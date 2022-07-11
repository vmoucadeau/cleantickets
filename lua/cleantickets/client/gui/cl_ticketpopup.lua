function CleanTickets.GUI.ShowTicket(ticketdata)
    if not CleanTickets.Config.AdminMode then return end
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
                    local contentpanel = ticket:GetChild(5)
                    if player.GetBySteamID64(ticketdata.admin.steamid) == LocalPlayer() then                 
                        local takebut = contentpanel:GetChild(0)
                        

                        local closebut = ticket:GetChild(4)
                        closebut.DoClick = function()
                            ticket:Close()
                            CleanTickets.ClFuncs.SendTable("ct_closeticket", ticketdata)
                        end
                        takebut:Remove()

                        CleanTickets.GUI.TicketsAdminButtons(contentpanel, ticketdata)

                    else
                        if(CleanTickets.Config.HideOnTake) then
                            ticket:Close()
                            table.remove(CleanTickets.ClData.OnScreenTickets, k)
                            return
                        end
                        local takebut = contentpanel:GetChild(0)
                        local tick_x, tick_y = ticket:GetPos()
                        takebut.DoClick = function(self)
                            CleanTickets.GUI.Utils.DisplayChoicePopup({
                                ["x"] = ticket:GetWide() + tick_x + 40,
                                ["y"] = tick_y
                            }, CleanTickets.Lang.NOTIF_WARNING, CleanTickets.Lang.POPUP_TICKET_CLAIMED, CleanTickets.Lang.BTN_CANCEL, CleanTickets.Lang.BTN_CONTINUE, nil, function()
                                takebut:Remove()
                                CleanTickets.GUI.TicketsAdminButtons(contentpanel, ticketdata)
                            end)
                        end
                    end
                    local claimLabel = vgui.Create("DButton", ticket)
                    claimLabel:SetSize(60, 20)
                    claimLabel:SetPos(ticket:GetWide() - claimLabel:GetWide() - 40, 7.999)
                    claimLabel:SetFont("CleanTickets_Font18")
                    claimLabel:SetText(CleanTickets.Lang.TICKETSTATUS_TAKEN)
                    claimLabel:SetTooltip(CleanTickets.Lang.TICKET_TAKENBY .. ticketdata.admin.name)
                    claimLabel:SetColor(CleanTickets.Config.TextColor)
                    claimLabel.Paint = function(s, w, h)
                        draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.TakenColor)
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
    if CleanTickets.Config.MaxTicketsOnScreen <= #CleanTickets.ClData.OnScreenTickets then return end

    

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 151)
    frame:SetVisible(true)
    frame:SetPos(0, CleanTickets.Config.TicketPos.y + (160 * #CleanTickets.ClData.OnScreenTickets))
    frame:SetDraggable(false)
    frame:SetTitle(" ")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    
    local anim = Derma_Anim("EaseInQuad", frame, function(pnl, anim, delta, data)
        pnl:SetPos(inQuad(delta, 0, CleanTickets.Config.TicketPos.x), frame:GetY())
        pnl:SetAlpha(inQuad(delta, 0, 255))
    end)
    -- Animate for 0.5 second
    anim:Start(0.5)
    CleanTickets.ClFuncs.ShowNotif(nil, nil, nil, CleanTickets.Config.TicketSound)
    frame.Think = function(self)
        if anim:Active() then
            anim:Run()
        end
    end
    frame.Paint = function(self, w, h)
        -- Frame box
        draw.RoundedBox(16, 0, 0, w, h, CleanTickets.Config.TicketOutline)	
        draw.RoundedBox(16, 1, 1, w-2, h-2, CleanTickets.Config.TicketBackground)
        
        -- Frame title + line
        local maxnamelen = 17
        local name_to_display = ""
        if string.len(ticketdata.sender.name) > maxnamelen then
            name_to_display = string.sub(ticketdata.sender.name, 1, maxnamelen) .. "..."
        else
            name_to_display = ticketdata.sender.name
        end
        draw.SimpleText(name_to_display, "CleanTickets_Font25", 10, 5, Color(255, 255, 255))
        CleanTickets.GUI.Utils.DrawLine(1, 35, w-1, 35, CleanTickets.Config.TicketOutline)
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

    local TicketContentContainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = frame,
        size = {x=frame:GetWide()-2, y=frame:GetTall()-37},
        pos = {x=1, y=36},
        paint = function() end
    })

    local TakeButton = vgui.Create("DButton", TicketContentContainer)
    TakeButton:SetWide(100)
    TakeButton:SetText("")
    TakeButton:SetColor(Color(255, 255, 255))
    TakeButton:Dock(3)
    TakeButton:DockMargin(0,0,0,0)
    TakeButton.DoClick = function()
        CleanTickets.ClFuncs.SendTable("ct_takerequest", ticketdata)
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

    local ticketcontent = vgui.Create("RichText", TicketContentContainer)
    
    ticketcontent:Dock(1)
    function ticketcontent:PerformLayout()
        self:SetFontInternal("CleanTickets_Font22")
        self:SetFGColor(255, 255, 255, 255)
    end
    ticketcontent:AppendText(CleanTickets.Lang.TICKET_SUBJECT .. ticketdata["subject"] .. "\n")
    ticketcontent:AppendText(CleanTickets.Lang.TICKET_DESCRIPTION .. ticketdata["message"])
    if next(ticketdata["players"]) then
        ticketcontent:AppendText("\n" .. CleanTickets.Lang.TICKET_SELECTEDPLAYER)
        for k, v in pairs(ticketdata["players"]) do
            ticketcontent:AppendText("\n  - " .. v[1])
        end

    end
    if next(ticketdata["attachments"]) then
        ticketcontent:AppendText("\n" .. CleanTickets.Lang.TICKET_ATTACHMENTS)
        for k, v in pairs(ticketdata["attachments"]) do
            ticketcontent:AppendText("\n" .. v)
        end

    end
    ticketcontent.Paint = function(self, w, h)
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
function CleanTickets.GUI.TicketsAdminButtons(contentcontainer, ticketdata)
    local button_list = {
        [1] = {
            ['name'] = CleanTickets.Lang.TICKET_BUT_GOTO,
            ['action'] = function(slf, target)
                local command = string.format("ulx goto $%s", target:SteamID())
                LocalPlayer():ConCommand(command)
                if CleanTickets.Config.TicketNotifs then
                    CleanTickets.ClFuncs.RequestNotif(target, string.format(CleanTickets.Lang.NOTIF_GOTO, LocalPlayer():GetName()), 0, 2, nil)
                end
            end
        },
        [2] = {
            ['name'] = CleanTickets.Lang.TICKET_BUT_TELEPORT,
            ['action'] = function(slf, target)
                local command = string.format("ulx teleport $%s", target:SteamID())
                LocalPlayer():ConCommand(command)
                if CleanTickets.Config.TicketNotifs then
                    CleanTickets.ClFuncs.RequestNotif(target, string.format(CleanTickets.Lang.NOTIF_TELEPORTED, LocalPlayer():GetName()), 0, 2, nil)
                end
            end
        },
        [3] = {
            ['name'] = CleanTickets.Lang.TICKET_BUT_SPECTATE,
            ['action'] = function(slf, target)
                local command = string.format("ulx spectate $%s", target:SteamID())
                LocalPlayer():ConCommand(command)
            end
        },
        [4] = {
            ['name'] = CleanTickets.Lang.TICKET_BUT_FREEZE,
            ['action'] = function(slf, target)
                if slf:GetText() == CleanTickets.Lang.TICKET_BUT_FREEZE then
                    local command = string.format("ulx freeze $%s", target:SteamID())
                    slf:SetText(CleanTickets.Lang.TICKET_BUT_UNFREEZE)
                    LocalPlayer():ConCommand(command)
                    if CleanTickets.Config.TicketNotifs then
                        CleanTickets.ClFuncs.RequestNotif(target, string.format(CleanTickets.Lang.NOTIF_FREEZE, LocalPlayer():GetName()), 0, 2, nil)
                    end
                else
                    local command = string.format("ulx unfreeze $%s", target:SteamID())
                    slf:SetText(CleanTickets.Lang.TICKET_BUT_FREEZE)
                    LocalPlayer():ConCommand(command)
                    if CleanTickets.Config.TicketNotifs then
                        CleanTickets.ClFuncs.RequestNotif(target, string.format(CleanTickets.Lang.NOTIF_UNFREEZE, LocalPlayer():GetName()), 0, 2, nil)
                    end
                end
            end
        },
    }


    local AdminButContainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = contentcontainer,
        size = {x=100, y=0},
        pos = {x=0, y=0},
        paint = function() end,
        dock = RIGHT,
    })

    for k, v in ipairs(button_list) do
        local button = vgui.Create("DButton", AdminButContainer)
        button:SetText(v.name)
        button:SetFont("CleanTickets_Font22")
        button:SetColor(Color(255, 255, 255))
        button:SetTall(23)
        button:Dock(4)
        button:DockMargin(0,0,0,0)
        button.DoClick = function(self)
            local sender = player.GetBySteamID64(ticketdata.sender.steamid)
            if(sender) then
                v.action(self, sender)
            else
                CleanTickets.ClFuncs.ShowNotif(CleanTickets.Lang.NOTIF_PLAYER_NOT_FOUND, 0, 2, CleanTickets.Config.InfoSound)
                CleanTickets.ClFuncs.SendTable("ct_closeticket", ticketdata)
            end
        end
        button.Paint = function(self, w, h)
            if(self:IsHovered()) then
                draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
            end
            
        end
    end
    local MoreButton = vgui.Create("DButton", AdminButContainer)
    MoreButton:SetTall(23)
    MoreButton:Dock(4)
    MoreButton:SetText(CleanTickets.Lang.TICKET_BUT_MORE)
    MoreButton:SetFont("CleanTickets_Font22")
    MoreButton:SetColor(Color(255,255,255))
    MoreButton.DoClick = function()
        local MoreMenu = DermaMenu()
        if next(ticketdata["players"]) then
            local function teleportid(steamid64)
                local target = player.GetBySteamID64(steamid64)
                if target then
                    local command = string.format("ulx teleport $%s", target:SteamID())
                    LocalPlayer():ConCommand(command)
                    if CleanTickets.Config.TicketNotifs then
                        CleanTickets.ClFuncs.RequestNotif(player.GetBySteamID64(steamid), string.format(CleanTickets.Lang.NOTIF_TELEPORTED, LocalPlayer():GetName()), 0, 2, nil)
                    end
                end
            end


            local Child, Parent = MoreMenu:AddSubMenu( CleanTickets.Lang.DMENU_TELEPORT_TARGETS )
            Parent:SetIcon( "icon16/arrow_down.png" )
            Child:AddOption( CleanTickets.Lang.DMENU_TELEPORT_EVERYONE, function()
                for k, v in pairs(ticketdata["players"]) do
                    teleportid(v[2])
                end
            end )
            for k, v in pairs(ticketdata["players"]) do
                Child:AddOption( CleanTickets.Lang.DMENU_TELEPORT .. v[1], function()
                    teleportid(v[2])
                end )
            end
        end
        if next(ticketdata["attachments"]) then
            local Child, Parent = MoreMenu:AddSubMenu( CleanTickets.Lang.DMENU_OPEN_LINK )
            Parent:SetIcon( "icon16/link_go.png" )
            for k, v in pairs(ticketdata["attachments"]) do
                Child:AddOption( CleanTickets.Lang.DMENU_LINK .. k, function()
                    gui.OpenURL(v)
                end )
            end
        end
        local btnWithIcon = MoreMenu:AddOption( CleanTickets.Lang.DMENU_KICK, function()
            local sender = player.GetBySteamID64(ticketdata.sender.steamid)
            if(sender) then
                local command = string.format('ulx kick $%1s "%2s"', sender:SteamID(), CleanTickets.Lang.KICK_MESSAGE)
                LocalPlayer():ConCommand(command)
            else
                CleanTickets.ClFuncs.ShowNotif(CleanTickets.Lang.NOTIF_PLAYER_NOT_FOUND, 0, 2, CleanTickets.Config.InfoSound)
            end 
            CleanTickets.ClFuncs.SendTable("ct_closeticket", ticketdata)
        end )
        btnWithIcon:SetIcon( "icon16/door_out.png" )
        

        MoreMenu:Hide()
        MoreMenu:Open()
    end
    MoreButton.Paint = function(self, w, h)
        if(self:IsHovered()) then
            draw.RoundedBoxEx(48, 0, 0, w, h, CleanTickets.Config.AccentColor, false, false, false, true) 
        end
    end
    
    
end