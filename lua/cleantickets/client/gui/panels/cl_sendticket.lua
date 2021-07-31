function CleanTickets.GUI.Panel.SendTicket(parent)
    local SelectedPlayers = {}
    local SelectedSubject
    local Message = ""
    local attachments = {}

    local panel = vgui.Create("DPanel", parent)
    panel:SetSize(parent:GetWide(), parent:GetTall())
    panel:SetPos(0, 0)

    panel.Paint = function(self, w, h)
        surface.SetFont("ct_TextFont")
    end

    local TopContainer = CleanTickets.GUI.Utils.DrawContainer(panel, CleanTickets.Config.TabPanelBackgroundColor, {["x"]=600, ["y"]=190}, nil, "", nil, 4, {0,0,0,0})

    local DescriptionContainer = CleanTickets.GUI.Utils.DrawContainer(TopContainer, CleanTickets.Config.MainFrameBackground, {["x"]=550, ["y"]=190}, nil, "Description", nil, 2, {10,10,0,0})

    local PlayerListContainer = CleanTickets.GUI.Utils.DrawContainer(TopContainer, CleanTickets.Config.MainFrameBackground, {["x"]=200, ["y"]=190}, nil, "Select Players", nil, 3, {10,10,10,0})

    local subject_table = {{"Subject", nil}}
    for i = 1, #CleanTickets.Config.SubjectsList do
        table.insert(subject_table, {CleanTickets.Config.SubjectsList[i], nil})
    end
    local subjectdropdown = CleanTickets.GUI.Utils.DrawComboBox(DescriptionContainer, CleanTickets.Config.TextColor, "ct_TextFont", {["x"] = 100, ["y"] = 25}, subject_table, 4, {10,25,10,0}, function(index, value, data) 
        if(index == 1) then
            SelectedSubject = nil
        else
            SelectedSubject = value
        end
    end)

    local players_table = {}
    for k, v in pairs(player.GetAll()) do
        table.insert(players_table, {v:Name(), v:SteamID64()})
    end

    local playersdropdown = CleanTickets.GUI.Utils.DrawComboBox(PlayerListContainer, CleanTickets.Config.TextColor, "ct_TextFont", {["x"] = 100, ["y"] = 25}, players_table, 4, {10,25,10,0}, function(index, value, data) 
        for k, v in pairs(SelectedPlayers) do
            -- if(v[2] == data) then
            if (v[1] == value) then
                return
            end
        end
        table.insert(SelectedPlayers, {value, data})
        fetchPlylist()
    end)

    local description_entry = CleanTickets.GUI.Utils.DrawTextBox(DescriptionContainer, CleanTickets.Config.TextColor, "ct_TextFont", {["x"] = 500, ["y"] = 110}, 4, {10,10,10,0}, nil, function(text)
        Message = text
    end)

    
    local PlyList = vgui.Create("DScrollPanel", PlayerListContainer)
    PlyList:Dock(1)
    PlyList:DockMargin(10,10,10,10)
    PlyList.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor)
    end

    local sbar = PlyList:GetVBar()
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end
    function sbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
    end
    function sbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
    end

    function fetchPlylist()
        PlyList:Clear()
        for k, v in ipairs(SelectedPlayers) do
            local delbut = vgui.Create("DButton", panel)
            delbut:SetText(v[1])
            delbut:SetFont("ct_TinyFont")
            delbut:SetColor(Color(255, 255, 255))
            delbut:Dock(4)
            delbut:DockMargin(5, 5, 5, 5)
            delbut.Paint = function(self, w, h)
                if (self:IsHovered()) then
                    draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentColor)
                    draw.RoundedBox(8, 2, 2, w - 4, h - 4, CleanTickets.Config.MsgBoxColor)
                else
                    draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.MsgBoxColor)
                end
            end
            function delbut:DoClick()
                local name = delbut:GetText()
                for k, v in pairs(SelectedPlayers) do
                    if v[1] == name then
                        table.remove(SelectedPlayers, k)
                        break
                    end
                end
                PlyList:Clear()
                fetchPlylist()
            end

            PlyList:Add(delbut)
        end
    end

    local AttachmentsContainer = CleanTickets.GUI.Utils.DrawContainer(panel, CleanTickets.Config.MainFrameBackground, {["x"]=600, ["y"]=100}, nil, "Attachments", nil, 4, {10,10,10,0})

    local TopAttachmentsContainer = CleanTickets.GUI.Utils.DrawContainer(AttachmentsContainer, CleanTickets.Config.MainFrameBackground, {["x"]=0, ["y"]=25}, nil, "", nil, 4, {10,25,10,0})

    local link = ""
    local LinkEntry = CleanTickets.GUI.Utils.DrawTextBox(TopAttachmentsContainer, CleanTickets.Config.TextColor, "ct_TextFont", {["x"] = 500, ["y"] = 25}, 2, {0,0,0,0}, nil, function(text)
        link = text
    end)

    local AddAttachementButton = CleanTickets.GUI.Utils.DrawButton(TopAttachmentsContainer, "Add link", "ct_TextFont", {["x"] = 100, ["y"] = 25}, 2, {10,0,0,0}, nil, function()
        for k, v in pairs(attachments) do
            -- if(v[2] == data) then
            if (v == value) then
                return
            end
        end
        table.insert(attachments, link)
    end)

    local AttachmentsList = vgui.Create("DScrollPanel", AttachmentsContainer)
    AttachmentsList:Dock(4)
    AttachmentsList:DockMargin(10,10,10,10)
    AttachmentsList.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor)
    end
    local sbar = AttachmentsList:GetVBar()
    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end
    function sbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
    end
    function sbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.AccentColor)
    end
    function AttachmentsContainer:DoClick()
        local name = AttachmentsContainer:GetText()
        for k, v in pairs(attachments) do
            if v[1] == name then
                table.remove(attachments, k)
                break
            end
        end
    end

    local sendbut = vgui.Create("DButton", panel)
    sendbut:SetSize(100, 40)
    sendbut:SetPos(panel:GetWide() / 2 - sendbut:GetWide() / 2, panel:GetTall() - sendbut:GetTall()-20)
    sendbut:SetText("Send")
    sendbut:SetFont("ct_TextFont")
    sendbut:SetColor(CleanTickets.Config.TextColor)
    sendbut.Paint = function(self, w, h)
        if (sendbut:IsHovered()) then
            draw.RoundedBox(20, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor)
        else
            draw.RoundedBox(20, 0, 0, w, h, CleanTickets.Config.AccentColor)
        end
    end
    function sendbut:DoClick(clr, btn)
        if (SelectedSubject == nil) then
            CT_ShowNotif("You need to chose a subject", 1, 2, nil)
            return
        end
        if (Message == "") then
            CT_ShowNotif("You need enter a message", 1, 2, nil)
            return
        end
        local tabletosend = {
            ["players"] = SelectedPlayers,
            ["subject"] = SelectedSubject,
            ["message"] = Message,
            ["status"] = "Open",
            ["date"] = os.date(CleanTickets.Config.dateformat),
            ["time"] = os.date(CleanTickets.Config.timeformat)
        }
        CT_SendTable("ct_sendticket", tabletosend)
        CT_GetTickets()
    end

    return panel

end