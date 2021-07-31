

function CleanTickets.GUI.ShowTicket(ticketdata)
    if ticketdata.isupdate then
        for k, v in pairs(CleanTickets.ClData.OnScreenTickets) do
            if v[2].id == ticketdata.id then
                if ticketdata.status == "Closed" then
                    ticket:Close()
                    table.remove(CleanTickets.ClData.OnScreenTickets, k)
                    return
                end

                local ticket = v[1]

                
                if ticketdata.status == "Taken" then
                    if player.GetBySteamID64(ticketdata.admin.steamid) == LocalPlayer() then

                        local takebut = ticket:GetChild(5)
                        takebut:Remove()

                        CleanTickets.GUI.TicketsAdminButtons(ticket, ticketdata)

                    end
                    local claimLabel = vgui.Create("DButton", ticket)
                    claimLabel:SetSize(60, 20)
                    claimLabel:SetPos(ticket:GetWide() - claimLabel:GetWide() - 40, 7.999)
                    claimLabel:SetFont("ct_TinyFont")
                    claimLabel:SetText("Taken")
                    claimLabel:SetTooltip("Admin: " .. ticketdata.admin.name)
                    claimLabel:SetColor(Color(255, 255, 255))
                    claimLabel.Paint = function(s, w, h)
                        draw.RoundedBox(7, 0, 0, w, h, Color(39, 174, 96))
                    end
                end

                break
            end
        end

        return
    end

    if CleanTickets.Config.MaxTicketsOnScreen == nil then
        CleanTickets.Config.MaxTicketsOnScreen = (ScrH() - ScrH() % (CleanTickets.Config.TicketPos.y + 160) ) / (CleanTickets.Config.TicketPos.y + 160)
    end
    print(math.floor(4.2))
    if CleanTickets.Config.MaxTicketsOnScreen <= #CleanTickets.ClData.OnScreenTickets then return end

    local sender = player.GetBySteamID64(ticketdata.sender.steamid)

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 151)
    frame:SetVisible(true)
    frame:SetPos(0, CleanTickets.Config.TicketPos.y + (160 * #CleanTickets.ClData.OnScreenTickets))
    frame:SetDraggable(false)
    frame:SetTitle(" ")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    local x, y = frame:GetPos()
    local anim = Derma_Anim("EaseInQuad", frame, function(pnl, anim, delta, data)
        pnl:SetPos(inQuad(delta, 0, CleanTickets.Config.TicketPos.x), y)
        pnl:SetAlpha(inQuad(delta, 0, 255))
    end)
    -- Animate for 0.5 second
    anim:Start(0.5)
    CT_ShowNotif(nil, nil, nil, CleanTickets.Config.TicketSound)
    frame.Think = function(self)
        if anim:Active() then
            anim:Run()
        end
    end
    frame.Paint = function(self, w, h)
        -- Frame box	
        draw.RoundedBox(15, 0, 0, w, h, CleanTickets.Config.TicketBackground)
        -- Frame title + line
        local maxnamelen = 17
        local name_to_display = ""
        if string.len(sender:GetName()) > maxnamelen then
            name_to_display = string.sub(sender:GetName(), 1, maxnamelen) .. "..."
        else
            name_to_display = sender:GetName()
        end
        draw.SimpleText(name_to_display, "ct_TextFont", 10, 5, Color(255, 255, 255))
        CleanTickets.GUI.Utils.DrawLine(0, 35, w, 35, Color(255, 255, 255, 255))
    end

    local CloseButton = vgui.Create("DButton", frame)
    CloseButton:SetPos(frame:GetWide() - 30, 7)
    CloseButton:SetSize(20, 20)
    CloseButton:SetText("")
    CloseButton:SetTooltip(CleanTickets.Lang.Close)
    CloseButton.DoClick = function()
        if ticketdata.status == "Taken" and v.admin then
            if v.admin.steamid == LocalPlayer():SteamID64() then
                CT_SendTable("ct_closeticket", ticketdata)
            end
        end
        frame:Close()
    end
    CloseButton.Paint = function(s, w, h)
        draw.RoundedBox(100, 0, 0, w, h, CleanTickets.Config.CloseButtonColor)
        if(s:IsHovered()) then
            draw.SimpleText("x", "CleanTickets_Font24", 5, 2, Color(255,255,255,255))
        end
    end

    local TakeButton = vgui.Create("DButton", frame)
    TakeButton:SetPos(frame:GetWide() - 100, 36)
    TakeButton:SetSize(100, frame:GetTall() - 36)
    TakeButton:SetText("")
    TakeButton:SetColor(Color(255, 255, 255))
    TakeButton.DoClick = function()
        if ticketdata.status == "Taken" then
            CT_ShowNotif("Ticket already claimed", 1, 2, nil)
            CleanTickets.GUI.Utils.DisplayChoicePopup({
                ["x"] = frame:GetWide() + x + 40,
                ["y"] = y
            }, "Warning", "Someone has already taken this ticket :/", "Cancel", "Continue", nil, function()
                CleanTickets.GUI.TicketsAdminButtons(frame, ticketdata)
            end)
        else
            CT_SendTable("ct_takerequest", ticketdata)
        end
    end
    TakeButton.Paint = function(s, w, h)
        if s:IsHovered() then
            draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor, false, false, false, true)
        else
            draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.AccentColor, false, false, false, true)
        end
        surface.SetFont("ct_TextFont")
        local w1, h1 = surface.GetTextSize("Take")
        draw.SimpleText("Take", "ct_TextFont", w / 2, h / 2 - h1 / 2 - 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER)
        local w2, h2 = surface.GetTextSize("Ticket")
        draw.SimpleText("Ticket", "ct_TextFont", w / 2, h / 2 + h2 / 2 - 5, Color(255, 255, 255, 255),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local ticketcontent = vgui.Create("RichText", frame)
    ticketcontent:SetPos(0, 36)
    local wc, hc = ticketcontent:GetPos()
    ticketcontent:SetSize(frame:GetWide() - 100, frame:GetTall() - hc)
    function ticketcontent:PerformLayout()
        self:SetFontInternal("ct_MedFont")
        self:SetFGColor(255, 255, 255, 255)
    end
    ticketcontent:AppendText("Reason: " .. ticketdata["subject"] .. "\nMessage: ")
    ticketcontent:AppendText(ticketdata["message"])
    if next(ticketdata["players"]) then
        ticketcontent:AppendText("\nSelected players:\n")
        for k, v in pairs(ticketdata["players"]) do
            ticketcontent:AppendText("   - " .. v[1] .. "\n")
        end

    end
    ticketcontent.Paint = function(self, w, h)
        draw.RoundedBoxEx(15, 0, 0, w, h, Color(0, 0, 0, 0), false, false, true, false)
    end

    function frame:OnRemove()

        for k, v in pairs(CleanTickets.ClData.OnScreenTickets) do
            if v[1] == frame then
                table.remove(CleanTickets.ClData.OnScreenTickets, k)
                break
            end
        end

        for k, v in pairs(CleanTickets.ClData.OnScreenTickets) do
            v[1]:MoveTo(CleanTickets.Config.TicketPos.x, CleanTickets.Config.TicketPos.y + (160 * (k - 1)), 0.5, 0, 1, function()
            end)
        end
    end

    table.insert(CleanTickets.ClData.OnScreenTickets, {frame, ticketdata})
end

-- Admin buttons
function CleanTickets.GUI.TicketsAdminButtons(ticket, ticketdata)
    local sender = player.GetBySteamID64(ticketdata.sender.steamid)
    local GotoButton = vgui.Create("DButton", ticket)
    GotoButton:SetPos(ticket:GetWide()-100, 36)
    GotoButton:SetSize(100, 23)
    GotoButton:SetText("Goto")
    GotoButton:SetFont("ct_MedFont")
    GotoButton:SetColor(Color(255,255,255))
    GotoButton.DoClick = function()
        local command = [["ulx goto $]]..sender:SteamID()..[["]]
        LocalPlayer():ConCommand(command)
        if CleanTickets.Config.TicketNotifs then
            CT_RequestNotif(sender, LocalPlayer():GetName() .. " is teleporting to you", 0, 2, nil)
        end
    end
    GotoButton.Paint = function(self, w, h)
        if(self:IsHovered()) then
            draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
        end
    end

    local TpButton = vgui.Create("DButton", ticket)
    TpButton:SetPos(ticket:GetWide()-100, 59)
    TpButton:SetSize(100, 23)
    TpButton:SetText("Teleport")
    TpButton:SetFont("ct_MedFont")
    TpButton:SetColor(Color(255,255,255))
    TpButton.DoClick = function()
        local command = [["ulx teleport $]]..sender:SteamID()..[["]]
        LocalPlayer():ConCommand(command)
        if CleanTickets.Config.TicketNotifs then
            CT_RequestNotif(sender, "You have been teleported by " .. LocalPlayer():GetName(), 0, 2, nil)
        end
    end
    TpButton.Paint = function(self, w, h)
        if(self:IsHovered()) then
            draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
        end
    end
    local SpecButton = vgui.Create("DButton", ticket)
    SpecButton:SetPos(ticket:GetWide()-100, 82)
    SpecButton:SetSize(100, 23)
    SpecButton:SetText("Spectate")
    SpecButton:SetFont("ct_MedFont")
    SpecButton:SetColor(Color(255,255,255))
    SpecButton.DoClick = function()
        local command = [["ulx spectate $]]..sender:SteamID()..[["]]
        LocalPlayer():ConCommand(command)
    end
    SpecButton.Paint = function(self, w, h)
        if(self:IsHovered()) then
            draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
        end
    end
    
    local FreezeButton = vgui.Create("DButton", ticket)
    FreezeButton:SetPos(ticket:GetWide()-100, 105)
    FreezeButton:SetSize(100, 23)
    FreezeButton:SetText("Freeze")
    FreezeButton:SetFont("ct_MedFont")
    FreezeButton:SetColor(Color(255,255,255))
    FreezeButton.DoClick = function(self)
        if self:GetText() == "Freeze" then
            local command = [["ulx freeze $]]..sender:SteamID()..[["]]
            self:SetText("Unfreeze")
            LocalPlayer():ConCommand(command)
            if CleanTickets.Config.TicketNotifs then
                CT_RequestNotif(sender, "You have been frozen by " .. LocalPlayer():GetName(), 0, 2, nil)
            end
        else
            local command = [["ulx unfreeze $]]..sender:SteamID()..[["]]
            self:SetText("Freeze")
            LocalPlayer():ConCommand(command)
            if CleanTickets.Config.TicketNotifs then
                CT_RequestNotif(sender, "You have been unfrozen by " .. LocalPlayer():GetName(), 0, 2, nil)
            end
        end
        
    end
    FreezeButton.Paint = function(self, w, h)
        if(self:IsHovered()) then
            draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
        end
    end
    local MoreButton = vgui.Create("DButton", ticket)
    MoreButton:SetPos(ticket:GetWide()-100, 128)
    MoreButton:SetSize(100, 23)
    MoreButton:SetText("More")
    MoreButton:SetFont("ct_MedFont")
    MoreButton:SetColor(Color(255,255,255))
    MoreButton.DoClick = function()
        -- frame:Close()
    end
    MoreButton.Paint = function(self, w, h)
        if(self:IsHovered()) then
            draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.AccentColor, false, false, false, true) 
        else
            draw.RoundedBoxEx(15, 0, 0, w, h, Color(0,0,0,0), false, false, false, true) 
        end
    end
end