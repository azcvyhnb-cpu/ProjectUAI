-- Project UAI 2.6.0 -- WindUI runtime loader
-- Build windui-runtime-20261008
-- Temporary network-backed bundle generated from the WindUI branch.
-- It preserves the normal init.lua/module architecture while fetching source modules lazily.
local __UAI_BUILD = "windui-runtime-20261008"
local __UAI_MODULES = {}

local __UAI_BASE = "https://raw.githubusercontent.com/azcvyhnb-cpu/ProjectUAI/feat/windui-ui-optimize/src/"
local __UAI_SOURCE_CACHE = {}

local function __UAI_LOAD(id, env)
  local source = __UAI_SOURCE_CACHE[id]
  if not source then
    local url = __UAI_BASE .. id:gsub("%.", "%%.") .. ".lua"
    url = __UAI_BASE .. id .. ".lua"
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if not ok or type(body) ~= "string" or body == "" then
      error("failed to fetch module '" .. tostring(id) .. "': " .. tostring(body), 2)
    end
    source = body
    __UAI_SOURCE_CACHE[id] = source
  end
  local chunk, err = loadstring(source)
  if type(chunk) ~= "function" then
    error("failed to compile module '" .. tostring(id) .. "': " .. tostring(err), 2)
  end
  local ok, factory = pcall(chunk)
  if not ok or type(factory) ~= "function" then
    error("module '" .. tostring(id) .. "' did not return a factory", 2)
  end
  return factory(env)
end

