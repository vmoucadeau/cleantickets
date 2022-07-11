

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


--[[
    CONTAINER

    This is a container class for the GUI.
    Settings:
        - settings.parent
        - settings.color
        - settings.size
        - settings.pos
        - settings.title
        - settings.paint
        - settings.dock
        - settings.margin
]]

function CleanTickets.GUI.Utils.DrawContainer(settings)
    local title = settings.title or ""
    local container = vgui.Create("DPanel", settings.parent)
    if settings.dock then
        container:Dock(settings.dock)
        if settings.margin then
            container:DockMargin(settings.margin[1], settings.margin[2], settings.margin[3], settings.margin[4])
        end
    end
    if settings.size then 
        container:SetSize(settings.size.x, settings.size.y)
    end
    if settings.pos then
        container:SetPos(settings.pos.x, settings.pos.y)
    end
    if(settings.paint) then
        container.Paint = settings.paint
    else
        container.Paint = function(s,w, h)
            if settings.color then
                draw.RoundedBox(10, 0, 0, w, h, settings.color)
            end
            if settings.title then
                local wt, ht = surface.GetTextSize(settings.title)
                draw.SimpleText(settings.title, "CleanTickets_Font25", w/2, 10,
                    Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end
    return container
end

--[[
    LABEL

    This is a label class for the GUI.
    Settings:
        - settings.parent
        - settings.text
        - settings.color
        - settings.font
        - settings.size
        - settings.pos
        - settings.dock
        - settings.margin
        - settings.sizetocontent
        - settings.align
]]

function CleanTickets.GUI.Utils.DrawLabel(settings)
    local label = vgui.Create( "DLabel", settings.parent )
	if settings.dock then
		label:Dock(settings.dock)
		if settings.margin then
			label:DockMargin(settings.margin[1], settings.margin[2], settings.margin[3], settings.margin[4])
		end
	end
	label:SetColor(Color(255, 255, 255, 255))
	label:SetFont(settings.font or "CleanTickets_Font22")
	label:SetText(settings.text)
	if settings.size then
		label:SetSize(settings.size.x, settings.size.y)
    else
        label:SizeToContents(20)
    end
    if settings.pos then
	    label:SetPos(settings.pos.x or 0, settings.pos.y or 0)
    end
	
	if settings.sizetocontent then
		if not settings.size.x then
			label:SizeToContentsX(20)
		end
		if not settings.size.y then
			label:SizeToContentsY(20)
		end
	end
	if settings.align then
		label:SetContentAlignment(settings.align)
	end
    if settings.paint then
        label.Paint = settings.paint
    end

	return label
end

--[[
    COMBO BOX

    Settings arrangement :
        settings.parent
        settings.textcolor
        settings.font
        settings.size
        settings.pos
        settings.dock
        settings.margin
        settings.items
        settings.onselect
        settings.paint
        settings.sortitems

]]


function CleanTickets.GUI.Utils.DrawComboBox(settings)
    local combo = vgui.Create( "DComboBox", settings.parent )
    
    combo:SetColor(settings.textcolor)
    combo:SetFont(settings.font)
    combo:SetSize(settings.size["x"] or 0, settings.size["y"] or 0)
    if(settings.sortitems ~= nil) then
        combo:SetSortItems(settings.sortitems)
    end
    if settings.dock then
        combo:Dock(settings.dock)
        if settings.margin then
            combo:DockMargin(settings.margin[1], settings.margin[2], settings.margin[3], settings.margin[4])
        end
    end

    if settings.paint then
        combo.Paint = settings.paint
    else
        combo.Paint = function(s,w, h)
            if (s:IsMenuOpen()) then
                draw.RoundedBox(10, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor)
            else
                draw.RoundedBox(10, 0, 0, w, h, CleanTickets.Config.AccentColor)
            end
        end
    end

    for i = 1, #settings.items do
        combo:AddChoice(settings.items[i][1], settings.items[i][2] or nil)
    end

    combo:ChooseOptionID(1)
    
    function combo:OnSelect(index, value, data)
        settings.onselect(index, value, data)
    end

    return combo

end

--[[
    TEXTBOX

    Settings arrangement :
        - settings.parent
        - settings.textcolor
        - settings.font
        - settings.size
        - settings.pos
        - settings.dock
        - settings.margin
        - settings.onvaluechange
        - settings.multiline
        - settings.maxcharacters


]]


function CleanTickets.GUI.Utils.DrawTextBox(settings)
    local msgfocused = false

    local textboxcontainer = CleanTickets.GUI.Utils.DrawContainer({
        parent = settings.parent,
        color = Color(0,0,0,0),
        size = settings.size or {x=0,y=0},
        paint = function(s,w, h)
            if (msgfocused) then
                draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor)
            else
                draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentColor)
            end
            draw.RoundedBox(8, 2, 2, w - 4, h - 4, CleanTickets.Config.TabPanelBackgroundColor)
        end
    })

    if settings.dock then
        textboxcontainer:Dock(settings.dock)
        if settings.margin then
            textboxcontainer:DockMargin(settings.margin[1], settings.margin[2], settings.margin[3], settings.margin[4])
        end
    end

    local textbox = vgui.Create( "DTextEntry", textboxcontainer )
    
    textbox:SetFont(settings.font)
    textbox:SetUpdateOnType(true)
    if settings.multiline then
        textbox:SetMultiline(true)
    end
    textbox:Dock(1)
    textbox:DockMargin(3,3,3,3)

    textbox.Paint = function(self, w, h)
        self:DrawTextEntryText(Color(255, 255, 255), Color(30, 130, 255), Color(255, 255, 255))
        if (textbox:IsEditing()) then
            msgfocused = true
        else
            msgfocused = false
        end
    end
    function textbox:OnValueChange(value)
        if settings.maxcharacters and string.len(value) == settings.maxcharacters then
            textbox.AllowInput = function(s, val) return true end
            CleanTickets.ClFuncs.ShowNotif(CleanTickets.Lang.PANEL_TEXTBOXLIMIT, 0, 3, nil)
        else
            textbox.AllowInput = function(s, val) return false end
        end
        settings.onvaluechange(value)
    end

    return textboxcontainer
