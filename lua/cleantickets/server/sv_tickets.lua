ticketslist = {}

-- Console debug
function CT_LogInConsole(msg)
	MsgN("[Clean Tickets]: " .. msg)
end

function SendTable(ply, table, network)
    net.Start(network)
    net.WriteTable(table)
    net.Send(ply)
end

function IsAdmin(ply)
    for k, v in pairs(CleanTickets.Config.AdminGroups) do
        if (ply:GetUserGroup() == v) then
            return true
        end    
    end
    return false
end

-- Notifs
util.AddNetworkString("ct_notif")

function SendNotif(ply, text, type, len, sound)
    local notiftable = {["text"] = text, ["type"] = type, ["len"] = len, ["sound"] = sound}
    SendTable(ply, notiftable, "ct_notif")
end
 
-- Notif request from admin
net.Receive("ct_notif", function(len, ply) 
    if IsAdmin(ply) then
        local notiftable = net.ReadTable()
        SendNotif(notiftable.receiver, notiftable.msg, notiftable.type, notiftable.len, notiftable.sound)
    else 
        SendNotif(ply, "You need to be admin to do that.", 0, 2, nil)
    end
end)


-- DATA

function GetTicketsTable() 
    CT_LogInConsole("Reading data...")
	ticketslist = util.JSONToTable(file.Read("cleantickets/ct_data.txt","DATA"))
end

function WriteTicketsTable()
    CT_LogInConsole("Saving data...")
	file.Write("cleantickets/ct_data.txt",util.TableToJSON(ticketslist))
end 

if not file.Exists("cleantickets/", "DATA") then
	file.CreateDir("cleantickets")
	WriteTicketsTable()
	CT_LogInConsole("Data file created !")
else 
    GetTicketsTable()
end
   
 
util.AddNetworkString("ct_getdata")
function GetPlayerTickets(steamid)
    local ply_tickets = {}
    for k, v in pairs(ticketslist) do
        if v.sender.steamid == steamid then
            table.insert(ply_tickets, v)
        end
    end
    return ply_tickets
end
 
net.Receive("ct_getdata", function(len, ply) 
    local tosend = {}
    tosend.plytickets = GetPlayerTickets(ply:SteamID64())
    if IsAdmin(ply) then tosend.servertickets = ticketslist else tosend.servertickets = {} end
    SendTable(ply, tosend, "ct_getdata")
end)


-- Tickets gestion
 
util.AddNetworkString("ct_showticket")
function TicketBroadcast(ticketdata)
    for k, v in pairs(player.GetHumans()) do
        if(IsAdmin(v)) then
            SendTable(v, ticketdata, "ct_showticket")
        end
    end    
    WriteTicketsTable()
end 

util.AddNetworkString("ct_sendticket")
net.Receive("ct_sendticket", function(len, ply)
    if(IsAdmin(ply) and not CleanTickets.Config.Debug) then SendNotif(ply, "You can't send tickets because you're an admin.", 1, 2, CleanTickets.Config.ErrorSound) return end 
    if timer.Exists("ct_timer"..ply:SteamID64()) then SendNotif(ply, "You need to wait 30s for sending a new ticket.", 1, 2, CleanTickets.Config.ErrorSound) return end
    local payload = net.ReadTable() 
    payload.id = #ticketslist
    payload.status = "Open"
    payload.sender = {
        ["name"] = ply:GetName(),
        ["steamid"] = ply:SteamID64(),
    } 
    
    table.insert(ticketslist, payload) 
    TicketBroadcast(payload)
    timer.Create("ct_timer" .. ply:SteamID64(), 1, 0, function() timer.Destroy("ct_timer" .. ply:SteamID64()) end)
end)


util.AddNetworkString("ct_takerequest") 
net.Receive("ct_takerequest", function(len, ply)
    if not IsAdmin(ply) then SendNotif(ply, "You don't have permission to do that.", 1, 2, CleanTickets.Config.ErrorSound) return end 
    local payload = net.ReadTable()
    payload.status = "Taken"
    payload.admin = {
        ["name"] = ply:GetName(), 
        ["steamid"] = ply:SteamID64(),
    }
    payload.isupdate = true
    for k, v in pairs(ticketslist) do
        if v.id == payload.id then
            ticketslist[k] = payload
            break
        end
    end
    SendNotif(player.GetBySteamID64(payload.sender.steamid), ply:GetName().." took care of your request.", 0, 3, CleanTickets.Config.InfoSound)
    TicketBroadcast(payload)
    -- timer.Remove("ct_ticket_" .. payload.sender:SteamID64())
end)

 
function CloseTicket(payload, closer)
    payload.isupdate = true
    payload.status = "Closed"
    for k, v in pairs(ticketslist) do
        if v.id == payload.id then
            ticketslist[k] = payload
            break
        end 
    end
    if closer:SteamID64() == payload.sender.steamid then
        SendNotif(player.GetBySteamID64(payload.sender.steamid), "Your ticket has been closed.", 0, 3, CleanTickets.Config.InfoSound)
    else
        SendNotif(player.GetBySteamID64(payload.sender.steamid), "Your ticket has been closed by " .. closer:GetName(), 0, 3, CleanTickets.Config.InfoSound)
    end
    TicketBroadcast(payload)
    -- timer.Remove("ct_ticket_" .. payload.sender:SteamID64())
end

util.AddNetworkString("ct_closeticket")
net.Receive("ct_closeticket", function(len, ply)
    local payload = net.ReadTable()
    if (not IsAdmin(ply)) or (ply:SteamID64() ~= payload.sender.steamid) then SendNotif(ply, "You don't have permission to do that.", 1, 2, CleanTickets.Config.ErrorSound) return end 
    CloseTicket(payload, ply)
end)

function DeleteTicket(payload, closer)
    for k, v in pairs(ticketslist) do
        if v.id == payload.id then
            table.remove(ticketslist, k)
            break
        end 
    end
    if closer:SteamID64() == payload.sender.steamid then
        SendNotif(player.GetBySteamID64(payload.sender.steamid), "Your ticket has been deleted.", 0, 3, CleanTickets.Config.InfoSound)
    else
        SendNotif(player.GetBySteamID64(payload.sender.steamid), "Your ticket has been deleted by " .. closer, 0, 3, CleanTickets.Config.InfoSound)
    end
    WriteTicketsTable()
    -- timer.Remove("ct_ticket_" .. payload.sender:SteamID64())
end

util.AddNetworkString("ct_deleteticket")
net.Receive("ct_deleteticket", function(len, ply)
    local payload = net.ReadTable()
    if (not IsAdmin(ply)) or (ply:SteamID64() ~= payload.sender.steamid) then SendNotif(ply, "You don't have permission to do that.", 1, 2, CleanTickets.Config.ErrorSound) return end 
    if payload.status ~= "Closed" then
        CloseTicket(payload, ply)
    end
    DeleteTicket(payload, ply)
end)