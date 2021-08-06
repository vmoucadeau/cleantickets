function CleanTickets.GUI.Panel.SendTicket(parent)
    local SelectedPlayers = {}
    local SelectedSubject
    local Message = ""
    local attachments = {}

    local panel = vgui.Create("DPanel", parent)
    panel:SetSize(parent:GetWide(), parent:GetTall())
    panel:SetPos(0, 0)

    panel.Paint = function(self, w, h)
    end

    local TopContainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = panel,
        color = CleanTickets.Config.TabPanelBackgroundColor,
        size = {x=600, y=160},
        dock = TOP       
    })

    local DescriptionContainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = TopContainer,
        color = CleanTickets.Config.MainFrameBackground,
        size = {x=550, y=190},
        dock = FILL,
        margin = {10,10,0,0},
        title = CleanTickets.Lang.PANEL_SENDTICKET_DESCRIPTION
    })

    local subject_table = {{CleanTickets.Lang.PANEL_SENDTICKET_SUBJECT}}
    for i = 1, #CleanTickets.Config.SubjectsList do
        table.insert(subject_table, {CleanTickets.Config.SubjectsList[i]})
    end

    local subjectdropdown = CleanTickets.GUI.Utils.DrawComboBox({
        parent = DescriptionContainer,
        textcolor = CleanTickets.Config.TextColor,
        font = "CleanTickets_Font25",
        items = subject_table,
        size = {x=0,y=25},
        dock = 4,
        margin = {10,25,10,0},
        sortitems = false,
        onselect = function(index, value, data)
            if(index == 1) then
                SelectedSubject = nil
            else
                SelectedSubject = value
            end
        end
        
    })

    local PlayerListContainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = TopContainer,
        font = "CleanTickets_Font25",
        color = CleanTickets.Config.MainFrameBackground,
        size = {x=200, y=190},
        title = CleanTickets.Lang.PANEL_SENDTICKET_SELECTPLAYERS,
        dock = RIGHT,
        margin = {10,10,10,0}
    })

    local description_entry = CleanTickets.GUI.Utils.DrawTextBox({
        parent = DescriptionContainer,
        font = "CleanTickets_Font25",
        size = {x=0, y=0},
        dock = FILL,
        margin = {10,10,10,10},
        multiline = true,
        maxcharacters = CleanTickets.Config.MaxDescCharacters,
        onvaluechange = function(value)
            Message = value
        end
    })

    

    local players_table = {}
    for k, v in pairs(player.GetAll()) do
        table.insert(players_table, {v:Name(), v:SteamID64()})
    end

    local playersdropdown = CleanTickets.GUI.Utils.DrawComboBox({
        parent = PlayerListContainer,
        textcolor = CleanTickets.Config.TextColor,
        font = "CleanTickets_Font25",
        items = players_table,
        size = {y=25},
        dock = 4,
        margin = {10,25,10,0},
        onselect = function(index, value, data)
            for k, v in pairs(SelectedPlayers) do
                -- if(v[2] == data) then
                if (v[1] == value) then
                    return
                end
            end
            table.insert(SelectedPlayers, {value, data})
            fetchPlylist()
        end
    })


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
            delbut:SetFont("CleanTickets_Font18")
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

    local AttachmentsContainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = panel,
        color = CleanTickets.Config.MainFrameBackground,
        size = {x=600, y=160},
        title = CleanTickets.Lang.PANEL_SENDTICKET_ATTACHMENTS,
        dock = TOP,
        margin = {10,10,10,0}
    })

    local TopAttachmentsContainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = AttachmentsContainer,
        color = CleanTickets.Config.MainFrameBackground,
        size = {x=0, y=28},
        dock = TOP,
        margin = {10,25,10,0}
    })

    local link = ""

    local LinkEntry = CleanTickets.GUI.Utils.DrawTextBox({
        parent = TopAttachmentsContainer,
        font = "CleanTickets_Font22",
        size = {x=0, y=0},
        dock = FILL,
        onvaluechange = function(value)
            link = value
        end

    })

    local AddAttachmentButton = CleanTickets.GUI.Utils.DrawButton({
        parent = TopAttachmentsContainer,
        font = "CleanTickets_Font25",
        text = CleanTickets.Lang.PANEL_SENDTICKET_BTNADDLINK,
        size = {x=0,y=25}, 
        dock = RIGHT,
        margin = {10,0,0,0},
        doclick = function()
            if string.len(link) == 0 then return end
            if #attachments >= CleanTickets.Config.MaxAttachments then
                CleanTickets.ClFuncs.ShowNotif(CleanTickets.Lang.PANEL_ATTACHMENTLIMIT, 0, 3, nil)
                return
            end
            for k, v in pairs(attachments) do
                if (v == link) then
                    return
                end
            end
            table.insert(attachments, link)
            fetchAttachmentslist()
        end,
        SizeToContentsX = 10
    })

    local AttachmentsList = vgui.Create("DScrollPanel", AttachmentsContainer)
    AttachmentsList:Dock(1)
    AttachmentsList:DockMargin(10,10,10,10)
    AttachmentsList.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor)
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

    function fetchAttachmentslist()
        AttachmentsList:Clear()
        for k, v in ipairs(attachments) do
            local delbut = vgui.Create("DButton", AttachmentsList)
            delbut:SetText(v)
            delbut:SetFont("CleanTickets_Font18")
            delbut:SetColor(Color(255, 255, 255))
            delbut:Dock(4)
            delbut:DockMargin(5, 5, 5, 0)
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
                for k, v in pairs(attachments) do
                    if v == name then
                        table.remove(attachments, k)
                        break
                    end
                end
                AttachmentsList:Clear()
                fetchAttachmentslist()
            end

            AttachmentsList:Add(delbut)
        end
    end

    local sendbut = vgui.Create("DButton", panel)
    sendbut:SetSize(100, 40)
    sendbut:SetPos(panel:GetWide() / 2 - sendbut:GetWide() / 2, panel:GetTall() - sendbut:GetTall()-10)
    sendbut:SetText(CleanTickets.Lang.PANEL_SENDTICKET_BTNSEND)
    sendbut:SetFont("CleanTickets_Font25")
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
            CleanTickets.ClFuncs.ShowNotif("You need to chose a subject", 1, 2, nil)
            return
        end
        if (Message == "") then
            CleanTickets.ClFuncs.ShowNotif("You need enter a message", 1, 2, nil)
            return
        end
        local tabletosend = {
            ["players"] = SelectedPlayers,
            ["subject"] = SelectedSubject,
            ["attachments"] = attachments,
            ["message"] = Message,
            ["status"] = "Open",
            ["date"] = os.date(CleanTickets.Config.dateformat),
            ["time"] = os.date(CleanTickets.Config.timeformat)
        }
        CleanTickets.ClFuncs.SendTable("ct_sendticket", tabletosend)
        CleanTickets.ClFuncs.GetTickets()
    end

    return panel

end