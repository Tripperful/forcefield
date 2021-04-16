local GUI = ForceField.GUI
local Lang = ForceField.Lang
local TextColor = GUI.TextColor
local FieldMenuColor = GUI.FieldMenuColor
local FilterMenuColor = GUI.FilterMenuColor
local CloseButtonColor = GUI.CloseButtonColor
local UnmountButtonColor = GUI.UnmountButtonColor
local StoreButtonColor = GUI.StoreButtonColor
local FilterButtonColor = GUI.FilterButtonColor
local ValueButtonColor = GUI.ValueButtonColor
local ValueButtonRestrictColor = GUI.ValueButtonRestrictColor
local ValueButtonAllowColor = GUI.ValueButtonAllowColor
local HintBGColor = GUI.HintBGColor
local HintColor = GUI.HintColor
local CornerRadius = GUI.CornerRadius
local InvalidFilterText = "<INVALID FILTER>"
local InvalidValueText = "<INVALID VALUE>"
local TextAllow = Lang.allow
local TextRestrict = Lang.restrict
local TextEnabled = Lang.enabled
local TextAllowByDefault = Lang.allow_by_default
local TextNotAllowByDefault = Lang.not_allow_by_default
local TextDisabled = Lang.disabled
local TextDontFilter = Lang.dontfilter
local TextClose = Lang.close
local TextUnmount = Lang.unmount
local TextStore = Lang.store
local TextForceField = Lang.forcefield
local TextEditAccess = Lang.editaccess
local ScreenSizeIcon = Material("vgui/cursors/sizenwse")

local function PaintShiftedRound(X, Y, W, H, Shift, Col)
    draw.RoundedBox(CornerRadius, X, Y, W - Shift, H - Shift, Col)
    draw.RoundedBox(CornerRadius, X + Shift, Y + Shift, W - Shift, H - Shift, Col)
end

GUI.DValueButton = vgui.RegisterTable({
    Init = function(self)
        self:SetFont("ForceField.FilterList")
        self:SetTextColor(TextColor)
        self:SetHeight(24)
        self:SetText(InvalidValueText)
    end,
    SetValue = function(self, Value)
        if self.Filter then
            self.Value = Value
            self:SetText(self.Filter.PrintValue(Value))
        else
            self.Value = 0
            self:SetText(InvalidValueText)
        end
    end,
    GetValue = function(self) return self.Value end,
    Paint = function(self, W, H)
        local Col = ValueButtonColor

        if self.State == true then
            Col = ValueButtonAllowColor
        elseif self.State == false then
            Col = ValueButtonRestrictColor
        end

        PaintShiftedRound(2, 2, W - 4, H - 4, 1, Col)
    end,
    DoClick = function(self)
        if self.State == nil then
            self.State = true
            self:SetTooltip(TextAllow)
        elseif self.State == false then
            self.State = nil
            self:SetTooltip(TextDontFilter)
        else
            self.State = false
            self:SetTooltip(TextRestrict)
        end

        self.Filter.SetAccessRaw(self.FieldIndex, self.Value, self.State)
    end
}, "DButton")

AccessorFunc(GUI.DValueButton, "FieldIndex", "FieldIndex")
AccessorFunc(GUI.DValueButton, "Filter", "Filter")

GUI.DCloseButton = vgui.RegisterTable({
    Init = function(self)
        self:SetFont("ForceField.SmallButton")
        self:SetTextColor(TextColor)
        self:SetText(TextClose)
        self:SetTooltip(TextClose)
    end,
    Paint = function(self, W, H)
        draw.RoundedBoxEx(CornerRadius, 1, 1, W - 2, H - 2, CloseButtonColor, false, true, true, false)
    end,
    DoClick = function(self)
        self:GetParent():Remove()
    end
}, "DButton")

GUI.DUnmountButton = vgui.RegisterTable({
    Init = function(self)
        self:SetFont("ForceField.SmallButton")
        self:SetTextColor(TextColor)
        self:SetText(TextUnmount)
        self:SetTooltip(TextUnmount .. " " .. TextForceField)
    end,
    Paint = function(self, W, H)
        draw.RoundedBoxEx(CornerRadius, 1, 1, W - 2, H - 2, UnmountButtonColor, false, false, true, false)
    end,
    DoClick = function(self)
        local Field = Entity(self:GetParent().FieldIndex)
        ForceField.UnmountField(Field)
        self:GetParent():Remove()
    end
}, "DButton")