__UAI_MODULES["agent/completion"] = function(env) return __UAI_LOAD("agent/completion", env) end
__UAI_MODULES["agent/context"] = function(env) return __UAI_LOAD("agent/context", env) end
__UAI_MODULES["agent/hooks"] = function(env) return __UAI_LOAD("agent/hooks", env) end
__UAI_MODULES["agent/loop"] = function(env) return __UAI_LOAD("agent/loop", env) end
__UAI_MODULES["agent/permissions"] = function(env) return __UAI_LOAD("agent/permissions", env) end
__UAI_MODULES["agent/pricing"] = function(env) return __UAI_LOAD("agent/pricing", env) end
__UAI_MODULES["agent/prompt"] = function(env) return __UAI_LOAD("agent/prompt", env) end
__UAI_MODULES["agent/registry"] = function(env) return __UAI_LOAD("agent/registry", env) end
__UAI_MODULES["agent/schema"] = function(env) return __UAI_LOAD("agent/schema", env) end
__UAI_MODULES["agent/session"] = function(env) return __UAI_LOAD("agent/session", env) end
__UAI_MODULES["agent/state"] = function(env) return __UAI_LOAD("agent/state", env) end
__UAI_MODULES["agent/stats"] = function(env) return __UAI_LOAD("agent/stats", env) end
__UAI_MODULES["agent/stream"] = function(env) return __UAI_LOAD("agent/stream", env) end
__UAI_MODULES["agent/subagent"] = function(env) return __UAI_LOAD("agent/subagent", env) end
__UAI_MODULES["agent/transcript"] = function(env) return __UAI_LOAD("agent/transcript", env) end
__UAI_MODULES["agent/turnguard"] = function(env) return __UAI_LOAD("agent/turnguard", env) end
__UAI_MODULES["agent/usage"] = function(env) return __UAI_LOAD("agent/usage", env) end
__UAI_MODULES["embedding/scope"] = function(env) return __UAI_LOAD("embedding/scope", env) end
__UAI_MODULES["embedding/sdk"] = function(env) return __UAI_LOAD("embedding/sdk", env) end
__UAI_MODULES["net/bridge"] = function(env) return __UAI_LOAD("net/bridge", env) end
__UAI_MODULES["net/bridge_commands"] = function(env) return __UAI_LOAD("net/bridge_commands", env) end
__UAI_MODULES["net/headers"] = function(env) return __UAI_LOAD("net/headers", env) end
__UAI_MODULES["net/http"] = function(env) return __UAI_LOAD("net/http", env) end
__UAI_MODULES["net/relay"] = function(env) return __UAI_LOAD("net/relay", env) end
__UAI_MODULES["net/sse"] = function(env) return __UAI_LOAD("net/sse", env) end
__UAI_MODULES["net/ua"] = function(env) return __UAI_LOAD("net/ua", env) end
__UAI_MODULES["net/url"] = function(env) return __UAI_LOAD("net/url", env) end
__UAI_MODULES["net/ws"] = function(env) return __UAI_LOAD("net/ws", env) end
__UAI_MODULES["provider/anthropic"] = function(env) return __UAI_LOAD("provider/anthropic", env) end
__UAI_MODULES["provider/catalog"] = function(env) return __UAI_LOAD("provider/catalog", env) end
__UAI_MODULES["provider/chat"] = function(env) return __UAI_LOAD("provider/chat", env) end
__UAI_MODULES["provider/community_key"] = function(env) return __UAI_LOAD("provider/community_key", env) end
__UAI_MODULES["provider/models"] = function(env) return __UAI_LOAD("provider/models", env) end
__UAI_MODULES["provider/openai"] = function(env) return __UAI_LOAD("provider/openai", env) end
__UAI_MODULES["provider/proxy"] = function(env) return __UAI_LOAD("provider/proxy", env) end
__UAI_MODULES["provider/registry"] = function(env) return __UAI_LOAD("provider/registry", env) end
__UAI_MODULES["provider/traits"] = function(env) return __UAI_LOAD("provider/traits", env) end
__UAI_MODULES["runtime/attachments"] = function(env) return __UAI_LOAD("runtime/attachments", env) end
__UAI_MODULES["runtime/bridge_install"] = function(env) return __UAI_LOAD("runtime/bridge_install", env) end
__UAI_MODULES["runtime/caps"] = function(env) return __UAI_LOAD("runtime/caps", env) end
__UAI_MODULES["runtime/changelog"] = function(env) return __UAI_LOAD("runtime/changelog", env) end
__UAI_MODULES["runtime/changes"] = function(env) return __UAI_LOAD("runtime/changes", env) end
__UAI_MODULES["runtime/chatbot"] = function(env) return __UAI_LOAD("runtime/chatbot", env) end
__UAI_MODULES["runtime/chatloops"] = function(env) return __UAI_LOAD("runtime/chatloops", env) end
__UAI_MODULES["runtime/clock"] = function(env) return __UAI_LOAD("runtime/clock", env) end
__UAI_MODULES["runtime/code_actions"] = function(env) return __UAI_LOAD("runtime/code_actions", env) end
__UAI_MODULES["runtime/code_diff"] = function(env) return __UAI_LOAD("runtime/code_diff", env) end
__UAI_MODULES["runtime/code_files"] = function(env) return __UAI_LOAD("runtime/code_files", env) end
__UAI_MODULES["runtime/code_lexer"] = function(env) return __UAI_LOAD("runtime/code_lexer", env) end
__UAI_MODULES["runtime/code_limits"] = function(env) return __UAI_LOAD("runtime/code_limits", env) end
__UAI_MODULES["runtime/code_store"] = function(env) return __UAI_LOAD("runtime/code_store", env) end
__UAI_MODULES["runtime/code_text"] = function(env) return __UAI_LOAD("runtime/code_text", env) end
__UAI_MODULES["runtime/community"] = function(env) return __UAI_LOAD("runtime/community", env) end
__UAI_MODULES["runtime/config"] = function(env) return __UAI_LOAD("runtime/config", env) end
__UAI_MODULES["runtime/config_transfer"] = function(env) return __UAI_LOAD("runtime/config_transfer", env) end
__UAI_MODULES["runtime/conversation_folders"] = function(env) return __UAI_LOAD("runtime/conversation_folders", env) end
__UAI_MODULES["runtime/dispose"] = function(env) return __UAI_LOAD("runtime/dispose", env) end
__UAI_MODULES["runtime/explorer"] = function(env) return __UAI_LOAD("runtime/explorer", env) end
__UAI_MODULES["runtime/fsx"] = function(env) return __UAI_LOAD("runtime/fsx", env) end
__UAI_MODULES["runtime/gamechat"] = function(env) return __UAI_LOAD("runtime/gamechat", env) end
__UAI_MODULES["runtime/gravity"] = function(env) return __UAI_LOAD("runtime/gravity", env) end
__UAI_MODULES["runtime/gravity_docs"] = function(env) return __UAI_LOAD("runtime/gravity_docs", env) end
__UAI_MODULES["runtime/images"] = function(env) return __UAI_LOAD("runtime/images", env) end
__UAI_MODULES["runtime/instance_edits"] = function(env) return __UAI_LOAD("runtime/instance_edits", env) end
__UAI_MODULES["runtime/instance_fields"] = function(env) return __UAI_LOAD("runtime/instance_fields", env) end
__UAI_MODULES["runtime/instance_paths"] = function(env) return __UAI_LOAD("runtime/instance_paths", env) end
__UAI_MODULES["runtime/instance_refs"] = function(env) return __UAI_LOAD("runtime/instance_refs", env) end
__UAI_MODULES["runtime/instance_scan"] = function(env) return __UAI_LOAD("runtime/instance_scan", env) end
__UAI_MODULES["runtime/instance_schema"] = function(env) return __UAI_LOAD("runtime/instance_schema", env) end
__UAI_MODULES["runtime/iy"] = function(env) return __UAI_LOAD("runtime/iy", env) end
__UAI_MODULES["runtime/iy_control"] = function(env) return __UAI_LOAD("runtime/iy_control", env) end
__UAI_MODULES["runtime/iy_plugins"] = function(env) return __UAI_LOAD("runtime/iy_plugins", env) end
__UAI_MODULES["runtime/iy_store"] = function(env) return __UAI_LOAD("runtime/iy_store", env) end
__UAI_MODULES["runtime/legacy_values"] = function(env) return __UAI_LOAD("runtime/legacy_values", env) end
__UAI_MODULES["runtime/log"] = function(env) return __UAI_LOAD("runtime/log", env) end
__UAI_MODULES["runtime/luacid"] = function(env) return __UAI_LOAD("runtime/luacid", env) end
__UAI_MODULES["runtime/native_exports"] = function(env) return __UAI_LOAD("runtime/native_exports", env) end
__UAI_MODULES["runtime/place"] = function(env) return __UAI_LOAD("runtime/place", env) end
__UAI_MODULES["runtime/project_patch"] = function(env) return __UAI_LOAD("runtime/project_patch", env) end
__UAI_MODULES["runtime/project_source"] = function(env) return __UAI_LOAD("runtime/project_source", env) end
__UAI_MODULES["runtime/remote_capture"] = function(env) return __UAI_LOAD("runtime/remote_capture", env) end
__UAI_MODULES["runtime/remote_hooks"] = function(env) return __UAI_LOAD("runtime/remote_hooks", env) end
__UAI_MODULES["runtime/remote_store"] = function(env) return __UAI_LOAD("runtime/remote_store", env) end
__UAI_MODULES["runtime/remote_targets"] = function(env) return __UAI_LOAD("runtime/remote_targets", env) end
__UAI_MODULES["runtime/script_project"] = function(env) return __UAI_LOAD("runtime/script_project", env) end
__UAI_MODULES["runtime/script_sources"] = function(env) return __UAI_LOAD("runtime/script_sources", env) end
__UAI_MODULES["runtime/signal"] = function(env) return __UAI_LOAD("runtime/signal", env) end
__UAI_MODULES["runtime/skills"] = function(env) return __UAI_LOAD("runtime/skills", env) end
__UAI_MODULES["runtime/ui_library_docs"] = function(env) return __UAI_LOAD("runtime/ui_library_docs", env) end
__UAI_MODULES["runtime/util"] = function(env) return __UAI_LOAD("runtime/util", env) end
__UAI_MODULES["runtime/values"] = function(env) return __UAI_LOAD("runtime/values", env) end
__UAI_MODULES["runtime/workspace"] = function(env) return __UAI_LOAD("runtime/workspace", env) end
__UAI_MODULES["tools/agentself"] = function(env) return __UAI_LOAD("tools/agentself", env) end
__UAI_MODULES["tools/character"] = function(env) return __UAI_LOAD("tools/character", env) end
__UAI_MODULES["tools/chat"] = function(env) return __UAI_LOAD("tools/chat", env) end
__UAI_MODULES["tools/chatloops"] = function(env) return __UAI_LOAD("tools/chatloops", env) end
__UAI_MODULES["tools/code_runner"] = function(env) return __UAI_LOAD("tools/code_runner", env) end
__UAI_MODULES["tools/coding"] = function(env) return __UAI_LOAD("tools/coding", env) end
__UAI_MODULES["tools/execution"] = function(env) return __UAI_LOAD("tools/execution", env) end
__UAI_MODULES["tools/explorer"] = function(env) return __UAI_LOAD("tools/explorer", env) end
__UAI_MODULES["tools/fs"] = function(env) return __UAI_LOAD("tools/fs", env) end
__UAI_MODULES["tools/fs_bulk"] = function(env) return __UAI_LOAD("tools/fs_bulk", env) end
__UAI_MODULES["tools/gravity"] = function(env) return __UAI_LOAD("tools/gravity", env) end
__UAI_MODULES["tools/gravity_parts"] = function(env) return __UAI_LOAD("tools/gravity_parts", env) end
__UAI_MODULES["tools/gravity_plugins"] = function(env) return __UAI_LOAD("tools/gravity_plugins", env) end
__UAI_MODULES["tools/gui"] = function(env) return __UAI_LOAD("tools/gui", env) end
__UAI_MODULES["tools/helpers"] = function(env) return __UAI_LOAD("tools/helpers", env) end
__UAI_MODULES["tools/init"] = function(env) return __UAI_LOAD("tools/init", env) end
__UAI_MODULES["tools/input"] = function(env) return __UAI_LOAD("tools/input", env) end
__UAI_MODULES["tools/instance"] = function(env) return __UAI_LOAD("tools/instance", env) end
__UAI_MODULES["tools/instance_bulk"] = function(env) return __UAI_LOAD("tools/instance_bulk", env) end
__UAI_MODULES["tools/instance_native"] = function(env) return __UAI_LOAD("tools/instance_native", env) end
__UAI_MODULES["tools/iy"] = function(env) return __UAI_LOAD("tools/iy", env) end
__UAI_MODULES["tools/meta"] = function(env) return __UAI_LOAD("tools/meta", env) end
__UAI_MODULES["tools/native_helpers"] = function(env) return __UAI_LOAD("tools/native_helpers", env) end
__UAI_MODULES["tools/net"] = function(env) return __UAI_LOAD("tools/net", env) end
__UAI_MODULES["tools/perf"] = function(env) return __UAI_LOAD("tools/perf", env) end
__UAI_MODULES["tools/players"] = function(env) return __UAI_LOAD("tools/players", env) end
__UAI_MODULES["tools/project"] = function(env) return __UAI_LOAD("tools/project", env) end
__UAI_MODULES["tools/project_testing"] = function(env) return __UAI_LOAD("tools/project_testing", env) end
__UAI_MODULES["tools/remote_capture"] = function(env) return __UAI_LOAD("tools/remote_capture", env) end
__UAI_MODULES["tools/remote_native"] = function(env) return __UAI_LOAD("tools/remote_native", env) end
__UAI_MODULES["tools/remote_replay"] = function(env) return __UAI_LOAD("tools/remote_replay", env) end
__UAI_MODULES["tools/remote_transport"] = function(env) return __UAI_LOAD("tools/remote_transport", env) end
__UAI_MODULES["tools/remotes"] = function(env) return __UAI_LOAD("tools/remotes", env) end
__UAI_MODULES["tools/scan"] = function(env) return __UAI_LOAD("tools/scan", env) end
__UAI_MODULES["tools/screen"] = function(env) return __UAI_LOAD("tools/screen", env) end
__UAI_MODULES["tools/script"] = function(env) return __UAI_LOAD("tools/script", env) end
__UAI_MODULES["tools/script_native"] = function(env) return __UAI_LOAD("tools/script_native", env) end
__UAI_MODULES["tools/skills"] = function(env) return __UAI_LOAD("tools/skills", env) end
__UAI_MODULES["tools/source_documents"] = function(env) return __UAI_LOAD("tools/source_documents", env) end
__UAI_MODULES["tools/templates"] = function(env) return __UAI_LOAD("tools/templates", env) end
__UAI_MODULES["tools/web"] = function(env) return __UAI_LOAD("tools/web", env) end
__UAI_MODULES["tools/workspace"] = function(env) return __UAI_LOAD("tools/workspace", env) end
__UAI_MODULES["tools/world"] = function(env) return __UAI_LOAD("tools/world", env) end
__UAI_MODULES["ui/app"] = function(env) return __UAI_LOAD("ui/app", env) end
__UAI_MODULES["ui/assets"] = function(env) return __UAI_LOAD("ui/assets", env) end
__UAI_MODULES["ui/boot"] = function(env) return __UAI_LOAD("ui/boot", env) end
__UAI_MODULES["ui/brand"] = function(env) return __UAI_LOAD("ui/brand", env) end
__UAI_MODULES["ui/changelog"] = function(env) return __UAI_LOAD("ui/changelog", env) end
__UAI_MODULES["ui/chat/activity"] = function(env) return __UAI_LOAD("ui/chat/activity", env) end
__UAI_MODULES["ui/chat/composer"] = function(env) return __UAI_LOAD("ui/chat/composer", env) end
__UAI_MODULES["ui/chat/context"] = function(env) return __UAI_LOAD("ui/chat/context", env) end
__UAI_MODULES["ui/chat/loops"] = function(env) return __UAI_LOAD("ui/chat/loops", env) end
__UAI_MODULES["ui/chat/message"] = function(env) return __UAI_LOAD("ui/chat/message", env) end
__UAI_MODULES["ui/chat/prompts"] = function(env) return __UAI_LOAD("ui/chat/prompts", env) end
__UAI_MODULES["ui/chat/table"] = function(env) return __UAI_LOAD("ui/chat/table", env) end
__UAI_MODULES["ui/chat/todo"] = function(env) return __UAI_LOAD("ui/chat/todo", env) end
__UAI_MODULES["ui/chat/view"] = function(env) return __UAI_LOAD("ui/chat/view", env) end
__UAI_MODULES["ui/chat/viewport"] = function(env) return __UAI_LOAD("ui/chat/viewport", env) end
__UAI_MODULES["ui/code/common"] = function(env) return __UAI_LOAD("ui/code/common", env) end
__UAI_MODULES["ui/code/compare"] = function(env) return __UAI_LOAD("ui/code/compare", env) end
__UAI_MODULES["ui/code/diff_view"] = function(env) return __UAI_LOAD("ui/code/diff_view", env) end
__UAI_MODULES["ui/code/editor"] = function(env) return __UAI_LOAD("ui/code/editor", env) end
__UAI_MODULES["ui/code/explorer"] = function(env) return __UAI_LOAD("ui/code/explorer", env) end
__UAI_MODULES["ui/code/files"] = function(env) return __UAI_LOAD("ui/code/files", env) end
__UAI_MODULES["ui/code/forms"] = function(env) return __UAI_LOAD("ui/code/forms", env) end
__UAI_MODULES["ui/code/history"] = function(env) return __UAI_LOAD("ui/code/history", env) end
__UAI_MODULES["ui/code/large_source"] = function(env) return __UAI_LOAD("ui/code/large_source", env) end
__UAI_MODULES["ui/code/library"] = function(env) return __UAI_LOAD("ui/code/library", env) end
__UAI_MODULES["ui/code/list"] = function(env) return __UAI_LOAD("ui/code/list", env) end
__UAI_MODULES["ui/code/metrics"] = function(env) return __UAI_LOAD("ui/code/metrics", env) end
__UAI_MODULES["ui/code/output"] = function(env) return __UAI_LOAD("ui/code/output", env) end
__UAI_MODULES["ui/code/preview"] = function(env) return __UAI_LOAD("ui/code/preview", env) end
__UAI_MODULES["ui/code/remotes"] = function(env) return __UAI_LOAD("ui/code/remotes", env) end
__UAI_MODULES["ui/code/splitter"] = function(env) return __UAI_LOAD("ui/code/splitter", env) end
__UAI_MODULES["ui/code/syntax"] = function(env) return __UAI_LOAD("ui/code/syntax", env) end
__UAI_MODULES["ui/code/tabs"] = function(env) return __UAI_LOAD("ui/code/tabs", env) end
__UAI_MODULES["ui/code/value_tree"] = function(env) return __UAI_LOAD("ui/code/value_tree", env) end
__UAI_MODULES["ui/code/world_picker"] = function(env) return __UAI_LOAD("ui/code/world_picker", env) end
__UAI_MODULES["ui/community"] = function(env) return __UAI_LOAD("ui/community", env) end
__UAI_MODULES["ui/controls"] = function(env) return __UAI_LOAD("ui/controls", env) end
__UAI_MODULES["ui/conversations"] = function(env) return __UAI_LOAD("ui/conversations", env) end
__UAI_MODULES["ui/icons"] = function(env) return __UAI_LOAD("ui/icons", env) end
__UAI_MODULES["ui/instance_icons"] = function(env) return __UAI_LOAD("ui/instance_icons", env) end
__UAI_MODULES["ui/markdown"] = function(env) return __UAI_LOAD("ui/markdown", env) end
__UAI_MODULES["ui/overlay"] = function(env) return __UAI_LOAD("ui/overlay", env) end
__UAI_MODULES["ui/panels/agents"] = function(env) return __UAI_LOAD("ui/panels/agents", env) end
__UAI_MODULES["ui/panels/ask"] = function(env) return __UAI_LOAD("ui/panels/ask", env) end
__UAI_MODULES["ui/panels/code"] = function(env) return __UAI_LOAD("ui/panels/code", env) end
__UAI_MODULES["ui/panels/cowork"] = function(env) return __UAI_LOAD("ui/panels/cowork", env) end
__UAI_MODULES["ui/panels/home"] = function(env) return __UAI_LOAD("ui/panels/home", env) end
__UAI_MODULES["ui/panels/logs"] = function(env) return __UAI_LOAD("ui/panels/logs", env) end
__UAI_MODULES["ui/panels/modelpicker"] = function(env) return __UAI_LOAD("ui/panels/modelpicker", env) end
__UAI_MODULES["ui/panels/permission"] = function(env) return __UAI_LOAD("ui/panels/permission", env) end
__UAI_MODULES["ui/panels/providers"] = function(env) return __UAI_LOAD("ui/panels/providers", env) end
__UAI_MODULES["ui/panels/settings"] = function(env) return __UAI_LOAD("ui/panels/settings", env) end
__UAI_MODULES["ui/panels/settingsdialog"] = function(env) return __UAI_LOAD("ui/panels/settingsdialog", env) end
__UAI_MODULES["ui/panels/tools"] = function(env) return __UAI_LOAD("ui/panels/tools", env) end
__UAI_MODULES["ui/primitives"] = function(env) return __UAI_LOAD("ui/primitives", env) end
__UAI_MODULES["ui/profile"] = function(env) return __UAI_LOAD("ui/profile", env) end
__UAI_MODULES["ui/project"] = function(env) return __UAI_LOAD("ui/project", env) end
__UAI_MODULES["ui/quickchat"] = function(env) return __UAI_LOAD("ui/quickchat", env) end
__UAI_MODULES["ui/responsive"] = function(env) return __UAI_LOAD("ui/responsive", env) end
__UAI_MODULES["ui/settingspanes"] = function(env) return __UAI_LOAD("ui/settingspanes", env) end
__UAI_MODULES["ui/settingsrows"] = function(env) return __UAI_LOAD("ui/settingsrows", env) end
__UAI_MODULES["ui/sidebar"] = function(env) return __UAI_LOAD("ui/sidebar", env) end
__UAI_MODULES["ui/theme"] = function(env) return __UAI_LOAD("ui/theme", env) end
__UAI_MODULES["ui/wind_shell"] = function(env) return __UAI_LOAD("ui/wind_shell", env) end
__UAI_MODULES["ui/window"] = function(env) return __UAI_LOAD("ui/window", env) end
__UAI_MODULES["ui/windui"] = function(env) return __UAI_LOAD("ui/windui", env) end

