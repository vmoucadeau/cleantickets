CT_AdminMode = CleanTickets.Config.AdminModeByDefault


CleanTickets.ClData.OnScreenTickets = {}
CleanTickets.ClData.PlyTickets = {}
CleanTickets.ClData.ServerTickets = {}


-- Chat command
hook.Add( "OnPlayerChat", "CleanTicketsCommand", function( ply, strText, bTeam, bDead ) 
    if ( ply ~= LocalPlayer() ) then return end

	strText = string.lower( strText )

	if ( strText == CleanTickets.Config.ChatCommand ) then
		CT_GetTickets()
		CleanTickets.GUI.Panel.Main()
		return true
	end
end )

function CT_SendTable(netstr, payload)
	net.Start( netstr )
		net.WriteTable(payload)
	net.SendToServer()
end
 
function CT_ShowNotif(text, type, len, sound)
	if sound then
		LocalPlayer():ConCommand( "play " ..sound )
	end
	if(text and type and len) then
		notification.AddLegacy(text, type, len)
	end
end

function CT_RequestNotif(receiver, msg, type, len, sound)
	local sendtable = {
		["receiver"] = receiver,
		["msg"] = msg,
		["type"] = type,
		["len"] = len,
		["sound"] = sound
	}
	CT_SendTable("ct_notif", sendtable)
end

net.Receive("ct_showticket", function(len, ply) 
	local ticketdata = net.ReadTable()
	CleanTickets.GUI.ShowTicket(ticketdata)
end)

net.Receive("ct_notif", function(len, ply) 
	local notif = net.ReadTable()
	CT_ShowNotif(notif["text"], notif["type"], notif["len"], notif["sound"])
end)

function CT_GetTickets()
	net.Start("ct_getdata")
	net.SendToServer()
end

net.Receive("ct_getdata", function(len, ply) 
	local receive = net.ReadTable()
	CleanTickets.ClData.PlyTickets = receive.plytickets
	CleanTickets.ClData.ServerTickets = receive.servertickets
end)