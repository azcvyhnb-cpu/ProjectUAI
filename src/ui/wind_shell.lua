-- WindUI presentation adapter for Project UAI.
-- The UAI feature layer is preserved. WindUI supplies the navigation/chrome and
-- each original UAI panel is mounted into a real WindUI tab.
return function(env)
    local WindUI = env.require("ui/windui")
    local config = env.require("runtime/config")

    local M = {
        app = nil,
        window = nil,
        tabs = {},
        panelHosts = {},
        panelByIndex = {},
        activePanel = "chat",
        selecting = false,
    }

    local PANELS = {
        { id = "conversations", label = "Conversations", icon = "messages-square" },
        { id = "chat", label = "Chat", icon = "message-circle" },
        { id = "cowork", label = "Cowork", icon = "terminal" },
        { id = "code", label = "Code", icon = "code" },
        { id = "agents", label = "Subagents", icon = "users" },
        { id = "providers", label = "Providers", icon = "sliders-horizontal" },
        { id = "tools", label = "Tools", icon = "wrench" },
        { id = "settings", label = "Settings", icon = "settings" },
        { id = "logs", label = "Logs", icon = "file-text" },
    }

    local function safe(callback)
        return function(...)
            local ok, err = pcall(callback, ...)
            if not ok then
                local log = env.require("runtime/log")
                log.error("windui", tostring(err))
            end
        end
    end

    local function buildMoreDialog(app)
        if not M.window or not M.window.native then return end
        return M.window.native:Dialog({
            Title = "Project UAI",
            Width = 430,
            Buttons = {
                { Title = "New conversation", Icon = "plus", Callback = safe(function() app.newConversation() end) },
                { Title = "Search conversations", Icon = "search", Callback = safe(function() app.showSearch() end) },
                { Title = "Conversation folders", Icon = "folder", Callback = safe(function() app.manageFolders() end) },
                { Title = "Settings", Icon = "settings", Callback = safe(function() app.showSettingsDialog("general") end) },
                { Title = "Providers & models", Icon = "sliders-horizontal", Callback = safe(function() app.show("providers") end) },
                { Title = "What's new", Icon = "sparkles", Callback = safe(function() app.showChangelog() end) },
                { Title = "ProjectUAI", Icon = "book-open", Callback = safe(function() env.require("ui/project").open() end) },
                { Title = "About this build", Icon = "info", Callback = safe(function() app.showAbout() end) },
                { Title = "Join Discord", Icon = "globe", Callback = safe(function() app.joinDiscord() end) },
                { Title = "Donate", Icon = "heart", Callback = safe(function() app.donate() end) },
                { Title = "Unload UAI", Icon = "log-out", Variant = "Red", Callback = safe(function()
                    local globals = (type(getgenv) == "function") and getgenv() or nil
                    local live = globals and globals.UAI
                    if live and live.destroy then live.destroy()
                    else
                        env.require("runtime/dispose").drain()
                        if M.window then M.window.destroy() end
                    end
                end) },
            },
        })
    end

    local function buildChrome(app)
        local w = M.window.native

        w.Topbar:Button({
            Name = "New conversation", Icon = "plus", LayoutOrder = 1,
            Callback = safe(function() app.newConversation() end),
        })
        w.Topbar:Button({
            Name = "Search conversations", Icon = "search", LayoutOrder = 2,
            Callback = safe(function() app.showSearch() end),
        })
        w.Topbar:Button({
            Name = "Folders", Icon = "folder", LayoutOrder = 3,
            Callback = safe(function() app.manageFolders() end),
        })
        w.Topbar:Button({
            Name = "Back", Icon = "arrow-left", LayoutOrder = 4,
            Callback = safe(function() app.back() end),
        })
        w.Topbar:Button({
            Name = "Forward", Icon = "arrow-right", LayoutOrder = 5,
            Callback = safe(function() app.forward() end),
        })
        w.Topbar:Button({
            Name = "More", Icon = "ellipsis", LayoutOrder = 6,
            Callback = safe(function() buildMoreDialog(app) end),
        })
        w:SetToggleKey(Enum.KeyCode.RightShift)
    end

    local function makeWindow()
        local w = WindUI:CreateWindow({
            Title = "Project UAI",
            Author = "Universal AI Agent",
            Icon = "bot",
            Folder = "ProjectUAI",
            Theme = config.get("ui.theme", "Dark") == "Light" and "Light" or "Dark",
            NewElements = true,
            HideSearchBar = true,
            AutoScale = true,
            Resizable = true,
            Size = UDim2.fromOffset(900, 620),
            MinSize = Vector2.new(520, 380),
            MaxSize = Vector2.new(1280, 900),
            SideBarWidth = 190,
            HidePanelBackground = true,
        })

        local wrapper = {
            native = w,
            visible = false,
            maximised = false,
            body = nil,
            root = w.ScreenGui or (w.UIElements and w.UIElements.Main and w.UIElements.Main.Main),
            header = w.UIElements and w.UIElements.Main and w.UIElements.Main.Main
                and w.UIElements.Main.Main.Topbar or nil,
            headerHeight = 0,
        }

        function wrapper.show()
            if wrapper.native and not wrapper.native.Destroyed then
                wrapper.native:Open()
                wrapper.visible = true
                if wrapper.onShow then pcall(wrapper.onShow) end
            end
        end
        function wrapper.hide()
            if wrapper.native and not wrapper.native.Destroyed then
                wrapper.native:Close()
                wrapper.visible = false
                if wrapper.onHide then pcall(wrapper.onHide) end
            end
        end
        function wrapper.toggleMaximised()
            if wrapper.native and not wrapper.native.Destroyed then
                wrapper.native:ToggleFullscreen()
                wrapper.maximised = not wrapper.maximised
            end
        end
        function wrapper.setMinWidth(value)
            if wrapper.native and wrapper.native.UIElements and wrapper.native.UIElements.Main then
                local size = wrapper.native.UIElements.Main.Size
                wrapper.native.UIElements.Main.Size = UDim2.new(
                    size.X.Scale, math.max(size.X.Offset, value or 0),
                    size.Y.Scale, size.Y.Offset
                )
            end
        end
        function wrapper.destroy()
            if wrapper.native and not wrapper.native.Destroyed then wrapper.native:Destroy() end
            wrapper.visible = false
        end
        return wrapper
    end

    local function buildTabs(app)
        local w = M.window.native
        for _, entry in ipairs(PANELS) do
            local tab = w:Tab({
                Title = entry.label,
                Icon = entry.icon,
                ShowTabTitle = false,
            })
            M.tabs[entry.id] = tab
            M.panelByIndex[tab.Index] = entry.id

            local canvas = tab.UIElements and tab.UIElements.ContainerFrameCanvas
            if not canvas then
                error("WindUI tab content canvas is unavailable for " .. entry.id)
            end
            canvas.Name = "UAI_" .. entry.id
            canvas.ClipsDescendants = true
            M.panelHosts[entry.id] = canvas
        end

        -- The conversation/history surface is the one legacy UI surface that
        -- cannot be reduced to a panel builder: it owns history rows, folders,
        -- profile actions and thread management. Mount it as a real WindUI tab
        -- instead of throwing those capabilities away.
        local conversationHost = M.panelHosts.conversations
        if conversationHost and M.app then
            M.app.sidebar = env.require("ui/sidebar").new(conversationHost, M.app)
        end

        if M.window.native.TabModule then
            M.window.native.TabModule:OnChange(function(index)
                local id = M.panelByIndex[index]
                if not id or M.selecting then return end
                M.activePanel = id
                if id == "conversations" then
                    return
                end
                if M.app then
                    M.app.showPanel(id)
                end
            end)
        end
    end

    function M.mount(app)
        if M.window then return M end
        M.app = app
        M.window = makeWindow()
        buildChrome(app)
        buildTabs(app)

        app.window = M.window
        app.windShell = M
        M.window.body = M.panelHosts[app.panel] or M.panelHosts.chat
        M.window.headerHeight = 0

        -- Build every existing UAI feature surface lazily into its WindUI tab.
        -- No legacy sidebar/header is created in this mode.
        app.buildBody()

        M.window.onShow = function()
            if M.app and M.app.syncNav then M.app.syncNav() end
        end
        M.window.onHide = function()
            -- Preserve UAI's focus/lifecycle contract when the WindUI window closes.
            pcall(function()
                local field = env.uis:GetFocusedTextBox()
                if field and M.window.root and field:IsDescendantOf(M.window.root) then
                    field:ReleaseFocus()
                end
            end)
        end
        M.window.show()
        return M
    end

    function M.getPanelHost(id)
        return M.panelHosts[id] or M.panelHosts.chat
    end

    function M.selectPanel(id)
        if not M.window or not M.tabs[id] then return end
        M.activePanel = id
        M.selecting = true
        local ok, err = pcall(function()
            M.tabs[id]:Select()
        end)
        if not ok then
            pcall(function() M.window.native:SelectTab(M.tabs[id].Index) end)
        end
        M.selecting = false
        M.window.body = M.panelHosts[id]
    end

    function M.syncSelection(id)
        if not id then return end
        M.activePanel = id
        if M.tabs[id] then M.selectPanel(id) end
    end

    function M.toggleSidebar()
        if not M.window or not M.window.native then return end
        local side = M.window.native.UIElements and M.window.native.UIElements.SideBar
        if side then
            side.Visible = not side.Visible
        end
    end

    function M.show(id)
        if not M.window then M.mount(M.app) end
        if id and M.tabs[id] then M.selectPanel(id) end
        M.window.show()
        return M
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
        M.panelHosts = {}
        M.panelByIndex = {}
        M.app = nil
    end

    return M
end