--!globals __UAI_MODULES __UAI_BUILD
-- Bootstrap.
--
-- Everything above this file is a factory of the form `return function(env)`. This
-- is the one chunk that is not: it builds the env, wires the module loader, and
-- mounts the interface. The bundler emits it last, after the module table, so
-- `__UAI_MODULES` is a local in the finished artifact.
--
-- Run it as:
--     loadstring(game:HttpGet("<url>/dist/uai.lua"))()
-- or, when embedding it in a host script, pass a context table:
--     loadstring(...)({ prompt = "You also control X", hooks = { preTool = fn } })

local MODULES = __UAI_MODULES
if type(MODULES) ~= "table" then
	warn("[uai] no module table -- run the bundled dist/uai.lua, not src/init.lua")
	return nil
end

local hostContext = ...

local VERSION = "2.6.0"
local FOLDER = "UAI"
local BUILD = type(__UAI_BUILD) == "string" and __UAI_BUILD or VERSION

-- Re-running the same build reopens it; a changed build replaces an idle client.
-- Never tear down active work or mount over a cleanup that did not finish.
local globalTable = (type(getgenv) == "function") and getgenv() or nil
if globalTable and type(globalTable.UAI) == "table" then
	local existing = globalTable.UAI
	if existing.alive or existing.reloadBlocked then
		local function notice(message)
			local shown, toast = pcall(function()
				local overlay = existing.env.loadedModules and existing.env.loadedModules["ui/overlay"]
				if overlay and existing.app and existing.app.screen then return overlay.toast(message, "warn", 7) end
			end)
			if not shown or not toast or not existing.alive then warn("[uai] " .. message) end
		end
		if existing.reloadBlocked then
			notice("The previous client did not finish unloading. Rejoin before loading the update.")
			return existing
		end
		if existing.build == BUILD then
			local options = type(hostContext) == "table" and hostContext
				or (type(globalTable.UAI_CONTEXT) == "table" and globalTable.UAI_CONTEXT) or {}
			if options.reuse ~= true and type(existing.toggle) == "function" then pcall(existing.toggle) end
			return existing
		end
		existing.pendingBuild = BUILD
		local inspected, busy = pcall(function()
			local runner = existing.env.loadedModules and existing.env.loadedModules["tools/code_runner"]
			if runner and runner.busy and runner.busy() then return true end
			for _, session in ipairs(existing.sessions.list()) do
				if session.busy then return true end
			end
			local child = existing.env.loadedModules and existing.env.loadedModules["agent/subagent"]
			return child ~= nil and #child.running() > 0
		end)
		if not inspected then
			notice("Update ready. Could not check active work; reopen the client after your work finishes.")
			return existing
		end
		if busy then
			notice("Update ready. Let the current work finish or stop it, then run the loader again.")
			return existing
		end
		local checkedDrafts, pending = pcall(function()
			local workspace = existing.env.loadedModules and existing.env.loadedModules["runtime/code_store"]
			if workspace and workspace.preflightReplacement then
				local preserved, why = workspace.preflightReplacement()
				if not preserved then return "Update ready. " .. tostring(why) end
			end
			for _, session in ipairs(existing.sessions.list()) do
				local ctx = session.ctx or {}
				if session.ephemeral and (#(session.log or {}) > 0 or #(ctx.messages or {}) > 0
					or (type(ctx.summary) == "string" and ctx.summary ~= "") or session.named or (session.turns or 0) > 0) then
					return "Update ready. Save or remove your isolated conversations before running the loader again."
				end
			end
			local composer = existing.app and existing.app.chatPanel and existing.app.chatPanel.composer
			local chatLoops = existing.env.loadedModules and existing.env.loadedModules["runtime/chatloops"]
			if chatLoops and #chatLoops.running() > 0 then
				return "Update ready. Stop your chat loops before running the loader again."
			end
			local composerModule = existing.env.loadedModules and existing.env.loadedModules["ui/chat/composer"]
			local quick = existing.env.loadedModules and existing.env.loadedModules["ui/quickchat"]
			local function hasText(field)
				return field and type(field.get) == "function" and tostring(field.get()):find("%S") ~= nil
			end
			if (composer and (hasText(composer.field) or #(composer.attachments or {}) > 0))
				or (composerModule and composerModule.hasDrafts and composerModule.hasDrafts()) then
				return "Update ready. Send or clear your draft and attachments before running the loader again."
			end
			if quick and hasText(quick.field) then
				return "Update ready. Send or clear your Quick Chat draft before running the loader again."
			end
		end)
		if not checkedDrafts or pending then
			notice(pending or "Update ready. Could not check unsaved drafts, so this client is staying open.")
			return existing
		end
		local saved, complete = pcall(function()
			local fsx = existing.env.require("runtime/fsx")
			if not fsx.enabled then return false end
			if not existing.config.saveNow() then return false end
			for _, session in ipairs(existing.sessions.list()) do
				if not session.headless and not session.ephemeral and (session.depth or 0) == 0 then
					if not existing.sessions.persist(session) then return false end
				end
			end
			return true
		end)
		if not saved or not complete then
			notice("Update ready. Settings and conversations could not be saved, so this client is staying open.")
			return existing
		end
		if hostContext == nil and existing.env and type(existing.env.context) == "table" then
			hostContext = existing.env.context
		end
		local unloaded, result = pcall(function() return existing.destroy() end)
		local checked, detached = pcall(function()
			return not existing.app or not existing.app.screen or existing.app.screen.Parent == nil
		end)
		if not unloaded or result == false or existing.alive or existing.cleanupFailed or not checked or not detached then
			existing.reloadBlocked = true
			globalTable.UAI = existing
			notice("The previous client did not finish unloading. Rejoin before loading the update.")
			return existing
		end
	end
end

-- Services are resolved lazily and memoised. GetService is the correct accessor
-- even for Workspace and Players: a game may have renamed the instance, and
-- indexing `game.Workspace` would then miss.
local services = setmetatable({}, {
	__index = function(cache, name)
		local ok, service = pcall(function() return game:GetService(name) end)
		if not ok or not service then return nil end
		cache[name] = service
		return service
	end,
})

local env = {
	info = { name = "UAI", version = VERSION, build = BUILD, folder = FOLDER },
	services = services,
	context = (type(hostContext) == "table" and hostContext)
		or (globalTable and type(globalTable.UAI_CONTEXT) == "table" and globalTable.UAI_CONTEXT)
		or {},
}

env.hs = services.HttpService
env.uis = services.UserInputService
env.tween = services.TweenService
env.run = services.RunService
env.guisvc = services.GuiService
env.players = services.Players
env.plr = env.players and env.players.LocalPlayer or nil

-- The loader. Cycles are an error rather than a hang: a module that is already
-- loading has been reached again, and returning a half-built table would fail
-- somewhere far away from the cause.
local loaded, loading = {}, {}

-- How many modules this artifact carries, counted rather than written down: the
-- bundler decides it, and a literal here would go stale on the next build. It is the
-- only denominator available to the boot indicator, and it is deliberately *not*
-- treated as a target -- a normal boot loads about four fifths of it and never
-- reaches the rest, because a panel's module is loaded the first time that panel is
-- opened.
env.moduleTotal = 0
for _ in pairs(MODULES) do env.moduleTotal = env.moduleTotal + 1 end
env.moduleCount = 0

function env.require(id)
	local cached = loaded[id]
	if cached ~= nil then return cached end
	if loading[id] then
		error("[uai] circular require: " .. tostring(id), 2)
	end
	local factory = MODULES[id]
	if type(factory) ~= "function" then
		error("[uai] no module '" .. tostring(id) .. "'", 2)
	end
	loading[id] = true
	local ok, result = pcall(factory, env)
	loading[id] = nil
	if not ok then
		error("[uai] module '" .. tostring(id) .. "' failed to load: " .. tostring(result), 2)
	end
	if result == nil then
		error("[uai] module '" .. tostring(id) .. "' returned nothing", 2)
	end
	loaded[id] = result
	env.moduleCount = env.moduleCount + 1
	-- The one hook in the loader, and it exists for the boot indicator: the count is
	-- real work finishing, which is the only progress this client can honestly report
	-- before the interface is up. pcall because a watcher must never be able to stop a
	-- module from loading.
	if env.onModuleLoaded then pcall(env.onModuleLoaded, id, env.moduleCount, env.moduleTotal) end
	return result
end

env.loadedModules = loaded

local function start()
	local mountAtBoot = env.context.ui ~= false
	-- The boot indicator first, before a single other module loads.
	--
	-- It is dependency free on purpose, so it can paint within a frame of execution
	-- rather than after the theme and the control set are built -- the seconds those
	-- take are exactly what it exists to cover, and it used to appear only once three
	-- quarters of them were already spent. It is only a pcall deep because a client
	-- that cannot draw it must still boot: a progress bar is not worth failing a
	-- start over.
	local boot
	if mountAtBoot then pcall(function() boot = env.require("ui/boot").show() end) end

	-- The loader reports real work finishing -- the only honest progress there is
	-- before the interface is up -- and yields on a budget while it does, so the
	-- indicator animates instead of freezing until the mount is done. A Roblox GUI
	-- does not paint until the thread building it yields, and the whole boot used to
	-- run start-to-finish without one; the throttle keeps a fast client from paying
	-- for yields it does not need while still repainting a slow one a few times a
	-- second. pcall on step because a watcher must never stop a module loading.
	local lastYield = os.clock()
	env.onModuleLoaded = function(id, count, total)
		if boot then pcall(boot.step, id, count, total) end
		if os.clock() - lastYield >= 0.03 then
			task.wait()
			lastYield = os.clock()
		end
	end

	-- The interface build is the tail of the boot that module counting cannot see:
	-- once every module is loaded the counter sits still while the window, the
	-- transcript and the composer are constructed -- the single largest synchronous
	-- chunk of the whole start, and where the bar used to jump to four fifths and then
	-- freeze. app.mount calls this at those construction boundaries, so the indicator
	-- yields across them and keeps animating. Set only for the first mount and cleared
	-- with the loader below, so a later rebuild never pays for it.
	if mountAtBoot then
		env.onMountPhase = function(text)
			if boot then pcall(boot.phase, text) end
			task.wait()
		end
	end

	-- Force the first paint before the heavy loading begins, so the indicator is on
	-- screen for the whole of it rather than appearing at the end.
	if boot then task.wait() end

	-- Startup order matters in exactly one place: config has to be read before
	-- anything derives from it, because the theme and the provider list are both
	-- built from stored values.
	local caps = env.require("runtime/caps")
	local log = env.require("runtime/log")
	local config = env.require("runtime/config")

	config.load()
	log.mirror = config.get("logs.mirror", false) == true
	log.info("boot", string.format("UAI %s starting -- %s", VERSION, caps.summary()))

	-- Asked for early and answered in the background: the place name is what the
	-- conversation list groups by, and it is a web call.
	env.require("runtime/place").resolve()

	env.require("agent/hooks").adoptContext()
	env.require("agent/registry").load()

	-- The workspace migration, before anything that reads files/: the file tools,
	-- the paste fallbacks, the attach menu. For a returning user with older files
	-- this is the step between "it used to see my notes" and the tidy layout, so it
	-- is reported through the boot indicator while it happens rather than logged
	-- where nobody looks. A fresh install sweeps an empty root and reports nothing.
	pcall(function()
		local fsx = env.require("runtime/fsx")
		local alreadyMigrated = config.get("fs.migrated", false) == true
		local hasDisplacedSkills = fsx.isDir("skills", { scope = "files" })
		if alreadyMigrated and not hasDisplacedSkills then return end

		local swept = fsx.list("")
		local pending = 0
		for _, entry in ipairs(swept) do
			if not tostring(entry.path or ""):find("/", 1, true) then
				local name = tostring(entry.name or "")
				local clientOwns = name == "files" or name == "pastes" or name == "skills"
					or name == "sessions" or name == "export" or name == "icons"
					or name == "config.json" or name == "stats.json"
				if not clientOwns then pending = pending + 1 end
			end
		end
		if (pending > 0 or hasDisplacedSkills) and boot then
			boot.phase("updating: your files are moving to the new layout", 0)
		end
		local moved = fsx.migrate(function(count, name)
			if boot then boot.phase(string.format("moved %d: %s", count, name), math.min(count / 30, 0.9)) end
		end)
		if moved and moved > 0 and boot then
			boot.phase(string.format("moved %d file(s) into files/", moved), 1)
		end
		config.set("fs.migrated", true)
		config.save()
		fsx.ensure("skills")
		fsx.ensure("files")
	end)

	local sessions = env.require("agent/session")
	sessions.restore()

	-- After the restore, because the first run recovers the real message history out
	-- of whatever transcripts are already on disk, and before the interface, because
	-- the home card reads it as soon as it builds.
	env.require("agent/stats").init()

	local app, handle
	local mounting, mountFailure = false, nil
	local function mountApp()
		if handle and not handle.alive then return nil, "client is unloaded" end
		if mounting then return nil, "interface is already mounting" end
		if mountFailure then return nil, mountFailure end
		mounting = true
		local ok, why = pcall(function()
			app = env.require("ui/app")
			if handle then handle.app = app end
			app.mount()
			if not app.screen or not app.screen.Parent then error("nowhere to parent the interface", 0) end
		end)
		mounting = false
		if not ok then
			mountFailure = tostring(why)
			log.error("app", "could not mount interface", mountFailure)
			return nil, mountFailure
		end
		if handle then handle.uiMounted = true end
		return app
	end
	if mountAtBoot then
		local mounted, why = mountApp()
		if not mounted then error(why, 0) end
		app.show(config.get("ui.panel", "chat"))
	else
		-- A UI-free client still has a selected conversation for the bridge and ask().
		sessions.current()
	end

	-- The interface is up, so the indicator has nothing left to report. The count is
	-- what it closes on: the rest of the artifact is the panels nobody has opened yet.
	env.onModuleLoaded = nil
	env.onMountPhase = nil
	if boot then
		pcall(boot.done, string.format("%d of %d modules loaded -- the rest load with the panel that needs them",
			env.moduleCount, env.moduleTotal))
	end

	-- After the interface, because the bridge attaches to whichever thread is
	-- active and the interface is what establishes that on a fresh install. A
	-- no-op unless the setting has been turned on.
	local bridge = env.require("net/bridge")
	local bridgeOk, bridgeWhy = bridge.sync()
	if not bridgeOk and bridgeWhy then log.warn("bridge", "not started", bridgeWhy) end

	-- The handle a host script (or the user, from a console) can drive.
	-- Declared before it is populated: `local handle = { ... }` does not put `handle`
	-- in scope inside its own initialiser, so every closure below that reaches for
	-- `handle` would have captured a nil global instead. `destroy` did exactly that,
	-- which is why unloading raised rather than unloading.
	handle = {
		alive = true,
		uiMounted = app ~= nil and app.screen ~= nil and app.screen.Parent ~= nil,
		version = VERSION,
		build = BUILD,
		env = env,
		app = app,
		sessions = sessions,
		config = config,
		log = log,
		caps = caps,
		bridge = bridge,
		hooks = env.require("agent/hooks"),
		permissions = env.require("agent/permissions"),
		providers = env.require("provider/registry"),
		tools = env.require("agent/registry"),
		toggle = function()
			local mounted, why = mountApp()
			if not mounted then return false, why end
			mounted.toggle()
			return true
		end,
		show = function(panel)
			local mounted, why = mountApp()
			if not mounted then return false, why end
			mounted.show(panel)
			return true
		end,
		hide = function()
			if not handle.alive then return false, "client is unloaded" end
			if app then app.hide() end
			return true
		end,
		openSession = function(id)
			if not handle.alive then return false, "client is unloaded" end
			if id ~= nil and not sessions.threads[id] then return false, "conversation no longer exists" end
			local mounted, why = mountApp()
			if not mounted then return false, why end
			return mounted.openSession(id)
		end,
		ask = function(text)
			if not handle.alive then return false, "client is unloaded" end
			local session = sessions.current()
			return session.send(text)
		end,
		-- The kill switch. Destroying the ScreenGui is not unloading: timers keep
		-- ticking, input handlers keep firing on the service, and a config write
		-- would rebuild an interface that is no longer on screen. Everything that
		-- outlives the instance tree registers a cleanup in runtime/dispose, and
		-- this is what drains it.
		--
		--     getgenv().UAI.destroy()
		destroy = function()
			if not handle.alive then return 0 end
			handle.alive = false
			-- Every turn in flight is stopped, not just the one on screen: conversations
			-- run on their own threads and more than one can be working, so aborting the
			-- active session alone left the others to finish into a transcript that had
			-- already been destroyed.
			for _, session in ipairs(sessions.list()) do
				pcall(session.abort)
			end
			-- Anything delegated is stopped with them. A subagent outlives the step that
			-- dispatched it by design, and its budget is measured in minutes.
			pcall(function() env.require("agent/subagent").stopAll() end)
			local ran, failed = env.require("runtime/dispose").drain()
			local screenOk = pcall(function() if app and app.screen then app.screen:Destroy() end end)
			handle.uiMounted = false
			handle.cleanupFailed = not screenOk or #(failed or {}) > 0
			pcall(function() config.saveNow() end)
			if globalTable and globalTable.UAI == handle then globalTable.UAI = nil end
			log.info("boot", string.format("unloaded -- %d cleanups run", ran or 0))
			for _, problem in ipairs(failed or {}) do
				log.warn("boot", "cleanup failed", problem)
			end
			return ran
		end,
		unload = function() return handle.destroy() end,
	}
	handle.sdk = env.require("embedding/sdk").attach(handle)

	if globalTable then globalTable.UAI = handle end
	log.info("boot", "ready")
	return handle
end

local ok, result = pcall(start)
if not ok then
	warn("[uai] failed to start: " .. tostring(result))
	-- A visible failure beats a silent one: the log module may not even have
	-- loaded, so this goes to the console directly.
	--
	-- And on screen too, where the indicator already is: a boot that dies at module
	-- forty leaves a bar stopped at forty and no explanation, which is worse than
	-- never having drawn one. Both the flag and the notice are cleared here, so a
	-- half-loaded client leaves nothing of itself behind.
	env.onModuleLoaded = nil
	env.onMountPhase = nil
	local disposer = loaded["runtime/dispose"]
	if disposer then pcall(disposer.drain) end
	local app = loaded["ui/app"]
	pcall(function() if app and app.screen then app.screen:Destroy() end end)
	local boot = loaded["ui/boot"]
	if boot then pcall(boot.fail, result) end
	return nil
end
return result

