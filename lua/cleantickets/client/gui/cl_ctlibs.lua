

CleanTickets.GUI.Utils = CleanTickets.GUI.Utils or {}


        ----------------------------------------------
        --                                          --
        --                  UTILS                   --
        --                                          --
        ----------------------------------------------



function inQuad(fraction, beginning, change)
    return change * (fraction ^ 2) + beginning
end

function CleanTickets.GUI.Utils.DrawLine(start_x, start_y, end_x, end_y, color)
    surface.SetDrawColor(color)
    surface.DrawLine(start_x, start_y, end_x, end_y)
end


function CleanTickets.GUI.Utils.DrawContainer(parent, color, size, pos, title, paint, dock, margin)
    local title = title or ""
    local container = vgui.Create("DPanel", parent)
    if dock then
        container:Dock(dock)
        if margin then
            container:DockMargin(margin[1], margin[2], margin[3], margin[4])
        end
    end
    if size then 
        container:SetSize(size["x"], size["y"])
    end
    if pos then
        container:SetPos(pos["x"], pos["y"])
    end
    if(paint) then
        container.Paint = paint
    else
        container.Paint = function(s,w, h)
            draw.RoundedBox(10, 0, 0, w, h, color)
            local wt, ht = surface.GetTextSize(title)
            draw.SimpleText(title, "CleanTickets_Font25", w/2, 10,
                Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    return container
end

function CleanTickets.GUI.Utils.DrawLabel(parent, text, font, size, pos, dock, margin, sizetocontent, align)
    local label = vgui.Create( "DLabel", parent )
	if dock then
		label:Dock(dock)
		if margin then
			label:DockMargin(margin[1], margin[2], margin[3], margin[4])
		end
	end
	label:SetColor(Color(255, 255, 255, 255))
	label:SetFont(font)
	label:SetText(text)
	if size then
		label:SetSize(size["x"], size["y"])
    else
        surface.SetFont(font)
        local w, h = surface.GetTextSize(text)
        label:SetSize(w, h)
    end

	label:SetPos(pos["x"] or 0, pos["y"] or 0)
	
	if sizetocontent then
		if not size["x"] then
			label:SizeToContentsX()
		end
		if not size["y"] then
			label:SizeToContentsY()
		end
	end
	if align then
		label:SetContentAlignment(align)
	end

	return label
end


function CleanTickets.GUI.Utils.DrawComboBox(parent, color, font, size, items, dock, margin, onselect, paint)
    local combo = vgui.Create( "DComboBox", parent )
    
    combo:SetColor(color)
    combo:SetFont(font)
    combo:SetSize(size["x"] or 0, size["y"] or 0)
    if dock then
        combo:Dock(dock)
        if margin then
            combo:DockMargin(margin[1], margin[2], margin[3], margin[4])
        end
    end

    if paint then
        combo.Paint = paint
    else
        combo.Paint = function(s,w, h)
            if (s:IsMenuOpen()) then
                draw.RoundedBox(10, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor)
            else
                draw.RoundedBox(10, 0, 0, w, h, CleanTickets.Config.AccentColor)
            end
        end
    end

    for i = 1, #items do
        combo:AddChoice(items[i][1], items[i][2] or nil)
    end

    combo:ChooseOptionID(1)
    
    function combo:OnSelect(index, value, data)
        onselect(index, value, data)
    end

    return combo

end

function CleanTickets.GUI.Utils.DrawTextBox(parent, color, font, size, dock, margin, paint, onvaluechange, multiline, maxcharacters)
    local msgfocused = false
    local textboxcontainer = CleanTickets.GUI.Utils.DrawContainer(parent, nil, {["x"]=size["x"] or 0, ["y"]=size["y"] or 0}, nil, "", function(self, w, h) 
        if (msgfocused) then
            draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor)
        else
            draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentColor)
        end
        draw.RoundedBox(8, 2, 2, w - 4, h - 4, CleanTickets.Config.TabPanelBackgroundColor)
    end)

    if dock then
        textboxcontainer:Dock(dock)
        if margin then
            textboxcontainer:DockMargin(margin[1], margin[2], margin[3], margin[4])
        end
    end

    local textbox = vgui.Create( "DTextEntry", textboxcontainer )
    
    textbox:SetFont(font)
    textbox:SetUpdateOnType(true)
    if multiline then
        textbox:SetMultiline(true)
    end
    textbox:Dock(1)
    textbox:DockMargin(3,3,3,3)

    textbox.Paint = function(self, w, h)
        -- draw.RoundedBox(15, 0, 0, w, h, Color(100, 100, 100))
        self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
        if (textbox:IsEditing()) then
            msgfocused = true
        else
            msgfocused = false
        end
    end
    function textbox:OnValueChange(value)
        if maxcharacters and string.len(value) == maxcharacters then
            textbox.AllowInput = function(s, val) return true end
            CT_ShowNotif(CleanTickets.Lang.PANEL_TEXTBOXLIMIT, 0, 3, nil)
        else
            textbox.AllowInput = function(s, val) return false end
        end
        onvaluechange(value)
    end

    return textboxcontainer
