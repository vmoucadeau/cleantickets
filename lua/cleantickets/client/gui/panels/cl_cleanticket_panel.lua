CleanTickets.GUI.Panel = {}

function CleanTickets.GUI.Panel.Main()
    local tabstable = {
        [1] = {
            name = "Send a ticket",
            panel = CleanTickets.GUI.Panel.SendTicket
        },
        [2] = {
            name = "My tickets",
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
        draw.SimpleText("Clean Tickets", "ct_TitleFont", 10, 3, Color(255, 255, 255))
        CleanTickets.GUI.Utils.DrawLine(0, 40, w, 40, Color(200, 200, 200, 255))


    end

    local CloseButton = vgui.Create("DButton", frame)
    CloseButton:SetPos(frame:GetWide() - 30, 10)
    CloseButton:SetSize(20, 20)
    CloseButton:SetText("")
    CloseButton:SetTooltip("Close")
    CloseButton.DoClick = function()
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
    CloseButton.Paint = function(s, w, h)
        draw.RoundedBox(100, 0, 0, w, h, CleanTickets.Config.CloseButtonColor)

    end

    local tabs = vgui.Create('DPanelList', frame)
    tabs:SetPos(40, 60)
    local tx, ty = tabs:GetPos()
    tabs:SetSize(frame:GetWide(), 45)
    tabs:EnableHorizontal(true)
    tabs:SetStretchHorizontally(true)
    tabs:SetSpacing(10)

    local active_panel = vgui.Create('DPanel', frame)
    active_panel:SetPos(10, ty + tabs:GetTall() - 5)
    local xp, yp = active_panel:GetPos()
    active_panel:SetSize(frame:GetWide() - 20, frame:GetTall() - yp - 10)
    active_panel.Paint = function(self, w, h)
        draw.RoundedBox(15, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor)
    end

    for k, v in ipairs(tabstable) do

        local btn = vgui.Create("DButton", frame)
        surface.SetFont("ct_TextFont")
        local w, h = surface.GetTextSize(v.name)
        btn:SetSize(w + 20, 40)
        btn:SetFont("ct_TextFont")
        btn:SetTextColor(Color(255, 255, 255))
        btn:SetText(v.name)
        btn:SetPos(ScrW() * 0.4, 10)
        btn.Paint = function(me, w, h)
            draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor, true, true, false, false)
            if me:IsHovered() or (btn_selection == v) then -- Or selected
                local empty = 30
                draw.RoundedBox(0, empty / 2, h - 3, w - empty, 3, Color(255, 255, 255, 200))
            end
        end
        btn.DoClick = function()
            btn_selection = v
            DisplayTabPnl(v, active_panel)
        end
        tabs:AddItem(btn)
        if (k == 1) then
            DisplayTabPnl(v, active_panel)
            btn_selection = v
        end
    end

    if CleanTickets.ClData.ServerTickets then
        local admin_btn = vgui.Create("DButton", frame)
        surface.SetFont("ct_TextFont")
        local w, h = surface.GetTextSize("Admin Panel")
        admin_btn:SetSize(w + 20, 40)
        admin_btn:SetFont("ct_TextFont")
        admin_btn:SetTextColor(Color(255, 255, 255))
        admin_btn:SetText("Admin Panel")
        admin_btn:SetPos(active_panel:GetWide() - w - 40, 60)
        admin_btn.Paint = function(me, w, h)
            draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor, true, true, false, false)
            if me:IsHovered() or (btn_selection == "Admin Panel") then -- Or selected
                local empty = 30
                draw.RoundedBox(0, empty / 2, h - 3, w - empty, 3, CleanTickets.Config.AccentColor)
            end
        end
        admin_btn.DoClick = function()
            btn_selection = "Admin Panel"
            active_panel:Clear()
            CleanTickets.GUI.AdminPanel.Main(active_panel)
        end

    end
end

function DisplayTabPnl(item, pnl)
    pnl:Clear()
    return item.panel(pnl)
end

