-- Provider-chain completion and the compaction summariser.
--
-- Split out of agent/loop. `complete` walks the fallback chain for one request,
-- with one in-place context recovery per refusing record; `summariser` builds the
-- callback agent/context uses to fold old history into a summary.
return function(env)
	local util = env.require("runtime/util")
	local config = env.require("runtime/config")
	local clock = env.require("runtime/clock")
	local prompt = env.require("agent/prompt")
	local usage = env.require("agent/usage")
	local hooks = env.require("agent/hooks")
	local providers = env.require("provider/registry")
	local chat = env.require("provider/chat")
	local stream = env.require("agent/stream")

	local M = {}

	-- One completion, walking the provider chain. Returns result, error, record.
	--
	-- A provider that fails is demoted by the registry and the next one is tried,
	-- so a rate-limited primary does not end the turn. Only when every candidate
	-- has failed does the turn fail, and the message names the first failure --
	-- which is almost always the informative one.
	local function complete(session, request, recoverContext)
		local epoch = session.toolEpoch
		local function aborted() return session.toolEpoch ~= epoch or session.aborted() end
		local chain = providers.chain()
		if #chain == 0 then
			return nil, "No provider is configured. Open the Providers panel and add one."
		end

		local firstError
		for index, record in ipairs(chain) do
			if aborted() then return nil, "aborted" end
			if index > 1 then
				session.emit("provider:switch", {
					from = chain[index - 1].label,
					to = record.label,
					reason = firstError,
				})
			end

			local recovered = false
			while true do
				if aborted() then return nil, "aborted" end
				local payload = { record = record, request = request, session = session }
				hooks.run("preRequest", payload)
				local accounting = session.ctx.observeRequest(payload.request.messages, payload.request.tools, record)
				local maxTokens = payload.request.maxTokens or config.get("agent.maxTokens", 4096)
				local outputCeiling
				local window = env.require("provider/traits").contextWindow(record.model)
				if window then
					local available = math.floor(window - session.ctx.pressure(record))
					-- A fallback can have a much smaller window than the provider whose
					-- budget was checked before entering this chain. Give its removable
					-- history the same one recovery opportunity as an API refusal.
					if available < 1 and not recovered and recoverContext and recoverContext(record) then
						recovered = true
						if aborted() then return nil, "aborted" end
						payload = { record = record, request = request, session = session }
						hooks.run("preRequest", payload)
						accounting = session.ctx.observeRequest(payload.request.messages, payload.request.tools, record)
						maxTokens = payload.request.maxTokens or config.get("agent.maxTokens", 4096)
						available = math.floor(window - session.ctx.pressure(record))
					end
					if available < 1 then
						firstError = firstError or "The prepared prompt exceeds this model's context window even after compaction. "
							.. "Use a larger-context model or reduce the enabled tools/standing instructions."
						break
					end
					maxTokens = tonumber(maxTokens) or 4096
					if maxTokens ~= maxTokens or maxTokens <= 0 or maxTokens == math.huge then maxTokens = 4096 end
					local margin = math.min(1024, math.floor(window * 0.02))
					outputCeiling = math.max(1, available - margin)
					maxTokens = math.min(maxTokens, outputCeiling)
				end
				local preview = stream.new(session, record.model, aborted)

				session.emit("request:start", {
					streamId = preview.id,
					provider = record.label,
					providerId = record.id,
					model = record.model,
					attempt = index,
					messages = #payload.request.messages,
					stream = payload.request.stream,
				})

				local started = clock.ms()
				local result, err, response = chat.complete(record, {
					sessionId = not session.headless and session.id or nil, session = session,
					messages = payload.request.messages,
					tools = payload.request.tools,
					toolChoice = payload.request.toolChoice,
					stream = payload.request.stream,
					temperature = payload.request.temperature,
					maxTokens = maxTokens,
					outputCeiling = outputCeiling,
					extra = payload.request.extra,
					aborted = aborted,
					onRetry = function(info)
						if aborted() then return end
						session.emit("request:retry", {
							provider = record.label,
							attempt = info.attempt,
							attempts = info.attempts,
							wait = info.wait,
							status = info.status,
							reason = info.reason,
						})
					end,
					onFrame = function(frame)
						if aborted() then return end
						preview.feed(frame)
						if request.onFrame then request.onFrame(frame) end
					end,
				})
				preview.close()

				if aborted() then return nil, "aborted" end
				if result then
					session.emit("request:done", {
						streamId = preview.id,
						provider = record.label,
						model = result.model or record.model,
						ms = clock.since(started),
						streamed = result.streamed,
						via = result.via,
					})
					local after = { result = result, record = record, session = session }
					hooks.run("postResponse", after)
					if util.trim(after.result.model) == "" then after.result.model = record.model end
					after.result.streamId = preview.id
					return after.result, nil, record, accounting
				end

				session.emit("request:done", {
					streamId = preview.id,
					provider = record.label,
					model = record.model,
					ms = clock.since(started),
					error = err,
				})
				if err == "aborted" or session.aborted() then return nil, "aborted" end
				if (response and response.terminal) or env.require("net/http").terminal(err) then return nil, err end
				-- Recover against the provider that actually refused the prompt, before
				-- failover. A smaller fallback model can have a different window.
				if recovered or not chat.contextOverflow(err) or not recoverContext or not recoverContext(record) then
					firstError = firstError or err
					break
				end
				recovered = true
			end
		end

		return nil, firstError or "every provider failed"
	end

	-- Compaction uses whatever provider is healthy, with no tools and a tight
	-- ceiling. Account for its cost separately without teaching the main context
	-- estimator that this small, tool-free prompt was the conversation request.
	local function summariser(session, preferredRecord)
		return function(transcript, maxBytes)
			local epoch = session.toolEpoch
			local record = preferredRecord or providers.active()
			if not record then return nil end
			local budgetBytes = maxBytes or 2048
			local messages = {
				{ role = "system", content = prompt.compaction(budgetBytes / 8) },
				{ role = "user", content = transcript },
			}
			-- A byte budget of four per token, capped well under any output limit.
			local maxTokens = math.min(4096, math.max(16, math.floor(budgetBytes / 4)))
			local window = env.require("provider/traits").contextWindow(record.model)
			if window then
				local available = math.floor(window - usage.estimateMessages(messages) - 64)
				if available < 16 then return nil end
				maxTokens = math.min(maxTokens, available)
			end
			session.emit("status", { text = "Compacting context" })
			local result = chat.complete(record, { session = session,
				messages = messages,
				temperature = 0,
				maxTokens = maxTokens,
				outputCeiling = maxTokens,
				attempts = 1,
				aborted = function() return session.toolEpoch ~= epoch or session.aborted() end,
			})
			if session.toolEpoch ~= epoch or session.aborted() then return nil end
			if result then
				usage.record(result.usage, result.model or record.model, {
					prompt = usage.estimateMessages(messages),
					completion = usage.estimateText(result.content) + usage.estimateText(result.reasoning),
				}, record)
				session.emit("usage", { session = usage.session, turn = usage.turn })
			end
			return result and result.finish ~= "length" and result.content or nil
		end
	end

	M.complete = complete
	M.summariser = summariser

	return M
end
