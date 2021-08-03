function CleanTickets.GUI.Panel.MyTickets(parent)

    local TicketsButtons = function(item_data, item_panel)
        if item_data.status ~= "Closed" then
            local bt_CloseTicket = vgui.Create("DButton", item_panel)
            bt_CloseTicket:SetPos(item_panel:GetWide() - 100, 128)
            bt_CloseTicket:SetSize(100, 23)
            bt_CloseTicket:SetText(CleanTickets.Lang.BTN_CLOSE)
            bt_CloseTicket:SetFont("CleanTickets_Font22")
            bt_CloseTicket:SetColor(Color(255, 255, 255))
            bt_CloseTicket.DoClick = function()
                CT_SendTable("ct_closeticket", item_data)
                CT_GetTickets()
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

    return CleanTickets.GUI.Utils.TicketsListPanel(CleanTickets.ClData.PlyTickets, parent, TicketsButtons)
end