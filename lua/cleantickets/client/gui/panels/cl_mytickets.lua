function CleanTickets.GUI.Panel.MyTickets(parent)

    local function TicketsButtons(ticket)


        if ticket.data.status ~= "Closed" then
            local bt_CloseTicket = CleanTickets.GUI.Utils.DrawButton({
                parent = ticket.but_container,
                text = CleanTickets.Lang.TICKET_BUT_CLOSE,
                dock = TOP,
                size = {x=0,y=57},
                font = "CleanTickets_Font22",
                paint = function(self,w,h)
                    if (self:IsHovered()) then
                        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
                    else
                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
                    end
                end,
                doclick = function(self)
                    CleanTickets.ClFuncs.SendTable("ct_closeticket", ticket.data)
                    CleanTickets.ClFuncs.GetDataCallback = {}
                    CleanTickets.ClFuncs.GetDataCallback.Item = ticket
                    CleanTickets.ClFuncs.GetDataCallback.Func = function(item)
                        local status_data = CleanTickets.GUI.Utils.GetTicketStatus("Closed")
                        local status_label = item.label
                        status_label:SetText(status_data[1])
                        status_label.Paint = function(s, w, h)
                            draw.RoundedBox(8, 0, 0, w, h, status_data[2])
                        end
                        local closebtn = item.but_container:GetChild(0)
                        closebtn:Remove()
                    end 
                    CleanTickets.ClFuncs.GetTickets()
                end
            })

        end

            local bt_DelTicket = CleanTickets.GUI.Utils.DrawButton({
            parent = ticket.but_container,
            text = CleanTickets.Lang.TICKET_BUT_DELETE,
            dock = FILL,
            font = "CleanTickets_Font22",
            paint = function(self,w,h)
                if (self:IsHovered()) then
                    draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.AccentColor, false, false, false, true)
                else
                    draw.RoundedBoxEx(15, 0, 0, w, h, Color(0, 0, 0, 0), false, false, false, true)
                end
            end,
            doclick = function()
                CleanTickets.ClFuncs.SendTable("ct_deleteticket", ticket.data)
                CleanTickets.ClFuncs.GetDataCallback = {}
                CleanTickets.ClFuncs.GetDataCallback.Item = ticket.item
                CleanTickets.ClFuncs.GetDataCallback.Func = function(item)
                    item:Remove()
                end 
                CleanTickets.ClFuncs.GetTickets()
            end
        })
        
    end

    return CleanTickets.GUI.Utils.TicketsListPanel(CleanTickets.ClData.PlyTickets, parent, TicketsButtons, CleanTickets.Lang.PLY_NO_TICKET)
end