end

--[[
    BUTTONS

    Settings arrangement :
        settings.parent
        settings.text
        settings.font
        settings.size
        settings.pos
        settings.dock
        settings.margin
        settings.items
        settings.doclick
        settings.paint
        settings.SizeToContentsX,
        settings.SizeToContentsY

]]

function CleanTickets.GUI.Utils.DrawButton(settings)
    local button = vgui.Create( "DButton", settings.parent )    
    button:SetFont(settings.font or "CleanTickets_Font22")
    button:SetColor(settings.color or CleanTickets.Config.TextColor)
    if settings.size then    
        button:SetSize(settings.size.x or 0, settings.size.y or 0)
    end
    if settings.dock then
        button:Dock(settings.dock)
        if settings.margin then
            button:DockMargin(settings.margin[1], settings.margin[2], settings.margin[3], settings.margin[4])
        end
    end
    if settings.pos then
        button:SetPos(settings.pos.x or 0, settings.pos.y or 0)
    end
    if settings.paint then
        button.Paint = settings.paint
    else
        button.Paint = function(s,w, h)
            if s:IsHovered() then
                draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentDarkerColor)
            else
                draw.RoundedBox(8, 0, 0, w, h, CleanTickets.Config.AccentColor)
            end
        end
    end
    button:SetText(settings.text or "")
    function button:DoClick()
        settings.doclick()
    end

    if settings.SizeToContentsX then
        button:SizeToContentsX(settings.SizeToContentsX)
    end
    if settings.SizeToContentsY then
        button:SizeToContentsY(settings.SizeToContentsY)
    end

    if settings.tooltip then
        button:SetTooltip(settings.tooltip)
    end

    return button
end

function CleanTickets.GUI.Utils.DrawCloseButton(settings)
    local btn_close = CleanTickets.GUI.Utils.DrawButton({
        parent = settings.parent,
        tooltip = CleanTickets.Lang.PANEL_CLOSE,
        size = {x=20,y=20},
        pos = settings.pos,
        doclick = settings.doclick,
        paint = function(s, w, h)
            draw.RoundedBox(100, 0, 0, w, h, CleanTickets.Config.CloseButtonColor)
        end
        
    })
    return btn_close
end

function CleanTickets.GUI.Utils.GetTicketStatus(status)
    local status_color
    local status_text
    if status == "Open" then
        status_color = CleanTickets.Config.OpenColor
        status_text = CleanTickets.Lang.TICKETSTATUS_OPEN
    else 
        status_color = CleanTickets.Config.TakenColor
        status_text = CleanTickets.Lang.TICKETSTATUS_TAKEN
    end

    return {status_text, status_color}
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
        draw.RoundedBox(16, 0, 0, w, h, CleanTickets.Config.TicketOutline)	
        draw.RoundedBox(16, 1, 1, w-2, h-2, CleanTickets.Config.TicketBackground)
        draw.SimpleText(title, "CleanTickets_Font25", 10, 5, Color(255, 255, 255))
        CleanTickets.GUI.Utils.DrawLine(0, 35, w, 35, CleanTickets.Config.TicketOutline)
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
        draw.RoundedBoxEx(16, 0, 0, w, h, CleanTickets.Config.CloseButtonColor, false, false, true, false) 
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
        draw.RoundedBoxEx(16, 0, 0, w, h, CleanTickets.Config.OpenColor, false, false, false, true) 
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
