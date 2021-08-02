

function CleanTickets.GUI.ShowTicket(ticketdata)
    if ticketdata.isupdate then
        for k, v in pairs(CleanTickets.ClData.OnScreenTickets) do
            if v[2].id == ticketdata.id then
                local ticket = v[1]

                if ticketdata.status == "Closed" then
                    ticket:Close()
                    table.remove(CleanTickets.ClData.OnScreenTickets, k)
                    return
                end

                

                
                if ticketdata.status == "Taken" then
                    if player.GetBySteamID64(ticketdata.admin.steamid) == LocalPlayer() then

                        local takebut = ticket:GetChild(5)
                        takebut:Remove()

                        CleanTickets.GUI.TicketsAdminButtons(ticket, ticketdata)

                    end
                    local claimLabel = vgui.Create("DButton", ticket)
                    claimLabel:SetSize(60, 20)
                    claimLabel:SetPos(ticket:GetWide() - claimLabel:GetWide() - 40, 7.999)
                    claimLabel:SetFont("CleanTickets_Font18")
                    claimLabel:SetText(CleanTickets.Lang.TICKETSTATUS_TAKEN)
                    claimLabel:SetTooltip(CleanTickets.Lang.TICKET_TAKENBY .. ticketdata.admin.name)
                    claimLabel:SetColor(Color(255, 255, 255))
                    claimLabel.Paint = function(s, w, h)
                        draw.RoundedBox(8, 0, 0, w, h, Color(39, 174, 96))
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
        draw.SimpleText(name_to_display, "CleanTickets_Font25", 10, 5, Color(255, 255, 255))
        CleanTickets.GUI.Utils.DrawLine(0, 35, w, 35, Color(255, 255, 255, 255))
    end

    local CloseButton = vgui.Create("DButton", frame)
    CloseButton:SetPos(frame:GetWide() - 30, 7)
    CloseButton:SetSize(20, 20)
    CloseButton:SetText("")
    CloseButton:SetTooltip(CleanTickets.Lang.BTN_CLOSE)
    CloseButton.DoClick = function()
        frame:Close()
    end
    CloseButton.Paint = function(s, w, h)
        draw.RoundedBox(100, 0, 0, w, h, CleanTickets.Config.CloseButtonColor)
    end

    local TakeButton = vgui.Create("DButton", frame)
    TakeButton:SetPos(frame:GetWide() - 100, 36)
    TakeButton:SetSize(100, frame:GetTall() - 36)
    TakeButton:SetText("")
    TakeButton:SetColor(Color(255, 255, 255))
    TakeButton.DoClick = function()
        if ticketdata.status == "Taken" then
            CleanTickets.GUI.Utils.DisplayChoicePopup({
                ["x"] = frame:GetWide() + x + 40,
                ["y"] = y
            }, CleanTickets.Lang.NOTIF_WARNING, CleanTickets.Lang.NOTIF_TICKET_CLAIMED, CleanTickets.Lang.BTN_CANCEL, CleanTickets.Lang.BTN_CONTINUE, nil, function()
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
        surface.SetFont("CleanTickets_Font25")
        local w1, h1 = surface.GetTextSize("Take")
        draw.SimpleText("Take", "CleanTickets_Font25", w / 2, h / 2 - h1 / 2 - 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER)
        local w2, h2 = surface.GetTextSize("Ticket")
        draw.SimpleText("Ticket", "CleanTickets_Font25", w / 2, h / 2 + h2 / 2 - 5, Color(255, 255, 255, 255),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local ticketcontent = vgui.Create("RichText", frame)
    ticketcontent:SetPos(0, 36)
    local wc, hc = ticketcontent:GetPos()
    ticketcontent:SetSize(frame:GetWide() - 100, frame:GetTall() - hc)
    function ticketcontent:PerformLayout()
        self:SetFontInternal("CleanTickets_Font22")
        self:SetFGColor(255, 255, 255, 255)
    end
    ticketcontent:AppendText(CleanTickets.Lang.TICKET_SUBJECT .. ticketdata["subject"] .. "\n")
    ticketcontent:AppendText(CleanTickets.Lang.TICKET_DESCRIPTION .. ticketdata["message"])
    if next(ticketdata["players"]) then
        ticketcontent:AppendText("\n" .. CleanTickets.Lang.TICKET_SELECTEDPLAYER .. "\n")
        for k, v in pairs(ticketdata["players"]) do
            ticketcontent:AppendText("   - " .. v[1] .. "\n")
        end

    end
    if next(ticketdata["attachments"]) then
        ticketcontent:AppendText("\n" .. CleanTickets.Lang.TICKET_ATTACHMENTS .. "\n")
        for k, v in pairs(ticketdata["attachments"]) do
            ticketcontent:AppendText("   - " .. v .. "\n")
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
    GotoButton:SetText(CleanTickets.Lang.TICKET_BUT_GOTO)
    GotoButton:SetFont("CleanTickets_Font22")
    GotoButton:SetColor(Color(255,255,255))
    GotoButton.DoClick = function()
        local command = [["ulx goto $]]..sender:SteamID()..[["]]
        LocalPlayer():ConCommand(command)
        if CleanTickets.Config.TicketNotifs then
            CT_RequestNotif(sender, string.format(CleanTickets.Lang.NOTIF_GOTO, LocalPlayer():GetName()), 0, 2, nil)
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
    TpButton:SetText(CleanTickets.Lang.TICKET_BUT_TELEPORT)
    TpButton:SetFont("CleanTickets_Font22")
    TpButton:SetColor(Color(255,255,255))
    TpButton.DoClick = function()
        local command = [["ulx teleport $]]..sender:SteamID()..[["]]
        LocalPlayer():ConCommand(command)
        if CleanTickets.Config.TicketNotifs then
            CT_RequestNotif(sender, string.format(CleanTickets.Lang.NOTIF_TELEPORTED, LocalPlayer():GetName()), 0, 2, nil)
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
    SpecButton:SetText(CleanTickets.Lang.TICKET_BUT_SPECTATE)
    SpecButton:SetFont("CleanTickets_Font22")
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
    FreezeButton:SetText(CleanTickets.Lang.TICKET_BUT_FREEZE)
    FreezeButton:SetFont("CleanTickets_Font22")
    FreezeButton:SetColor(Color(255,255,255))
    FreezeButton.DoClick = function(self)
        if self:GetText() == CleanTickets.Lang.TICKET_BUT_FREEZE then
            local command = [["ulx freeze $]]..sender:SteamID()..[["]]
            self:SetText(CleanTickets.Lang.TICKET_BUT_UNFREEZE)
            LocalPlayer():ConCommand(command)
            if CleanTickets.Config.TicketNotifs then
                CT_RequestNotif(sender, string.format(CleanTickets.Lang.NOTIF_FREEZE, LocalPlayer():GetName()), 0, 2, nil)
            end
        else
            local command = [["ulx unfreeze $]]..sender:SteamID()..[["]]
            self:SetText(CleanTickets.Lang.TICKET_BUT_FREEZE)
            LocalPlayer():ConCommand(command)
            if CleanTickets.Config.TicketNotifs then
                CT_RequestNotif(sender, string.format(CleanTickets.Lang.NOTIF_UNFREEZE, LocalPlayer():GetName()), 0, 2, nil)
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
    MoreButton:SetText(CleanTickets.Lang.TICKET_BUT_MORE)
    MoreButton:SetFont("CleanTickets_Font22")
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