end

function CleanTickets.GUI.Utils.DrawButton(parent, text, font, size, dock, margin, paint, doclick)
    local button = vgui.Create( "DButton", parent )
    button:SetFont(font)
    button:SetColor(CleanTickets.Config.TextColor)
    button:SetSize(size["x"] or 0, size["y"] or 0)
    if dock then
        button:Dock(dock)
        if margin then
            button:DockMargin(margin[1], margin[2], margin[3], margin[4])
        end
    end
    if paint then
        button.Paint = paint
    else
        button.Paint = function(s,w, h)
            if s:IsHovered() then
                draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor)
                -- draw.RoundedBox(8, 2, 2, w-4, h - 4, CleanTickets.Config.TabPanelBackgroundColor)
            else
                draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentColor)
                -- draw.RoundedBox(8, 2, 2, w-4, h - 4, CleanTickets.Config.TabPanelBackgroundColor)
            end
        end
    end
    button:SetText(text)
    function button:DoClick()
        doclick()
    end
    return button
end

function CleanTickets.GUI.Utils.GetTicketStatus(status)
    local status_color
    local status_text
    if status == "Open" then
        status_color = CleanTickets.Config.OpenColor
        status_text = CleanTickets.Lang.TICKETSTATUS_OPEN
    elseif status == "Taken" then
        status_color = CleanTickets.Config.TakenColor
        status_text = CleanTickets.Lang.TICKETSTATUS_TAKEN
    else 
        status_color = CleanTickets.Config.ClosedColor
        status_text = CleanTickets.Lang.TICKETSTATUS_CLOSED
    end

    return {status_text, status_color}
end

        ----------------------------------------------
        --                                          --
        --               TICKETS LIST               --
        --                                          --
        ----------------------------------------------
 
