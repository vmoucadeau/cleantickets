
-- Notifications
CleanTickets.Config.InfoSound = "buttons/lightswitch2.wav"
CleanTickets.Config.ErrorSound = "buttons/button10.wav"

-- Ticket Popup
CleanTickets.Config.TicketSound = "buttons/lightswitch2.wav"
CleanTickets.Config.dateformat = "%d/%m/%Y" -- see https://www.lua.org/pil/22.1.html
CleanTickets.Config.timeformat = "%H:%M"

CleanTickets.Config.SubjectsList = {
    "Troll",
    "Bug(s)",
    "Offense",
    "RolePlay Problem"
}
CleanTickets.Config.ChatCommand = "!ticket" -- Command to send a ticket (and access to the admin panel)
CleanTickets.Config.AutoClose = 60 -- Auto close time (in seconds)
CleanTickets.Config.TicketNotifs = true -- Send a notification to the ticket's sender when admin click on "goto", "teleport"...
CleanTickets.Config.AdminModeByDefault = true -- Admin mode state on admin join the server

CleanTickets.Config.TicketPos = {
    x = 25,
    y = 25
}
CleanTickets.Config.TicketBackground = Color(40, 40, 40, 255)
CleanTickets.Config.TicketOutline = Color(70, 70, 70, 255)
CleanTickets.Config.MaxTicketsOnScreen = nil -- If nil then this value will be based on the height of the screen

-- [GUI]

-- Clean Tickets Panel
CleanTickets.Config.PrimaryColor = Color(189, 189, 189)
CleanTickets.Config.AccentColor = Color(17, 120, 187)
CleanTickets.Config.AccentDarkerColor = Color(16, 109, 186)
CleanTickets.Config.CloseButtonColor = Color(252, 42, 5)
CleanTickets.Config.TextColor = Color(255,255,255)
CleanTickets.Config.MainFrameBackground = Color(70, 70, 70, 255)
CleanTickets.Config.TabPanelBackgroundColor = Color(50, 50, 50,255)

-- Create Ticket Tab
CleanTickets.Config.MsgBoxColor = Color(70, 70, 70, 255)
CleanTickets.Config.MaxAttachments = 3 -- max link that players can send to admin
CleanTickets.Config.MaxDescCharacters = 200 -- max characters that can be send to admin (description)

-- Tickets Status Colors
CleanTickets.Config.OpenColor = Color(40, 111, 81)
CleanTickets.Config.TakenColor = Color(239, 142, 7)
CleanTickets.Config.ClosedColor = Color(255, 0, 0)

-- [SERVER] 

CleanTickets.Config.Debug = true -- Admins can send tickets
CleanTickets.Config.SendTicketDelay = 0 -- Time to wait to send a new ticket (spam protection)
CleanTickets.Config.AdminGroups = { -- ULX Groups that will receive the tickets
    "superadmin",
    "admin"
}