GUI.DEnableButton = vgui.RegisterTable({
    Init = function(self)
        self:SetFont("ForceField.SmallButton")
        self:SetTextColor(TextColor)
        self:SetText(TextEnabled)
        self.Enabled = true
        self.Col = ValueButtonAllowColor
    end,
    Paint = function(self, W, H)
        if self:GetParent().AllowByDefaultButton then
            surface.SetDrawColor(self.Col)
            surface.DrawRect(1, 1, W - 2, H - 2)
        else
            draw.RoundedBoxEx(CornerRadius, 1, 1, W - 2, H - 2, self.Col, false, true, false, false)
        end
    end,
    DoClick = function(self)
        local Field = Entity(self:GetParent().FieldIndex)
        ForceField.EnableField(Field, not self.Enabled)
        self:Update()
    end,
    Update = function(self)
        local Field = Entity(self:GetParent().FieldIndex)
        local Enabled = Field:GetEnabled()
        self:SetText(Enabled and TextEnabled or TextDisabled)
        self.Col = Enabled and ValueButtonAllowColor or ValueButtonRestrictColor
        self.Enabled = Enabled
    end
}, "DButton")

GUI.DAllowByDefaultButton = vgui.RegisterTable({
    Init = function(self)
        self:SetFont("ForceField.SmallButton")
        self:SetTextColor(TextColor)
        self:SetText(TextNotAllowByDefault)
        self.AllowByDefault = false
        self.Col = ValueButtonRestrictColor
    end,
    Paint = function(self, W, H)
        if self:GetParent().StoreButton then
            surface.SetDrawColor(self.Col)
            surface.DrawRect(1, 1, W - 2, H - 2)
        else
            draw.RoundedBoxEx(CornerRadius, 1, 1, W - 2, H - 2, self.Col, false, true, false, false)
        end
    end,
    DoClick = function(self)
        local Field = Entity(self:GetParent().FieldIndex)
        ForceField.AllowByDefault(Field, not self.AllowByDefault)
        self:Update()
    end,
    Update = function(self)
        local Field = Entity(self:GetParent().FieldIndex)
        local AllowByDefault = Field:GetAllowByDefault()
        self:SetText(AllowByDefault and TextAllowByDefault or TextNotAllowByDefault)
        self.Col = AllowByDefault and ValueButtonAllowColor or ValueButtonRestrictColor
        self.AllowByDefault = AllowByDefault
    end
}, "DButton")

GUI.DStoreButton = vgui.RegisterTable({
    Init = function(self)
        self:SetFont("ForceField.SmallButton")
        self:SetTextColor(TextColor)
        self:SetText(TextStore)
        self:SetTooltip(TextStore .. " " .. TextForceField)
    end,
    Paint = function(self, W, H)
        draw.RoundedBoxEx(CornerRadius, 1, 1, W - 2, H - 2, StoreButtonColor, false, true, false, false)
    end,
    DoClick = function(self)
        local Field = Entity(self:GetParent().FieldIndex)
        ForceField.StoreField(Field)
        self:GetParent():Remove()
    end
}, "DButton")

GUI.DFieldMenu = vgui.RegisterTable({
    Init = function(self)
        self:SetTitle("")
        self:ShowCloseButton(false)
        self:SetFieldIndex(0)
        self:DockPadding(4, 32, 4, 32)
        self:SetMinimumSize(340, 200)
        self:SetSizable(true)
        self.Scroll = self:Add("DScrollPanel")
        self.Scroll:GetVBar():SetWidth(8)
        self.List = self.Scroll:Add("DListLayout")
        self.CloseButton = self:Add(GUI.DCloseButton)
        self.CloseButton:SetSize(64, 24)
        self.UnmountButton = self:Add(GUI.DUnmountButton)
        self.UnmountButton:SetSize(64, 24)
        self.EnableButton = self:Add(GUI.DEnableButton)
        self.EnableButton:SetSize(64, 24)
        self.AllowByDefaultButton = self:Add(GUI.DAllowByDefaultButton)
        self.AllowByDefaultButton:SetSize(128, 24)

        if LocalPlayer():IsAdmin() then
            self.StoreButton = self:Add(GUI.DStoreButton)
            self.StoreButton:SetSize(64, 24)
        end
    end,
    Populate = function(self)
        self.List:Clear()

        for FilterID, Filter in pairs(ForceField.Filters) do
            local Row = self.List:Add(GUI.DFilterButton)
            Row:SetFieldIndex(self.FieldIndex)
            Row:SetFilter(Filter)
        end

        self.EnableButton:Update()
        self.AllowByDefaultButton:Update()
    end,
    PerformLayout = function(self, W, H)
        self.Scroll:Dock(FILL)
        self.List:Dock(FILL)
        self.CloseButton:SetPos(W - 64, 0)
        self.UnmountButton:SetPos(0, H - 24)
        self.EnableButton:SetPos(64, H - 24)
        self.AllowByDefaultButton:SetPos(128, H - 24)

        if self.StoreButton then
            self.StoreButton:SetPos(256, H - 24)
        end
    end,
    Paint = function(self, W, H)
        PaintShiftedRound(1, 1, W - 2, H - 2, 2, FieldMenuColor)
        PaintShiftedRound(0, 0, W, 24, 2, FilterButtonColor)
        PaintShiftedRound(0, H - 24, W, 24, 2, FilterButtonColor)
        surface.SetMaterial(ScreenSizeIcon)
        surface.DrawTexturedRect(W - 20, H - 20, 16, 16)
        draw.SimpleText(TextEditAccess, "ForceField.FieldMenuHeader", 8, 2, TextColor)
    end
}, "DFrame")

