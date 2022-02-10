CleanTickets.ClData.AdminMode = CleanTickets.Config.AdminModeByDefault


CleanTickets.ClData.OnScreenTickets = {}


-- Chat command
hook.Add( "OnPlayerChat", "CleanTicketsCommand", function( ply, strText, bTeam, bDead ) 
    if ( ply ~= LocalPlayer() ) then return end

	strText = string.lower( strText )

	if ( strText == CleanTickets.Config.ChatCommand ) then
		CleanTickets.GUI.Panel.Main()
		return true
	end
end )

function CleanTickets.ClFuncs.IsAdmin()
	for k, v in pairs( CleanTickets.Config.AdminGroups ) do
		if(LocalPlayer():IsUserGroup(v)) then
			return true
		end
	end
	return false
end

function CleanTickets.ClFuncs.SendTable(netstr, payload)
	net.Start( netstr )
		net.WriteTable(payload)
	net.SendToServer()
end
 
function CleanTickets.ClFuncs.ShowNotif(text, type, len, sound)
	if sound then
		LocalPlayer():ConCommand( "play " ..sound )
	end
	if(text and type and len) then
		notification.AddLegacy(text, type, len)
	end
end

function CleanTickets.ClFuncs.RequestNotif(receiver, msg, type, len, sound)
	local sendtable = {
		["receiver"] = receiver,
		["msg"] = msg,
		["type"] = type,
		["len"] = len,
		["sound"] = sound
	}
	CleanTickets.ClFuncs.SendTable("ct_notif", sendtable)
end

net.Receive("ct_showticket", function(len, ply) 
	local ticketdata = net.ReadTable()
	CleanTickets.GUI.ShowTicket(ticketdata)
end)

net.Receive("ct_notif", function(len, ply) 
	local notif = net.ReadTable()
	CleanTickets.ClFuncs.ShowNotif(notif["text"], notif["type"], notif["len"], notif["sound"])
end)
