-- The turn loop.
--
-- Send the conversation, run whatever tools come back, repeat until the model
-- answers in prose or a limit stops it. Everything around that -- provider
-- failover, compaction, repeat detection, usage, the event stream -- is here
-- because it all has to interleave with the same loop. The stateless parts live
-- beside it: agent/completion (provider chain, summariser) and agent/turnguard
-- (repeat signatures, delegation reminder).
return function(env)
	local util = env.require("runtime/util")
	local config = env.require("runtime/config")
	local clock = env.require("runtime/clock")
	local log = env.require("runtime/log")
	local prompt = env.require("agent/prompt")
	local registry = env.require("agent/registry")
	local usage = env.require("agent/usage")
	local providers = env.require("provider/registry")

	local M = {}

	-- Largest share of a known context window the system prompt and tool schemas
	-- may take before the loop switches to a smaller tool tier.
	local OVERHEAD_SHARE = 0.45

	local function stopped(session)
		session.emit("abort", {})
		session.emit("status", { text = "Ready" })
		return "Stopped."
	end

	local function failed(session, text)
		session.emit("turn:end", { text = text, failed = true })
		session.emit("status", { text = "Ready" })
		return text
	end

	local guard = env.require("agent/turnguard")
	local argumentSignature, callSignature = guard.argumentSignature, guard.callSignature
	local waitingForSubagents, delegationReminder = guard.waitingForSubagents, guard.delegationReminder
	local completion = env.require("agent/completion")
	local complete, summariser = completion.complete, completion.summariser

	-- Runs one user prompt to completion. Returns the assistant's final text.
	function M.run(session, text, images)
		local ctx = session.ctx
		local maxTurns = session.maxTurns or config.get("agent.maxTurns", 24)
		local repeatLimit = config.get("agent.repeatLimit", 3)

		-- Unlimited tool calling. Two switches reach this and they are deliberately
		-- separate.
		--
		-- `agent.unlimitedTurns` is for the conversation the user is watching, so a
		-- session carrying its own step budget -- every subagent -- ignores it.
		-- `session.unlimited` is set by whoever created the session, which is how the
		-- dispatcher passes on `agent.subagentUnlimited`: a delegated child is lifted
		-- only when someone has asked for that in those words, because a child is the
		-- one session with nobody's attention on it.
		local unlimited = session.unlimited == true
			or (session.maxTurns == nil and config.get("agent.unlimitedTurns", false) == true)

		-- The wall-clock bound goes with the step limit rather than outliving it. A
		-- fifteen-minute ceiling left standing behind a switch labelled unlimited
		-- stops the same long job at roughly twice the step count and calls it running
		-- out of time -- the same wall wearing a different sign.
		local deadline = nil
		if not unlimited then
			deadline = clock.ms() + (session.budgetSeconds or 900) * 1000
		end

		-- Turn totals belong to the turn the user started. A subagent runs this same
		-- loop, so without this guard every dispatch reset the counter the interface is
		-- showing, and a batch of them reset it repeatedly, mid-turn, to whatever the
		-- last child happened to have spent.
		if not session.headless then usage.startTurn() end
		ctx.pushUser(text, images)
		session.emit("turn:start", { turns = unlimited and 0 or maxTurns, unlimited = unlimited })
		-- Checkpoint the prompt before any provider call: a host crash mid-turn
		-- otherwise loses the message and, for a new chat, the whole conversation.
		if session.persist then session.persist() end

		local lastSignature, streak = "", 0
		local finalText = nil
		-- One timestamp per turn. The environment block is rebuilt every step, and a
		-- minute ticking over inside it would change the prompt bytes mid-turn and
		-- void the provider's prefix cache for everything after it.
		local turnDate = os.date("!%Y-%m-%d %H:%M UTC")
		local turn = 0

		while unlimited or turn < maxTurns do
			turn = turn + 1
			if session.aborted() then
				return stopped(session)
			end
			if deadline and clock.ms() > deadline then
				session.emit("error", { message = "This turn ran out of time.", fatal = false })
				return failed(session, "I ran out of time on this turn. Ask me to continue if you want me to keep going.")
			end

			session.emit("status", { text = turn == 1 and "Thinking" or ("Working (step " .. turn .. ")") })

			local record = providers.active()

			-- A conversation the user has named keeps that name: the rename tool is
			-- absent from its catalogue rather than described and refused, the same
			-- way a missing capability or a disabled group is handled. A headless
			-- child has no visible title to name either.
			local exclude = session.toolExclude
			if session.named or session.headless then
				exclude = util.copy(exclude or {})
				exclude.conversation_rename = true
			end

			-- System prompt and tool list for one record at one size tier. A session
			-- may carry its own brief. A subagent does: it answers to the parent agent
			-- rather than to the user, so inheriting the main prompt would have it
			-- write a chat reply instead of a report.
			local function build(target, tier)
				local text, prefix
				if type(session.systemPrompt) == "function" then
					text, prefix = session.systemPrompt({ date = turnDate, tier = tier })
				elseif type(session.systemPrompt) == "string" and util.trim(session.systemPrompt) ~= "" then
					text = session.systemPrompt
				else
					text, prefix = prompt.buildWithPrefix({
						date = turnDate,
						tier = tier,
						model = target and target.model or nil,
						provider = target and target.label or nil,
						-- Which conversation this is for. The task list rides on the session,
						-- so a prompt built without it is built without the plan.
						session = session,
					})
				end
				local tools = registry.definitions({
					only = session.toolFilter,
					groups = session.toolGroups,
					exclude = exclude,
					lazy = true,
					loaded = session.loadedGroups,
					tier = tier,
				})
				return text, prefix, tools
			end

			-- Fixed overhead has to leave room for the conversation. When the prompt
			-- and schemas alone would take more than OVERHEAD_SHARE of a known window,
			-- step down to compact schemas, then to the essential tool set. The choice
			-- is a pure function of the window and the loaded groups, so it is stable
			-- from step to step and does not churn the provider's cache.
			local function prepare(target)
				local window = target and env.require("provider/traits").contextWindow(target.model)
				local tier, text, prefix, tools = 0
				while true do
					text, prefix, tools = build(target, tier)
					if not window or tier >= 2 or config.get("agent.lazyTools", true) == false then break end
					local overhead = usage.estimateText(text) + usage.estimateText(util.encode(tools))
					if overhead <= window * OVERHEAD_SHARE then break end
					tier = tier + 1
				end
				session.toolTier = tier
				return text, prefix, tools
			end

			local systemText, cachePrefix, tools = prepare(record)
			local request = {
				messages = ctx.wire(systemText, cachePrefix),
				tools = tools,
				stream = session.stream,
				onFrame = session.onFrame,
			}

			ctx.observeRequest(request.messages, request.tools, record)
			local before = ctx.tokens()
			local epoch = session.toolEpoch
			local function compactionAborted() return session.toolEpoch ~= epoch or session.aborted() end
			local summarise = config.get("agent.compaction", true) ~= false and summariser(session, record) or nil
			local summary = ctx.compact(summarise, { model = record and record.model, record = record, aborted = compactionAborted })
			if summary then session.emit("compact", { summary = summary, before = before, after = ctx.tokens() }) end
			if compactionAborted() then return stopped(session) end
			request.messages = ctx.wire(systemText, cachePrefix)

			local result, err, usedRecord, accounting = complete(session, request, function(refusedRecord)
				if session.aborted() then return false end
				local prior = ctx.tokens()
				local recoverSummary = config.get("agent.compaction", true) ~= false and summariser(session, refusedRecord) or nil
				-- The refusal may have just taught a smaller window. Re-fit the fixed
				-- overhead to it before folding history against what is left.
				local tierBefore = session.toolTier
				systemText, cachePrefix, request.tools = prepare(refusedRecord)
				request.messages = ctx.wire(systemText, cachePrefix)
				ctx.observeRequest(request.messages, request.tools, refusedRecord)
				local folded = ctx.compact(recoverSummary, { model = refusedRecord.model, record = refusedRecord,
					force = true, aborted = compactionAborted })
				if not folded and session.toolTier == tierBefore then return false end
				if folded then session.emit("compact", { summary = folded, before = prior, after = ctx.tokens() }) end
				request.messages = ctx.wire(systemText, cachePrefix)
				return true
			end)
			record = usedRecord or record

			if not result then
				if err == "aborted" then
					return stopped(session)
				end
				session.emit("error", { message = err, fatal = true })
				return failed(session, "I could not reach a provider. " .. tostring(err))
			end

			local spent = usage.record(result.usage, result.model or (record and record.model), {
				prompt = accounting and (accounting.history + accounting.estimate) or usage.estimateMessages(request.messages),
				completion = usage.estimateText(result.content) + usage.estimateText(result.reasoning),
			}, record)
			session.emit("usage", { session = usage.session, turn = usage.turn })

			if util.trim(result.reasoning) ~= "" then
				session.emit("assistant:reasoning", { text = result.reasoning, requestId = result.requestId, streamId = result.streamId, model = result.model })
			end
			local displayed = result.content or ""
			local coordination = #result.toolCalls == 0 and delegationReminder(session) or nil
			if #result.toolCalls == 0 and result.finish == "length" then
				displayed = displayed .. "\n\n[The provider reached its output limit before finishing this reply.]"
			elseif #result.toolCalls == 0 and result.finish == "content_filter" then
				displayed = displayed .. "\n\n[The provider filtered part of this reply.]"
			end
			if util.trim(displayed) ~= "" then
				session.emit("assistant:text", { text = displayed, final = #result.toolCalls == 0 and coordination == nil, requestId = result.requestId, streamId = result.streamId, model = result.model })
			end
			session.emit("assistant:complete", { streamId = result.streamId })

			-- Calibrate the context estimate against what the provider actually
			-- counted for this prompt, before the reply is stored: the real figure
			-- includes the system prompt and tool schemas the message estimate omits,
			-- so the next compaction check measures true window pressure.
			if spent and not spent.estimated then ctx.calibrate(spent.prompt, accounting) end
			ctx.pushAssistant(result)

			if #result.toolCalls == 0 then
				if coordination then
					-- A continuation message keeps Messages-compatible request order;
					-- it is not a user transcript event or a permanent system directive.
					ctx.push({ role = "user", content = coordination, internal = true })
					session.emit("status", { text = "Coordinating subagents" })
				else
					finalText = displayed
					break
				end
			else
				-- Identical batches mean the model is stuck. Rather than let it burn the
				-- turn budget, the results are replaced with a refusal that names the
				-- problem, which is enough for most models to change tack.
				local signature = callSignature(result.toolCalls)
				if waitingForSubagents(result.toolCalls) then
					lastSignature, streak = "", 0
				elseif signature == lastSignature then
					streak = streak + 1
				else
					lastSignature, streak = signature, 1
				end

				if streak >= repeatLimit then
					for _, call in ipairs(result.toolCalls) do
						local name = (call["function"] or {}).name or "tool"
						ctx.pushToolResult(call.id, name,
							"This exact call has already been made " .. tostring(streak) ..
							" times with the same arguments. It will not be run again. Change the approach, or answer with what you already know.")
					end
					session.emit("status", { text = "Breaking a repeat loop" })
					log.warn("loop", "repeat limit hit on " .. util.ellipsis(signature, 120))
				else
					for _, call in ipairs(result.toolCalls) do
						local fn = call["function"] or {}
						local tool = registry.get(fn.name)
						-- A deferred tool called by name (the prompt mentions several)
						-- still runs; its group is promoted so the next step carries the
						-- schema it was missing.
						if tool and registry.deferredFor(tool, session.toolTier) then
							session.loadedGroups = session.loadedGroups or {}
							if not session.loadedGroups[tool.group] then
								session.loadGeneration = (session.loadGeneration or 0) + 1
								session.loadedGroups[tool.group] = session.loadGeneration
							end
						end
						session.emit("tool:call", {
							id = call.id,
							name = fn.name,
							group = tool and tool.group or nil,
							risk = tool and tool.risk or "write",
							arguments = fn.arguments,
						})
					end

					session.emit("status", { text = result.finish == "length" and "Requesting smaller tool calls" or #result.toolCalls == 1
						and ("Running " .. ((result.toolCalls[1]["function"] or {}).name or "tool"))
						or ("Running " .. util.pluralise(#result.toolCalls, "tool")) })

					-- The transcript sees a result as soon as that call finishes. Keep the
					-- model's results in original call order after the entire batch settles.
					local results
					if result.finish == "length" then
						-- Even a complete first call may depend on a later one that was cut
						-- off. Return a result for every id so the next request can recover.
						results = {}
						for index, call in ipairs(result.toolCalls) do
							results[index] = {
								id = call.id, name = (call["function"] or {}).name or "tool",
								ok = false, error = "truncated arguments", ms = 0,
								text = "The provider cut off this tool batch at its token limit. No calls in this batch ran. "
									.. "Send smaller complete calls; split large scripts into sequential file_write/file_append calls or targeted file_edit edits.",
							}
							session.emit("tool:error", results[index])
						end
					else
						results = registry.runAll(result.toolCalls, session.toolContext(), function(outcome)
							session.emit(outcome.ok and "tool:result" or "tool:error", outcome)
						end)
					end

					for index, call in ipairs(result.toolCalls) do
						local outcome = results[index] or {
							id = call.id,
							name = (call["function"] or {}).name or "tool",
							ok = false,
							text = "The tool produced no result.",
						}
						ctx.pushToolResult(call.id, outcome.name, outcome.text)
					end
					if session.aborted() then
						if session.persist then session.persist() end
						return stopped(session)
					end
				end
				-- Checkpoint each settled batch (results or repeat refusals). Tools can
				-- run for minutes; a crash on a later step keeps every earlier one, and
				-- ctx.repair() answers any call that never recorded a result.
				if session.persist then session.persist() end
			end
		end

		if finalText == nil then
			session.emit("error", {
				message = "Reached the step limit of " .. tostring(maxTurns) .. ".",
				fatal = false,
			})
			finalText = "I reached this session's step limit before finishing. Tell me to continue and I will pick up where I stopped."
		end

		session.emit("turn:end", { text = finalText })
		session.emit("status", { text = "Ready" })
		return finalText
	end

	-- Compact on demand, outside a turn -- the composer's Compact now action. Uses
	-- the same summariser as the automatic path and forces a pass even when the
	-- conversation is under budget. Failed or non-reducing summaries preserve the
	-- conversation. Returns the summary, before/after estimates, and a no-op reason.
	function M.compact(session)
		local ctx = session.ctx
		local record = providers.active()
		local before = ctx.tokens()
		local epoch = session.toolEpoch
		local summary, reason = ctx.compact(summariser(session, record), { model = record and record.model,
			record = record, force = true, requireSummary = true,
			aborted = function() return session.toolEpoch ~= epoch or session.aborted() end })
		if summary then
			session.emit("compact", { summary = summary, before = before, after = ctx.tokens(), manual = true })
		end
		return summary, before, ctx.tokens(), reason
	end

	return M
end