function CleanTickets.GUI.Utils.TicketsListPanel(ticketslist, parent, ticketbut)
    parent:Clear()

    local filterspanelopen = false
    local filter_expanded = 32
    local filterspanel = CleanTickets.GUI.Utils.DrawContainer(parent, CleanTickets.Config.MainFrameBackground, {["x"] = parent:GetWide()-20, ["y"] = 30}, {["x"] = 10, ["y"] = 10}, "")

    local listpanel = vgui.Create("DPanel", parent)
    listpanel:SetSize(parent:GetWide()-20, parent:GetTall()-filterspanel:GetTall()-20)
    listpanel:SetPos(10,filterspanel:GetTall()+10)
    listpanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor)
    end

    local item_list = vgui.Create( 'DPanelList', listpanel )
    item_list:SetPos( 10, 10 )
    item_list:SetSize( listpanel:GetWide() - 20, listpanel:GetTall() - 20 )
	item_list:EnableHorizontal( true )
	item_list:EnableVerticalScrollbar(true)
    item_list:SetSpacing( 10 )

    local filters_data = {
        status = "",
        player = nil,
        subject = "",
        date = ""
    }



    local filtersbutton = vgui.Create("DButton", filterspanel)
    filtersbutton:SetSize(filterspanel:GetWide(), 30)
    filtersbutton:SetPos(0,0)
    filtersbutton:SetText(CleanTickets.Lang.FILTERS)
    filtersbutton:SetFont("CleanTickets_Font22")
    filtersbutton:SetColor(Color(255,255,255))
    filtersbutton.DoClick = function()
        if not filterspanelopen then
            filterspanelopen = true
            filterspanel:SetTall(30+filter_expanded)
            local filterscontainer = CleanTickets.GUI.Utils.DrawContainer(filterspanel, CleanTickets.Config.MainFrameBackground, {["x"] = filterspanel:GetWide(), ["y"] = 30}, {["x"] = 0, ["y"] = 30}, "")
            local filters = CleanTickets.GUI.Utils.DisplayFilters(filterscontainer, ticketslist, function(data) 
                filters_data = data
                CleanTickets.GUI.TLP_RefreshTickets()
            end)
            filters:SetPos(filterspanel:GetWide()/2-filters:GetWide()/2, 0)
            
            listpanel:SetTall(listpanel:GetTall()-filter_expanded)
            listpanel:SetPos(10, select(2, listpanel:GetPos())+filter_expanded)
            item_list:SetSize( listpanel:GetWide() - 20, listpanel:GetTall() - 20 )
        else
            filterspanelopen = false
            filterspanel:SetTall(30)
            listpanel:SetTall(listpanel:GetTall()+filter_expanded)
            listpanel:SetPos(10, select(2, listpanel:GetPos())-filter_expanded)
            item_list:SetSize( listpanel:GetWide() - 20, listpanel:GetTall() - 20 )
        end
    end
    filtersbutton.Paint = function(s,w,h)
        if s:IsHovered() then
            draw.RoundedBox(10, 0, 0, w, h, CleanTickets.Config.AccentColor)
            draw.RoundedBox(10, 2, 2, w-4, h-4, CleanTickets.Config.TabPanelBackgroundColor)
        else
            draw.RoundedBox(10, 2, 2, w-4, h-4, CleanTickets.Config.TabPanelBackgroundColor)
        end
    end
    
    function CleanTickets.GUI.TLP_RefreshTickets()
        item_list:Clear()

        table.foreachi(ticketslist, function(v) 
            -- FILTERS CHECK
            local v = ticketslist[v]
            if (filters_data.status ~= "") then
                if(v.status ~= filters_data.status) then
                    return
                end
            end 
            if (filters_data.player ~= nil) then
                if(v.sender.steamid ~= filters_data.player) then
                    return
                end
            end 
            if (filters_data.subject ~= "") then
                if(v.subject ~= filters_data.subject) then
                    return
                end
            end
            if (filters_data.date ~= "") then
                if(v.date ~= filters_data.date) then
                    return
                end
            end

            local ticket_item = vgui.Create("DPanel", item_list)
            ticket_item:SetSize( listpanel:GetWide()/2 - 30, 150)
            ticket_item.Paint = function(s, w, h)
                draw.RoundedBox(15, 0, 0, w, h, CleanTickets.Config.MainFrameBackground)
                draw.SimpleText(v.subject, "CleanTickets_Font25", 10, 3, Color(255,255,255,255))
                CleanTickets.GUI.Utils.DrawLine(0, 30, w, 30, Color(255,255,255))
            end

            local status_data = CleanTickets.GUI.Utils.GetTicketStatus(v.status)

            local status_label = vgui.Create("DButton", ticket_item)
            surface.SetFont("CleanTickets_Font18")
            status_label:SetSize(60, 18)
            status_label:SetPos(ticket_item:GetWide() - status_label:GetWide() - 10, 7.6)
            status_label:SetFont("CleanTickets_Font18")
            status_label:SetText(status_data[1])
            status_label:SetColor(Color(255,255,255))
            status_label.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, status_data[2])
            end

            ticketbut(v, ticket_item)
            

            local ticketcontent = vgui.Create( "RichText", ticket_item )
            ticketcontent:SetPos(0,31)
            local wc, hc = ticketcontent:GetPos()
            ticketcontent:SetSize(ticket_item:GetWide() - 100, ticket_item:GetTall()-hc)
            
            function ticketcontent:PerformLayout()
                self:SetFontInternal("CleanTickets_Font22")
                self:SetFGColor(255, 255, 255, 255) 
                self:SetBGColor(255,255,255,0)
            end
            ticketcontent:AppendText(CleanTickets.Lang.TICKET_CREATOR .. v.sender.name .. "\n")
            ticketcontent:AppendText(CleanTickets.Lang.TICKET_DESCRIPTION .. v.message .. "\n")
            ticketcontent:AppendText(CleanTickets.Lang.TICKET_DATE .. v.date .. "\n")
            ticketcontent:AppendText(CleanTickets.Lang.TICKET_TIME .. v.time .. "\n")
            if next(v.players) then
                ticketcontent:AppendText(CleanTickets.Lang.TICKET_SELECTEDPLAYER .. "\n")
                for k, v in pairs(v.players) do
                    ticketcontent:AppendText("   - "..v[1].."\n")
                end

            end
            if v.admin then
                ticketcontent:AppendText(CleanTickets.Lang.TICKET_TAKENBY .. v.admin.name)
            end
            
            ticketcontent.Paint = function(self, w, h)
                draw.RoundedBoxEx(15, 0, 0, w, h, Color(0,0,0,150), false, false, true, false)
            end

            item_list:AddItem(ticket_item)
        end)
    end
    CleanTickets.GUI.TLP_RefreshTickets()
    return listpanel
