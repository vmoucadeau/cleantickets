-- Console debug
local function CT_LogInConsole(msg)
	MsgN("[Clean Tickets]: " .. msg)
end

local function SendTable(ply, table, network)
    net.Start(network)
    net.WriteTable(table)
    net.Send(ply)
end

local function SendCompressedTable(ply, table, network)
    local TableJSON = util.TableToJSON(table)
    local compressed_str = util.Compress(TableJSON)
    local len = #compressed_str
    net.Start(network)
        net.WriteUInt(len, 16)
        net.WriteData(compressed_str, len)
    net.Send(ply)
end

local function IsAdmin(ply)
    for k, v in pairs(CleanTickets.Config.AdminGroups) do
        if (ply:GetUserGroup() == v) then
            return true
        end    
    end
    return false
end

-- Notifs
util.AddNetworkString("ct_notif")

local function SendNotif(ply, text, type, len, sound)
    if not ply then return end
    local notiftable = {["text"] = text, ["type"] = type, ["len"] = len, ["sound"] = sound}
    SendTable(ply, notiftable, "ct_notif")
end
 
-- Notif request from admin
net.Receive("ct_notif", function(len, ply) 
    if IsAdmin(ply) then
        local notiftable = net.ReadTable()
        SendNotif(notiftable.receiver, notiftable.msg, notiftable.type, notiftable.len, notiftable.sound)
    else 
        SendNotif(ply, CleanTickets.Lang.NOTIF_NOTADMIN, 0, 2, nil)
    end
end)
   

-- Tickets gestion

util.AddNetworkString("ct_showticket")
local function TicketBroadcast(ticketdata)
    for k, v in pairs(player.GetHumans()) do
        if(IsAdmin(v)) then
            SendCompressedTable(v, ticketdata, "ct_showticket")
        end
    end    
end 

local function CloseTicket(payload, closer)
    if payload.status == "Closed" then return end
    payload.isupdate = true
    payload.status = "Closed"
    local sender = player.GetBySteamID64(payload.sender.steamid)
    if closer then
        if(sender) then
            SendNotif(sender, string.format(CleanTickets.Lang.NOTIF_TICKETCLOSEDBY, closer:GetName()), 0, 3, CleanTickets.Config.InfoSound)
        end
        SendNotif(closer, string.format(CleanTickets.Lang.NOTIF_TICKETCLOSED), 0, 3, CleanTickets.Config.InfoSound)
    else
        if(sender) then
            SendNotif(sender, CleanTickets.Lang.NOTIF_TICKETCLOSEDBYSRV, 0, 3, CleanTickets.Config.InfoSound)
        end
    end
    TicketBroadcast(payload)
end

util.AddNetworkString("ct_sendticket")
net.Receive("ct_sendticket", function(len, ply)
    if not ply then return end
    if(IsAdmin(ply) and not CleanTickets.Config.Debug) then SendNotif(ply, CleanTickets.Lang.NOTIF_NOTADMIN, 1, 2, CleanTickets.Config.ErrorSound) return end 
    if timer.Exists("ct_timer"..ply:SteamID64()) then SendNotif(ply, string.format(CleanTickets.Lang.NOTIF_NEEDWAIT, math.floor(timer.TimeLeft("ct_timer"..ply:SteamID64()))), 1, 2, CleanTickets.Config.ErrorSound) return end
    local payload = net.ReadTable() 
    payload.id = CleanTickets.SvData.id
    payload.status = "Open"
    payload.sender = {
        ["name"] = ply:GetName(),
        ["steamid"] = ply:SteamID64(),
    } 

    TicketBroadcast(payload)
    SendNotif(ply, CleanTickets.Lang.NOTIF_TICKET_SENT, 0, 3, CleanTickets.Config.InfoSound)
    timer.Create("ct_timer" .. ply:SteamID64(), CleanTickets.Config.SendTicketDelay, 0, function() timer.Destroy("ct_timer" .. ply:SteamID64()) end)
end)


util.AddNetworkString("ct_takerequest") 
net.Receive("ct_takerequest", function(len, ply)
    if not IsAdmin(ply) then SendNotif(ply, CleanTickets.Lang.NOTIF_NOTADMIN, 1, 2, CleanTickets.Config.ErrorSound) return end 
    local payload = net.ReadTable()
    payload.status = "Taken"
    payload.admin = {
        ["name"] = ply:GetName(), 
        ["steamid"] = ply:SteamID64(),
    }
    payload.isupdate = true
    
    if(player.GetBySteamID64(payload.sender.steamid)) then
        SendNotif(player.GetBySteamID64(payload.sender.steamid), string.format(CleanTickets.Lang.NOTIF_TICKET_TAKEN, ply:GetName()), 0, 3, CleanTickets.Config.InfoSound)
        TicketBroadcast(payload)
    else
        SendNotif(ply, string.format(CleanTickets.Lang.NOTIF_PLAYER_NOT_FOUND, ply:GetName()), 0, 3, CleanTickets.Config.InfoSound)
        CloseTicket(payload, ply)
    end
end)

util.AddNetworkString("ct_closeticket")
net.Receive("ct_closeticket", function(len, ply)
    local payload = net.ReadTable()
    if not IsAdmin(ply) then SendNotif(ply, CleanTickets.Lang.NOTIF_NOTADMIN, 1, 2, CleanTickets.Config.ErrorSound) return end 
    CloseTicket(payload, ply)
end)

