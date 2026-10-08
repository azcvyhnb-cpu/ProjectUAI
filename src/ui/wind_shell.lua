-- WindUI presentation adapter for Project UAI.
-- IMPORTANT: this is deliberately a compatibility shell. It keeps the complete
-- Project UAI application surface (sidebar, conversations, chat, code, agents,
-- providers, tools, settings, logs, dialogs and session wiring) and changes only
-- the outer window/chrome to WindUI.
return function(env)
    local WindUI = env.require("ui/windui")
    local config = env.require("runtime/config")
    local sessions = env.require("agent/session")

    local M = {
        app = nil,
        window = nil,
        tab = nil,
        canvas = nil,
        selecting = false,
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

    local function showPanel(app, id)
        if not app then return end
        app.show(id)
    end

    local function openUtilityDialog(title, buttons)
        if not M.window or not M.window.native then return end
        return M.window.native:Dialog({
            Title = title,
            Width = 430,
            Buttons = buttons,
        })
    end

    local function buildMoreDialog(app)
        return openUtilityDialog("Project UAI", {
            {
                Title = "Settings",
                Icon = "settings",
                Callback = safe(function()
                    app.showSettingsDialog("general")
                end),
            },
            {
                Title = "Providers & models",
                Icon = "sliders-horizontal",
                Callback = safe(function()
                    app.show("providers")
                end),
            },
            {
                Title = "What's new",
                Icon = "sparkles",
                Callback = safe(function()
                    app.showChangelog()
                end),
            },
            {
                Title = "ProjectUAI",
                Icon = "book-open",
                Callback = safe(function()
                    env.require("ui/project").open()
                end),
            },
            {
                Title = "About this build",
                Icon = "info",
                Callback = safe(function()
                    app.showAbout()
                end),
            },
            {
                Title = "Join Discord",
                Icon = "globe",
                Callback = safe(function()
                    app.joinDiscord()
                end),
            },
            {
                Title = "Donate",
                Icon = "heart",
                Callback = safe(function()
                    app.donate()
                end),
            },
            {
                Title = "Unload UAI",
                Icon = "log-out",
                Variant = "Red",
                Callback = safe(function()
                    local globals = (type(getgenv) == "function") and getgenv() or nil
                    local live = globals and globals.UAI
                    if live and live.destroy then
                        live.destroy()
                    else
                        env.require("runtime/dispose").drain()
                        if M.window then M.window.destroy() end
                    end
                end),
            },
        })
    end

    local function buildChrome(app)
        local w = M.window.native

        -- WindUI owns the visible chrome. The old UAI application chrome is NOT
        -- discarded: app.buildBody() below still creates the complete UAI sidebar,
        -- conversation list and all existing panels inside the WindUI content area.

        w.Topbar:Button({
            Name = "New conversation",
            Icon = "plus",
            LayoutOrder = 1,
            Callback = safe(function()
                app.newConversation()
            end),
        })

        w.Topbar:Button({
            Name = "Search conversations",
            Icon = "search",
            LayoutOrder = 2,
            Callback = safe(function()
                app.showSearch()
            end),
        })

        w.Topbar:Button({
            Name = "Folders",
            Icon = "folder",
            LayoutOrder = 3,
            Callback = safe(function()
                app.manageFolders()
            end),
        })

        w.Topbar:Button({
            Name = "Back",
            Icon = "arrow-left",
            LayoutOrder = 4,
            Callback = safe(function()
                app.back()
            end),
        })

        w.Topbar:Button({
            Name = "Forward",
            Icon = "arrow-right",
            LayoutOrder = 5,
            Callback = safe(function()
                app.forward()
            end),
        })

        w.Topbar:Button({
            Name = "More",
            Icon = "ellipsis",
            LayoutOrder = 6,
            Callback = safe(function()
                buildMoreDialog(app)
            end),
        })

        -- Keep the old keyboard contract too.
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
            SideBarWidth = 180,
            HidePanelBackground = true,
        })

        -- The old UAI sidebar remains the actual application navigation. WindUI's
        -- own tab rail is therefore hidden rather than duplicated.
        pcall(function()
            if w.UIElements and w.UIElements.SideBar then
                w.UIElements.SideBar.Visible = false
            end
        end)

        local wrapper = {
            native = w,
            visible = false,
            maximised = false,
            body = nil,
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

        -- One WindUI tab is intentional. Project UAI already has a complete
        -- navigation system with sidebar + panel routing. Replacing that with a
        -- second navigation system was the reason the previous port lost features.
        local tab = M.window.native:Tab({
            Title = "UAI",
            Icon = "bot",
            ShowTabTitle = false,
        })
        M.tab = tab

        local canvas = tab.UIElements and tab.UIElements.ContainerFrameCanvas
        if not canvas then
            error("WindUI tab content canvas is unavailable")
        end
        M.canvas = canvas
        canvas.ClipsDescendants = true

        local list = tab.UIElements and tab.UIElements.ContainerFrame
        if list then list.Visible = false end

        local holder = Instance.new("Frame")
        holder.Name = "ProjectUAIApp"
        holder.BackgroundTransparency = 1
        holder.BorderSizePixel = 0
        holder.Size = UDim2.fromScale(1, 1)
        holder.Position = UDim2.fromScale(0, 0)
        holder.Parent = canvas

        -- app.layoutNavigation() expects a legacy header object. Give it a zero-size
        -- compatibility frame so it can continue managing the original content layout
        -- without moving WindUI's real topbar.
        local legacyHeader = Instance.new("Frame")
        legacyHeader.Name = "LegacyHeaderAdapter"
        legacyHeader.BackgroundTransparency = 1
        legacyHeader.BorderSizePixel = 0
        legacyHeader.Size = UDim2.fromOffset(0, 0)
        legacyHeader.Parent = holder

        M.window.header = legacyHeader

        -- Bridge the original UAI application into WindUI without rewriting its
        -- feature modules. This preserves the sidebar, conversations, code explorer,
        -- chat composer, context controls, provider/model UI, tools, logs, settings,
        -- permissions, asks, notifications and all existing callbacks.
        app.window = M.window
        M.window.body = holder
        M.window.headerHeight = 0
        app.body = holder
        app.windShell = M

        buildChrome(app)

        -- Build the original UAI body exactly once inside the WindUI content canvas.
        app.buildBody()

        M.window.onShow = function()
            if app.panels and app.panels[app.panel] and app.panels[app.panel].setVisible then
                app.panels[app.panel].setVisible(true)
            end
            if app.syncNav then app.syncNav() end
        end

        M.window.onHide = function()
            if app.panels and app.panels[app.panel] and app.panels[app.panel].setVisible then
                app.panels[app.panel].setVisible(false)
            end
        end

        M.window.show()
        return M
    end

    -- Called by app.showPanel after the panel has been built. It only changes the
    -- WindUI shell state; it never calls app.showPanel, avoiding recursion.
    function M.syncSelection(id)
        if not M.window or not M.tab then return end
        -- There is only one WindUI tab. The actual panel selection remains UAI's
        -- existing sidebar/router, so no feature is duplicated or lost.
        M.activePanel = id
    end

    function M.show(id)
        if not M.window then
            return M.mount(M.app)
        end
        if id and M.app then self = M end
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
        M.tab = nil
        M.canvas = nil
        M.app = nil
    end

    return M
end
