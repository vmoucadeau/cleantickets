CleanTickets.GUI.AdminPanel = {}

function CleanTickets.GUI.AdminPanel.Main(active_panel)
    local admintabstable = {
        [1] = {
            name = CleanTickets.Lang.PANEL_ADMIN_ALLTICKETS, 
            panel = CleanTickets.GUI.AdminPanel.AllTickets
        },
        [2] = {
            name = CleanTickets.Lang.PANEL_ADMIN_STATS, 
            panel = CleanTickets.GUI.AdminPanel.Statistics
        }

    }
    
    local AdminPanel = vgui.Create("DPanel", active_panel)
    AdminPanel:SetSize(active_panel:GetWide(), active_panel:GetTall())
    AdminPanel:SetPos(0, 0)
    AdminPanel.Paint = function() end

    local tabsbarsize = 0

    local admintabs = vgui.Create('DPanelList', AdminPanel)
    admintabs:SetPos(0, 10)
    admintabs:EnableHorizontal(true)
    admintabs:SetStretchHorizontally(true)
    admintabs:SetSpacing(0)

    

    local ActiveAdminPanel = vgui.Create("DPanel", AdminPanel)
    ActiveAdminPanel:SetSize(AdminPanel:GetWide(), AdminPanel:GetTall()-45)
    ActiveAdminPanel:SetPos(0, 40)
    ActiveAdminPanel.Paint = function() end

    local admin_selection
    

    for k, v in ipairs(admintabstable) do

        local btn = vgui.Create("DButton", AdminPanel)
        surface.SetFont("CleanTickets_Font22")
        local w, h = surface.GetTextSize(v.name)
        tabsbarsize = tabsbarsize + w + 28
        btn:SetSize(w + 28, 30)
        btn:SetFont("CleanTickets_Font22")
        btn:SetTextColor(Color(255, 255, 255))
        btn:SetText(v.name)
        btn:SetPos(ScrW() * 0.4, 10)
        btn.Paint = function(me, w, h)
            local color
            if me:IsHovered() or (admin_selection == v) then color = CleanTickets.Config.AccentColor else color = CleanTickets.Config.MainFrameBackground end -- Or selected
            if (k==1) then
                draw.RoundedBoxEx(16, 0, 0, w, h, color, true, false, true, false)
            elseif (k==#admintabstable) then
                draw.RoundedBoxEx(16, 0, 0, w, h, color, false, true, false, true)
            else
                draw.RoundedBoxEx(0, 0, 0, w, h, color, false, true, false, true)
            end
        end
        
        btn.DoClick = function()
            admin_selection = v
            DisplayTabPnl(v, ActiveAdminPanel)
        end
        admintabs:AddItem(btn)
        if (k == 1) then
            admin_selection = v
            DisplayTabPnl(v, ActiveAdminPanel)
        end
    end
    admintabs:SetSize(tabsbarsize, 40)
    admintabs:SetPos(AdminPanel:GetWide()/2 - tabsbarsize / 2, 10)
        
end

function CleanTickets.GUI.AdminPanel.AllTickets(parent)
    local search_filters = {
        sender_info = false,
        subject = true,
        status = true
    }
    TicketsButtons = function(item_data, item_panel)
        if item_data.status ~= "Closed" then
            local bt_CloseTicket = vgui.Create("DButton", item_panel)
            bt_CloseTicket:SetPos(item_panel:GetWide() - 100, 128)
            bt_CloseTicket:SetSize(100, 23)
            bt_CloseTicket:SetText(CleanTickets.Lang.TICKET_BUT_CLOSE)
            bt_CloseTicket:SetFont("CleanTickets_Font22")
            bt_CloseTicket:SetColor(Color(255, 255, 255))
            bt_CloseTicket.DoClick = function()
                CleanTickets.ClFuncs.SendTable("ct_closeticket", item_data)
                CleanTickets.ClFuncs.GetTickets()
                item_panel:Remove()
            end
            bt_CloseTicket.Paint = function(self, w, h)
                if (self:IsHovered()) then
                    draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.AccentColor, false, false, false, true)
                else
                    draw.RoundedBoxEx(15, 0, 0, w, h, Color(0, 0, 0, 0), false, false, false, true)
                end
            end
        end
    end

    return CleanTickets.GUI.Utils.TicketsListPanel(CleanTickets.ClData.ServerTickets, parent, TicketsButtons, CleanTickets.Lang.SERVER_NO_TICKET)

