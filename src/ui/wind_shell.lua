-- WindUI presentation shell for Project UAI.
-- Keeps the existing panel/agent architecture and replaces only the chrome/navigation.
return function(env)
    local WindUI = env.require("ui/windui")
    local config = env.require("runtime/config")
    local sessions = env.require("agent/session")
    local providers = env.require("provider/registry")
    local place = env.require("runtime/place")
    local util = env.require("runtime/util")
    local log = env.require("runtime/log")

    local M = {}

    local PANEL_META = {
        { id = "chat", label = "Chat", icon = "message-circle" },
        { id = "cowork", label = "Cowork", icon = "briefcase" },
        { id = "code", label = "Code", icon = "code-2" },
        { id = "agents", label = "Subagents", icon = "users" },
        { id = "providers", label = "Providers", icon = "sliders-horizontal" },
        { id = "tools", label = "Tools", icon = "wrench" },
        { id = "settings", label = "Settings", icon = "settings" },
        { id = "logs", label = "Logs", icon = "file-text" },
    }

    local function makeWindow()
        local w = WindUI:CreateWindow({
            Title = "Project UAI",
            Author = "Universal AI Agent",
            Folder = "ProjectUAI",
            Theme = config.get("ui.theme", "Dark") == "Light" and "Light" or "Dark",
            NewElements = true,
            HideSearchBar = false,
            AutoScale = true,
            Size = UDim2.fromOffset(760, 560),
            MinSize = Vector2.new(520, 380),
            MaxSize = Vector2.new(1100, 820),
        })

        local wrapper = {
            native = w,
            visible = false,
            maximised = false,
            root = w.UIElements and w.UIElements.Main or nil,
            header = w.UIElements and w.UIElements.Main or nil,
            headerHeight = 0,
            body = w.UIElements and w.UIElements.MainBar or nil,
        }

        function wrapper.show()
            if wrapper.native and not wrapper.native.Destroyed then
                wrapper.native:Open()
                wrapper.visible = true
            end
        end

        function wrapper.hide()
            if wrapper.native and not wrapper.native.Destroyed then
                wrapper.native:Close()
                wrapper.visible = false
            end
        end

        function wrapper.toggleMaximised()
            if wrapper.native and not wrapper.native.Destroyed then
                wrapper.native:ToggleFullscreen()
                wrapper.maximised = not wrapper.maximised
            end
        end

        function wrapper.setMinWidth(_) end

        function wrapper.destroy()
            if wrapper.native and not wrapper.native.Destroyed then
                wrapper.native:Destroy()
            end
            wrapper.visible = false
        end

        return wrapper
    end

    function M.mount(app)
        if M.window and M.window.visible then return M end

        M.app = app
        M.window = makeWindow()
        M.screen = M.window.root
        M.tabs = {}
        M.tabById = {}

        -- WindUI owns the window chrome. Existing UAI panels remain native UAI
        -- surfaces and are mounted into each tab's content canvas.
        app.body = M.window.body
        app.panels = app.panels or {}
        app.chatPanel = nil

        for _, spec in ipairs(PANEL_META) do
            local tab = M.window.native:Tab({
                Title = spec.label,
                Icon = spec.icon,
                ShowTabTitle = false,
            })
            M.tabs[#M.tabs + 1] = tab
            M.tabById[spec.id] = tab

            local canvas = tab.UIElements and tab.UIElements.ContainerFrameCanvas
            local list = tab.UIElements and tab.UIElements.ContainerFrame
            if list then
                list.Visible = false
            end

            if canvas then
                canvas.ClipsDescendants = true
                local holder = Instance.new("Frame")
                holder.Name = "UAI_" .. spec.id
                holder.BackgroundTransparency = 1
                holder.BorderSizePixel = 0
                holder.Size = UDim2.fromScale(1, 1)
                holder.Position = UDim2.fromScale(0, 0)
                holder.Parent = canvas
                M.holders = M.holders or {}
                M.holders[spec.id] = holder

                holder.Destroying:Connect(function()
                    if app.panels[spec.id] and app.panels[spec.id].destroy then
                        pcall(app.panels[spec.id].destroy)
                    end
                end)
            end

            if tab.UIElements and tab.UIElements.Main then
                tab.UIElements.Main.Activated:Connect(function()
                    if M.selecting then return end
                    M.selecting = true
                    app.showPanel(spec.id)
                    M.selecting = false
                end)
            end
        end

        function M.select(id)
            local tab = M.tabById[id]
            local holder = M.holders and M.holders[id]
            if not tab or not holder then return false end
            M.selecting = true
            app.showPanel(id)
            M.window.native:SelectTab(tab.Index)
            M.selecting = false
            return true
        end

        -- Build only the current panel. Other panels are lazy and retain all their
        -- existing runtime/state behavior.
        app.body = M.holders[app.panel] or app.body
        app.showPanel(app.panel or "chat")

        local session = sessions.current()
        local record = providers.active()
        local model = record and util.trim(tostring(record.model or "")) or ""
        local subtitle = place.label()
        if record then
            subtitle = subtitle .. "  ·  " .. tostring(record.label or "provider")
            if model ~= "" then subtitle = subtitle .. "  " .. model end
        end
        if session and session.title and session.title ~= "" then
            M.window.native:SetTitle("Project UAI")
        end

        M.window.show()
        return M
    end

    function M.show(id)
        if id then
            M.select(id)
        else
            M.window.show()
        end
    end

    function M.hide()
        if M.window then M.window.hide() end
    end

    function M.toggle()
        if M.window and M.window.visible then M.hide() else M.show() end
    end

    function M.destroy()
        if M.window then M.window.destroy() end
        M.window = nil
        M.tabs = {}
        M.tabById = {}
        M.holders = {}
    end

    return M
end
