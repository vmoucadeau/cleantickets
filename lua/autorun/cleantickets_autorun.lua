hook.Add( "PostGamemodeLoaded", "CleanTicketInitialize", function()
	if SERVER then
		AddCSLuaFile("cleantickets/ct_init.lua")
		include( "cleantickets/ct_init.lua" )

		-- FastDL
		resource.AddSingleFile("resource/fonts/cleantickets/Asap.ttf")
	elseif CLIENT then
		include( "cleantickets/ct_init.lua" )
	end
end )
