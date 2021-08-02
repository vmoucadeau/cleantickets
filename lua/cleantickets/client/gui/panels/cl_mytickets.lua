function CleanTickets.GUI.Panel.MyTickets(parent)

    TicketsButtons = function(item_data, item_panel)
        if item_data.status ~= "Closed" then
            local bt_CloseTicket = vgui.Create("DButton", item_panel)
            bt_CloseTicket:SetPos(item_panel:GetWide() - 100, 128)
            bt_CloseTicket:SetSize(100, 23)
            bt_CloseTicket:SetText("Close")
            bt_CloseTicket:SetFont("CleanTickets_Font22")
            bt_CloseTicket:SetColor(Color(255, 255, 255))
            bt_CloseTicket.DoClick = function()
                CT_SendTable("ct_closeticket", item_data)
                CT_GetTickets()
                timer.Simple(1.5, function()
                    CleanTickets.GUI.Utils.TicketsListPanel(CleanTickets.ClData.PlyTickets, parent, TicketsButtons, search_filters)
                end)
            end
            bt_CloseTicket.Paint = function(self, w, h)
                if (self:IsHovered()) then
                    draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.AccentColor, false, false, false, true)
                else
                    draw.RoundedBoxEx(15, 0, 0, w, h, Color(0, 0, 0, 0), false, false, false, true)
                end
            end
        else
            local bt_DeleteTicket = vgui.Create("DButton", item_panel)
            bt_DeleteTicket:SetPos(item_panel:GetWide() - 100, 128)
            bt_DeleteTicket:SetSize(100, 23)
            bt_DeleteTicket:SetText("Delete")
            bt_DeleteTicket:SetFont("CleanTickets_Font22")
            bt_DeleteTicket:SetColor(Color(255, 255, 255))
            bt_DeleteTicket.DoClick = function()
                CT_SendTable("ct_deleteticket", item_data)
                CT_GetTickets()
                timer.Simple(1.5, function()
                    CleanTickets.GUI.Utils.TicketsListPanel(CleanTickets.ClData.PlyTickets, parent, TicketsButtons, search_filters)
                end)
            end
            bt_DeleteTicket.Paint = function(self, w, h)
                if (self:IsHovered()) then
                    draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.AccentColor, false, false, false, true)
                else
                    draw.RoundedBoxEx(15, 0, 0, w, h, Color(0, 0, 0, 0), false, false, false, true)
                end
            end
        end
    end

    return CleanTickets.GUI.Utils.TicketsListPanel(CleanTickets.ClData.PlyTickets, parent, TicketsButtons, search_filters)
    -- return TicketsListTable(CleanTickets.ClData.PlyTickets, parent, search_filters)
end