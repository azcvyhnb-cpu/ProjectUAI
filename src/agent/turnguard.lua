-- Repeat and delegation guards for the turn loop.
--
-- Pure helpers split out of agent/loop: a canonical signature for a batch of
-- tool calls (the repeat breaker compares these), recognising a bounded wait on
-- subagents (which is exempt from the breaker), and the coordination note sent
-- while delegated work is still outstanding.
return function(env)
	local util = env.require("runtime/util")

	local M = {}

	local function argumentSignature(value, depth)
		if type(value) ~= "table" then return util.encode(value) end
		if (depth or 0) > 24 then return util.encode(value) end
		local parts = {}
		for _, key in ipairs(util.keys(value, true)) do
			parts[#parts + 1] = type(key) .. ":" .. util.encode(key) .. ":" .. argumentSignature(value[key], (depth or 0) + 1)
		end
		return "{" .. table.concat(parts, ",") .. "}"
	end

	local function callSignature(calls)
		local parts = {}
		for _, call in ipairs(calls or {}) do
			local fn = call["function"] or {}
			local args = type(fn.arguments) == "table" and fn.arguments or util.decode(fn.arguments or "{}")
			-- JSONDecode does not distinguish empty [] and {}. Keep the original
			-- signature in that case rather than refusing a different operation.
			local ambiguous = type(fn.arguments) == "string"
				and (fn.arguments:find("%[%s*%]") or fn.arguments:find("{%s*}"))
			parts[#parts + 1] = tostring(fn.name) .. "(" .. (args and not ambiguous and argumentSignature(args) or tostring(fn.arguments)) .. ")"
		end
		table.sort(parts)
		return table.concat(parts, "|")
	end

	local function waitingForSubagents(calls)
		if #calls == 0 then return false end
		for _, call in ipairs(calls) do
			local fn = call["function"] or {}
			if fn.name ~= "agent_status" then return false end
			local args = type(fn.arguments) == "table" and fn.arguments or util.decode(fn.arguments or "")
			local seconds = type(args) == "table" and args.wait_seconds
			if type(seconds) ~= "number" or seconds < 1 or seconds > 30 or seconds ~= math.floor(seconds) then return false end
		end
		return true
	end

	local function delegationReminder(session)
		local children = env.loadedModules and env.loadedModules["agent/subagent"]
		if not children then return nil end
		local pending = children.pending(session)
		if #pending == 0 then return nil end
		local lines = { "[UAI delegation status] Internal update: " .. #pending .. " subagent task(s) still require coordination." }
		for index = 1, math.min(24, #pending) do
			local record = pending[index]
			lines[#lines + 1] = tostring(record.id) .. ": " .. tostring(record.status)
				.. ((record.status == "running" or record.status == "queued") and "" or " (report not collected)")
		end
		if #pending > 24 then lines[#lines + 1] = tostring(#pending - 24) .. " more; list them with agent_status." end
		lines[#lines + 1] = "Continue your independent work and check subagents periodically with agent_status. "
			.. "Use a bounded wait of 1-30 seconds only when no independent work remains. Read each finished report by exact ID "
			.. "through its final page and incorporate it before the final answer. This is an internal coordination update, not a new user request."
		return table.concat(lines, "\n")
	end

	M.argumentSignature = argumentSignature
	M.callSignature = callSignature
	M.waitingForSubagents = waitingForSubagents
	M.delegationReminder = delegationReminder

	return M
end