end

function CleanTickets.GUI.AdminPanel.Statistics(parent)
    local ServerStats = CleanTickets.GUI.Utils.DrawContainer({
        parent = parent,
        color = CleanTickets.Config.MainFrameBackground,
        size = {x = parent:GetWide()-20, y = parent:GetTall()/2 - 12.5},
        pos = {x = 10, y = 10},
        title = CleanTickets.Lang.PANEL_ADMIN_SERVERSTATS,
    })

    local ServerStats_list = vgui.Create("DHorizontalScroller", ServerStats)
    ServerStats_list:SetPos( 12, 30 )
    ServerStats_list:SetSize( ServerStats:GetWide() - 20, ServerStats:GetTall() - 45 )
	-- ServerStats_list:EnableHorizontal( true )
	-- ServerStats_list:EnableVerticalScrollbar(false)
    -- ServerStats_list:SetSpacing( 10 )
    ServerStats_list:SetOverlap(-10)

    function ServerStats_list.btnLeft:Paint( w, h )
        draw.RoundedBox( 6, 0, 0, w, h, Color( 200, 100, 0 ) )
        draw.SimpleText("<", "CleanTickets_Font24", w/2-1, h/2-3.25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function ServerStats_list.btnRight:Paint( w, h )
        draw.RoundedBox( 6, 0, 0, w, h, Color( 200, 100, 0 ) )
        draw.SimpleText(">", "CleanTickets_Font24", w/2-1, h/2-3.25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local taken_tickets = 0
    local open_tickets = 0

    for k, v in pairs(CleanTickets.ClData.ServerTickets) do
        if v.status == "Open" then
            open_tickets = open_tickets + 1
        end
        if v.status == "Taken" then
            taken_tickets = taken_tickets + 1
        end
    end


    local ServerStats_elements = {
        [1] = {
            name = CleanTickets.Lang.PANEL_ADMIN_CONNECTEDPLAYERS,
            data = {"number", player.GetCount()} 
        },
        [2] = {
            name = CleanTickets.Lang.PANEL_ADMIN_CONNECTEDADMINS,
            data = {"function", function() 
                local admins = 0
                for k, v in pairs(player.GetHumans()) do
                    if(CleanTickets.ClFuncs.IsAdmin(v)) then
                        admins = admins + 1
                    end
                end
                return admins
            end} 
        },
        [3] = {
            name = CleanTickets.Lang.PANEL_ADMIN_OPENTICKETS,
            data = {"number", open_tickets} 
        },
        [4] = {
            name = CleanTickets.Lang.PANEL_ADMIN_TAKENTICKETS,
            data = {"number", taken_tickets} 
        }

    }

    for k, v in ipairs(ServerStats_elements) do
        
        local stat_item = vgui.Create("DPanel", ServerStats_list)
        stat_item:SetSize( ServerStats_list:GetWide()/4-9, ServerStats_list:GetTall())
        stat_item:SizeToContentsX(0)
        stat_item.Paint = function(s, w, h)
            draw.RoundedBox(15, 0, 0, w, h-5, CleanTickets.Config.AccentColor)
            draw.RoundedBoxEx(15, 0, 25, w, h-25, CleanTickets.Config.TabPanelBackgroundColor, false, false, true, true)
        end

        local stat_label = CleanTickets.GUI.Utils.DrawLabel({
            parent = stat_item,
            text = v.name,
            font = "CleanTickets_Font24",
            dock = TOP,
            margin = {5, 0, 0, 0},
            align = 5,
        })

        local stat_data = CleanTickets.GUI.Utils.DrawLabel({
            parent = stat_item,
            text = "",
            font = "CleanTickets_Font60",
            dock = FILL,
            margin = {5, 0, 0, 0},
            align = 5,
        })

        if v.data[1] == "number" then
            stat_data:SetText(v.data[2])
        end
        if v.data[1] == "function" then
            local function_data = v.data[2]()
            stat_data:SetText(function_data)
        end

        ServerStats_list:AddPanel(stat_item)
    end

    local AdminStats = CleanTickets.GUI.Utils.DrawContainer({
        parent = parent,
        color = CleanTickets.Config.MainFrameBackground,
        size = {x = parent:GetWide()-20, y = parent:GetTall()/2 - 12.5},
        pos = {x = 10, y = ServerStats:GetTall()+20},
        title = CleanTickets.Lang.PANEL_ADMIN_PLYSTATS,
    })
end