end

        ----------------------------------------------
        --                                          --
        --                  FILTERS                 --
        --                                          --
        ----------------------------------------------

function CleanTickets.GUI.Utils.DisplayFilters(panel, ticketslist, callback)
    local filters_data = {
        status = "",
        player = nil,
        subject = "",
        date = ""
    }
    
    local filters_list = vgui.Create("DHorizontalScroller", panel)
    filters_list:SetPos( 0, 0 )
    filters_list:SetSize( panel:GetWide(), panel:GetTall() )
    filters_list:SetOverlap(-10)
    
    local function filter_element(parent, name, ypos, choices, onselect, sortitems)
        local element_container = CleanTickets.GUI.Utils.DrawContainer(parent, CleanTickets.Config.MainFrameBackground, {["x"] = parent:GetWide(), ["y"] = 26}, {["x"] = 0, ["y"] = ypos})
        local element_label = CleanTickets.GUI.Utils.DrawLabel(element_container, name, "CleanTickets_Font24", false, {["x"]=0, ["y"] = 0}, LEFT, {5,0,0,0})
        local element_dropdown = vgui.Create("DComboBox", element_container)
        element_dropdown:SetSize(100, 25)
        element_dropdown:Dock(LEFT)
        element_dropdown:DockMargin(10,1,0,1)
        element_dropdown:SetColor(CleanTickets.Config.TextColor)
        element_dropdown:SetFont("CleanTickets_Font22")
        element_dropdown:SetSortItems(sortitems)
        element_dropdown.Paint = function(self, w, h)
            if (self:IsMenuOpen()) then
                draw.RoundedBox(7, 0, 0, w, h, CleanTickets.Config.AccentColor)
            else
                draw.RoundedBox(7, 0, 0, w, h, CleanTickets.Config.TabPanelBackgroundColor)
            end
        end

        element_dropdown:AddChoice("", nil, true)
        choices(element_dropdown)

        element_container:SetSize(element_label:GetWide()+element_dropdown:GetWide()+20, 26)
        element_container:SetPos(parent:GetWide()/2-element_container:GetWide()/2, ypos)
        
        
        function element_dropdown:OnSelect(index, text, data)
            onselect(index, text, data)
        end

        return element_container
    end

    local status_element = filter_element(filters_list, CleanTickets.Lang.FILTER_STATUS, 0, function(element_dropdown) 
        element_dropdown:AddChoice("Open")
        element_dropdown:AddChoice("Taken")
        element_dropdown:AddChoice("Closed")
    end, function(index, text, data) 
        filters_data.status = text
        if callback then
            callback(filters_data)
        end
    end, false)

    
    local player_element = filter_element(filters_list, CleanTickets.Lang.FILTER_PLAYER, 0, function(element_dropdown) 
        for k, v in pairs(ticketslist) do
            if (element_dropdown:GetOptionTextByData(v.sender.steamid) == v.sender.steamid) then
                element_dropdown:AddChoice(v.sender.name, v.sender.steamid)
            end
        end
    end, function(index, text, data) 
        filters_data.player = data
        if callback then
            callback(filters_data)
        end
    end, true)

    local subject_element = filter_element(filters_list, CleanTickets.Lang.FILTER_SUBJECT, 0, function(element_dropdown) 
        for i = 1, #CleanTickets.Config.SubjectsList do
            element_dropdown:AddChoice(CleanTickets.Config.SubjectsList[i])
        end
    end, function(index, text, data) 
        filters_data.subject = text
        if callback then
            callback(filters_data)
        end
    end, true)

    local date_element = filter_element(filters_list, CleanTickets.Lang.FILTER_DATE, 0, function(element_dropdown) 
        for k, v in pairs(ticketslist) do
            if (element_dropdown:GetOptionTextByData(" " .. v.date) == " " .. v.date) then
                element_dropdown:AddChoice(v.date, " " .. v.date)
            end
        end
    end, function(index, text, data) 
        filters_data.date = text
        if callback then
            callback(filters_data)
        end
    end, true)


    filters_list:AddPanel(status_element)
    filters_list:AddPanel(player_element)
    filters_list:AddPanel(subject_element)
    filters_list:AddPanel(date_element)

    filters_list:InvalidateLayout( true )
    filters_list:SizeToChildren( true, true )

    return filters_list
