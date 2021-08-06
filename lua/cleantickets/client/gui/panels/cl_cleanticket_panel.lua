CleanTickets.GUI.Panel = {}

function CleanTickets.GUI.Panel.DisplayTab(tab, pnl)
    pnl:Clear()
    tab.panel(pnl)
end

function CleanTickets.GUI.Panel.Main()
    local tabstable = {
        [1] = {
            name = CleanTickets.Lang.PANEL_TAB_SENDTICKET,
            panel = CleanTickets.GUI.Panel.SendTicket
        },
        [2] = {
            name = CleanTickets.Lang.PANEL_TAB_MYTICKETS,
            panel = CleanTickets.GUI.Panel.MyTickets
        }
    }

    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 500)
    local w, h = frame:GetWide(), frame:GetTall()
    frame:SetVisible(true)
    frame:SetPos(ScrW() / 2 - (w / 2), ScrH() / 2 - (h / 2))
    local xf, yf = frame:GetPos()
    frame:SetDraggable(true)
    frame:MakePopup(true)
    frame:SetTitle(" ")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)

    local anim = Derma_Anim("EaseInQuad", frame, function(pnl, anim, delta, data)
        pnl:SetPos(xf, inQuad(delta, yf + 20, -20))
        -- pnl:SetSize(inQuad(delta, 0, w), inQuad(delta, 0, h))
        pnl:SetAlpha(inQuad(delta, 0, 255))
    end)
    -- Animate for 1 second
    anim:Start(0.5)
    frame.Think = function(self)
        if anim:Active() then
            anim:Run()
        end
    end
    frame.Paint = function(self, w, h)
        -- Frame box	

        draw.RoundedBox(15, 0, 0, w, h, CleanTickets.Config.MainFrameBackground)
        -- Frame title + line
        draw.SimpleText("Clean Tickets", "CleanTickets_Font35", 10, 3, Color(255, 255, 255))
        CleanTickets.GUI.Utils.DrawLine(0, 40, w, 40, Color(200, 200, 200, 255))


    end

    local CloseButton = CleanTickets.GUI.Utils.DrawCloseButton({
        parent = frame,
        pos = {x=frame:GetWide()-30, y=10},
        doclick = function()
            local anim = Derma_Anim("EaseInQuad", frame, function(pnl, anim, delta, data)
                pnl:SetPos(xf, inQuad(delta, yf, -20))
                -- pnl:SetSize(inQuad(delta, 0, w), inQuad(delta, 0, h))
                pnl:SetAlpha(inQuad(delta, 255, -255))
            end)
            -- Animate for 0.5 second
            anim:Start(0.5)
            frame.Think = function(self)
                if anim:Active() then
                    anim:Run()
                end
            end
            timer.Simple(0.6, function()
                frame:Close()
            end)
        end
    })

    local tabs = vgui.Create('DIconLayout', frame)
    tabs:Dock(TOP)
    tabs:DockMargin(30,25,10,0)
    tabs:SetSize(0, 40)
    tabs:SetSpaceX(10)
    tabs:SetSpaceY(0)

    local active_panel = vgui.Create('DPanel', frame)
    active_panel:SetSize(frame:GetWide()-20,390)
    active_panel:SetPos(10, 94)
    -- active_panel:DockMargin(10,0,10,10)
    active_panel.Paint = function(self, w, h)
        draw.RoundedBox(15, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor)
    end

    local btn_selection

    for k, v in ipairs(tabstable) do

        local btn = vgui.Create("DButton", tabs)
        btn:SetSize(0, 40)
        btn:SetFont("CleanTickets_Font25")
        btn:SetTextColor(Color(255, 255, 255))
        btn:SetText(v.name)
        btn:SizeToContentsX(20)
        btn.Paint = function(me, w, h)
            draw.RoundedBoxEx(16, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor, true, true, false, false)
            if me:IsHovered() or (btn_selection == v) then -- Or selected
                local empty = 30
                draw.RoundedBox(0, empty / 2, h - 3, w - empty, 3, Color(255, 255, 255, 200))
            end
        end
        btn.DoClick = function()
            btn_selection = v
            CleanTickets.GUI.Panel.DisplayTab(v, active_panel)
        end
        tabs:Add(btn)
    end

    CleanTickets.GUI.Panel.DisplayTab(tabstable[1], active_panel)
    btn_selection = tabstable[1]

    if CleanTickets.ClFuncs.IsAdmin() then

        local admin_btn = CleanTickets.GUI.Utils.DrawButton({
            parent = tabs,
            font = "CleanTickets_Font25",
            text = CleanTickets.Lang.PANEL_TAB_ADMIN,
            size = {x=0, y=40},
            dock = RIGHT,
            margin = {0, 0, 30, 0},
            SizeToContentsX = 20,
            paint = function(s, w, h)
                draw.RoundedBoxEx(16, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor, true, true, false, false)
                if s:IsHovered() or (btn_selection == CleanTickets.Lang.PANEL_TAB_ADMIN) then -- Or selected
                    local empty = 30
                    draw.RoundedBox(0, empty / 2, h - 3, w - empty, 3, CleanTickets.Config.AccentColor)
                end
            end,
            doclick = function()
                btn_selection = CleanTickets.Lang.PANEL_TAB_ADMIN
                active_panel:Clear()
                CleanTickets.GUI.AdminPanel.Main(active_panel)
            end

        })

    end
end