AccessorFunc(GUI.DFieldMenu, "FieldIndex", "FieldIndex")

GUI.DFilterButton = vgui.RegisterTable({
    Init = function(self)
        self:SetFont("ForceField.FilterList")
        self:SetTextColor(TextColor)
        self:SetHeight(24)
        self:SetText(InvalidFilterText)
    end,
    SetFilter = function(self, Filter)
        if Filter then
            self.Filter = Filter
            self:SetText(Filter.PrintName)
        else
            self.Filter = nil
            self:SetText(InvalidFilterText)
        end
    end,
    GetFilter = function(self) return self.Filter end,
    Paint = function(self, W, H)
        PaintShiftedRound(2, 2, W - 4, H - 4, 1, FilterButtonColor)
    end,
    DoClick = function(self)
        local FilterMenu = vgui.CreateFromTable(GUI.DFilterMenu)
        FilterMenu:SetFieldIndex(self.FieldIndex)
        FilterMenu:SetFilter(self.Filter)
        FilterMenu:Populate()
        FilterMenu:SetSize(GUI.FilterMenuWidth, GUI.FilterMenuHeight)
        FilterMenu:Center()
        FilterMenu:MakePopup()
        FilterMenu:SetKeyboardInputEnabled(false)
    end
}, "DButton")

AccessorFunc(GUI.DFilterButton, "FieldIndex", "FieldIndex")

GUI.DFilterMenu = vgui.RegisterTable({
    Init = function(self)
        self:SetTitle("")
        self:ShowCloseButton(false)
        self:SetFieldIndex(0)
        self:DockPadding(4, 32, 4, 32)
        self:SetMinimumSize(200, 200)
        self:SetSizable(true)
        self.Scroll = self:Add("DScrollPanel")
        self.Scroll:GetVBar():SetWidth(8)
        self.List = self.Scroll:Add("DListLayout")
        self.CloseButton = self:Add(GUI.DCloseButton)
        self.CloseButton:SetSize(64, 24)
    end,
    PerformLayout = function(self, W, H)
        self.Scroll:Dock(FILL)
        self.List:Dock(FILL)
        self.CloseButton:SetPos(W - self.CloseButton:GetWide(), 0)
    end,
    Populate = function(self)
        for I, Value in pairs(self.Filter.GetValues()) do
            local Row = self.List:Add(GUI.DValueButton)
            Row:SetFieldIndex(self.FieldIndex)
            Row:SetFilter(self.Filter)
            Row:SetValue(Value)
            local FieldAccess = ForceField.Access[self.FieldIndex]
            local Access = nil

            if FieldAccess and FieldAccess[self.Filter.ID] then
                Access = FieldAccess[self.Filter.ID][Value]
            end

            Row.State = Access
        end
    end,
    Paint = function(self, W, H)
        PaintShiftedRound(1, 1, W - 2, H - 2, 2, FilterMenuColor)
        PaintShiftedRound(0, 0, W, 24, 2, ValueButtonColor)
        PaintShiftedRound(0, H - 24, W, 24, 2, ValueButtonColor)
        surface.SetMaterial(ScreenSizeIcon)
        surface.DrawTexturedRect(W - 20, H - 20, 16, 16)
        draw.SimpleText(self.Filter.PrintName, "ForceField.FieldMenuHeader", 8, 2, TextColor)
    end
}, "DFrame")

AccessorFunc(GUI.DFilterMenu, "FieldIndex", "FieldIndex")
AccessorFunc(GUI.DFilterMenu, "Filter", "Filter")

function ForceField.EditAccess(FieldIndex)
    local FieldMenu = vgui.CreateFromTable(GUI.DFieldMenu)
    FieldMenu:SetFieldIndex(FieldIndex)
    FieldMenu:Populate()
    FieldMenu:SetSize(GUI.FieldMenuWidth, GUI.FieldMenuHeight)
    FieldMenu:Center()
    FieldMenu:MakePopup()
    FieldMenu:SetKeyboardInputEnabled(false)
end

function ForceField.DrawHint(X, Y, Text)
    draw.SimpleText(Text, "ForceField.HintBG", X, Y, HintBGColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(Text, "ForceField.Hint", X, Y, HintColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end