end


        ----------------------------------------------
        --                                          --
        --               CHOICE POPUP               --
        --                                          --
        ----------------------------------------------


function CleanTickets.GUI.Utils.DisplayChoicePopup(pos, title, content, closetxt, validtxt, onclose, onvalid)
    local popup = vgui.Create("DFrame")
    popup:SetSize(250, 150)
    if pos then
        popup:SetPos(pos.x, pos.y)
    else
        popup:SetPos(ScrW() / 2 - 125, ScrH() / 2 - 75)
    end
    popup:ShowCloseButton(false)
    popup:MakePopup()
    popup:SetTitle(" ")
    popup.Paint = function(self, w, h)
        draw.RoundedBox(15, 0, 0, w, h, CleanTickets.Config.TicketBackground)
        draw.SimpleText(title, "CleanTickets_Font25", 10, 5, Color(255, 255, 255))
        CleanTickets.GUI.Utils.DrawLine(0, 35, w, 35, Color(255, 255, 255, 255))
    end


    local CloseButton = vgui.Create("DButton", popup)
    CloseButton:SetPos(popup:GetWide() - 30, 7)
    CloseButton:SetSize(20, 20)
    CloseButton:SetText("")
    CloseButton:SetTooltip(CleanTickets.Lang.BTN_CLOSE)
    CloseButton.DoClick = function()
        popup:Close()
        if onclose then
            onclose()
        end
    end
    CloseButton.Paint = function(s, w, h)
        draw.RoundedBox(100, 0, 0, w, h, CleanTickets.Config.CloseButtonColor)
    end

    local text = vgui.Create( "RichText", popup )
    text:SetPos(0,36)
    text:SetVerticalScrollbarEnabled( false )
    local wc, hc = text:GetPos()
    text:SetSize(popup:GetWide(), popup:GetTall()-hc-40)
    function text:PerformLayout()
        self:SetFontInternal("CleanTickets_Font22")
        self:SetFGColor(255, 255, 255, 255) 
    end
    text:AppendText(content)

    text.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,150))
    end

    local CancelButton = vgui.Create("DButton", popup)
    CancelButton:SetPos(0, popup:GetTall()-40)
    CancelButton:SetSize(popup:GetWide()/2, 40)
    CancelButton:SetText(closetxt)
    CancelButton:SetFont("CleanTickets_Font25")
    CancelButton:SetColor(Color(255,255,255))
    CancelButton.DoClick = function()
        popup:Close()
        if onclose then
            onclose()
        end
    end
    CancelButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(15, 0, 0, w, h, CleanTickets.Config.CloseButtonColor, false, false, true, false) 
    end

    local ContinueButton = vgui.Create("DButton", popup)
    ContinueButton:SetPos(popup:GetWide()/2, popup:GetTall()-40)
    ContinueButton:SetSize(popup:GetWide()/2, 40)
    ContinueButton:SetText(validtxt)
    ContinueButton:SetFont("CleanTickets_Font25")
    ContinueButton:SetColor(Color(255,255,255))
    ContinueButton.DoClick = function()
        popup:Close()
        if onvalid then
            onvalid()
        end
    end
    ContinueButton.Paint = function(s, w, h)
        draw.RoundedBoxEx(15, 0, 0, w, h, Color(0,255,0), false, false, false, true) 
    end
end



        ----------------------------------------------
        --                                          --
        --                   FONTS                  --
        --                                          --
        ----------------------------------------------

function CleanTickets.GUI.Utils.GenerateFonts(min, max, font, weight)
    for i = min, max do 
        surface.CreateFont("CleanTickets_Font" .. i, {
            font = font,
            size = i,
            weight = weight
        })
    end
end

CleanTickets.GUI.Utils.GenerateFonts(12, 72, "Asap", 400)
