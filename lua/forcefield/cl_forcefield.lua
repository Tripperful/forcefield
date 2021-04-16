local MarkerMin = Vector(-5, -5, -5)
local MarkerMax = Vector(5, 5, 5)
local Red = Color(255, 0, 0, 255)
local Green = Color(0, 255, 0, 255)
local Hint1 = ForceField.Lang.corner1
local Hint2 = ForceField.Lang.corner2
local Hint3 = ForceField.Lang.setheight
local Hint4 = ForceField.Lang.toofar
local Hint5 = ForceField.Lang.rmbcancel
local Hint6 = ForceField.Lang.tooclose
local Hint7 = ForceField.Lang.selectang

local function DrawHint(Text)
    cam.Start2D()
    ForceField.DrawHint(ScrW() / 2, ScrH() / 2 - 80, Text)
    ForceField.DrawHint(ScrW() / 2, ScrH() / 2 - 60, Hint5)
    cam.End2D()
end

function ForceField.InstallThink()
    local State = ForceField.InstallState
    if not State then return end
    local Field = ForceField.InstallingField
    if not (Field and Field:IsValid()) then return end
    local Pos = LocalPlayer():GetEyeTrace().HitPos
    local TooFar, TooClose

    if State == 1 then
        render.DrawWireframeBox(Pos, Angle(0, 0, 0), MarkerMin, MarkerMax, Green, true)
        DrawHint(Hint1)
    elseif State == 2 then
        local Dist = (Pos - Field.Pos1):Length()
        TooFar = Dist > ForceField.MaxWidth
        TooClose = Dist < ForceField.MinWidth
        render.DrawWireframeBox(Field.Pos1, Angle(0, 0, 0), MarkerMin, MarkerMax, Green, true)
        render.DrawWireframeBox(Pos, Angle(0, 0, 0), MarkerMin, MarkerMax, (TooFar or TooClose) and Red or Green, true)
        DrawHint(TooFar and Hint4 or TooClose and Hint6 or Hint2)
    elseif State == 3 then
        local W = Field.Settings.Width
        local H = Field.Settings.Height
        local HitPos = util.IntersectRayWithOBB(EyePos(), EyeAngles():Forward() * 10000, Field.Settings.Pos, Field.Settings.Ang, Vector(-2, -2048, 0), Vector(2, 2048, ForceField.MaxHeight))

        if HitPos then
            local LPos = WorldToLocal(HitPos, Angle(), Field.Settings.Pos, Field.Settings.Ang)
            H = math.Clamp(LPos.z, ForceField.MinHeight, ForceField.MaxHeight)
            Field.Settings.Height = H
        end

        TooFar = H > ForceField.MaxHeight
        TooClose = H < ForceField.MinHeight
        render.DrawWireframeBox(Field.Settings.Pos, Field.Settings.Ang, Vector(-2, -W / 2, 0), Vector(2, W / 2, H), (TooFar or TooClose) and Red or Green, true)
        DrawHint(TooFar and Hint4 or TooClose and Hint6 or Hint3)
    elseif State == 4 then
        local W = Field.Settings.Width
        local H = Field.Settings.Height
        local EyeAng = EyeAngles()
        local DAng = EyeAng.y - ForceField.TempAng.y
        Field.Settings.Ang.p = input.IsKeyDown(KEY_LSHIFT) and math.Round(DAng * 4 / 45) * 45 or (DAng * 4)
        render.DrawWireframeBox(Field.Settings.Pos, Field.Settings.Ang, Vector(-2, -W / 2, 0), Vector(2, W / 2, H), Green, true)
        DrawHint(Hint7)
    end

    if TooFar or TooClose then
        Field.Settings.TooFar = true
    else
        Field.Settings.TooFar = nil
    end
end

hook.Remove("PostDrawOpaqueRenderables", "ForceField.InstallThink")
hook.Add("PreDrawOpaqueRenderables", "ForceField.InstallThink", ForceField.InstallThink)

local function InstallKeyPressed(Key)
    if Key == IN_ATTACK then
        local Field = ForceField.InstallingField
        if not (Field and Field:IsValid()) then return end

        if not Field.Settings.TooFar then
            local State = ForceField.InstallState

            if State == 1 then
                Field.Pos1 = LocalPlayer():GetEyeTrace().HitPos
                ForceField.InstallState = 2
            elseif State == 2 then
                local Pos2 = LocalPlayer():GetEyeTrace().HitPos
                Field.Settings.Pos = (Pos2 + Field.Pos1) / 2
                local Diff = Pos2 - Field.Pos1
                local Forward = Diff:Cross(Vector(0, 0, 1)):GetNormalized()
                local Up = -Diff:Cross(Forward):GetNormalized()
                Field.Settings.Ang = Forward:AngleEx(Up)
                Field.Settings.Width = Diff:Length()
                Field.Settings.Height = 64
                ForceField.InstallState = 3
            elseif State == 3 then
                ForceField.TempAng = EyeAngles()
                ForceField.InstallState = 4
            elseif State == 4 then
                Field:Install()
                ForceField.InstallState = 5
            end
        end

        return true
    elseif Key == IN_ATTACK2 then
        if ForceField.InstallingField then
            ForceField.InstallingField.Settings = nil
            ForceField.InstallingField = nil
            ForceField.InstallState = nil
            KeyTrap.StopKeyCapturing()
        end

        return true
    end
end

hook.Add("InputKeyPressed", "ForceField.InstallKeyPressed", InstallKeyPressed)

local function InstallKeyHeld(Key)
    if Key == IN_ATTACK and ForceField.InstallState then return true end
end

hook.Add("InputKeyHeld", "ForceField.InstallKeyHeld", InstallKeyHeld)

local function InstallKeyReleased(Key)
    if Key == IN_ATTACK and ForceField.InstallState == 5 then
        ForceField.InstallState = nil
        KeyTrap.StopKeyCapturing()
    end
end

hook.Add("InputKeyReleased", "ForceField.InstallKeyReleased", InstallKeyReleased)

function ForceField.SendToInstall(Cell)
    net.Start("ForceField.InstallCell")
    net.WriteEntity(Cell)
    net.WriteVector(Cell.Settings.Pos)
    net.WriteAngle(Cell.Settings.Ang)
    net.WriteUInt(Cell.Settings.Width, 32)
    net.WriteUInt(Cell.Settings.Height, 32)
    net.SendToServer()
end

function ForceField.UnmountField(Field)
    if not (Field and Field:IsValid()) then return end
    net.Start("ForceField.UnmountField")
    net.WriteEntity(Field)
    net.SendToServer()
end

function ForceField.EnableField(Field, Enable)
    if not (Field and Field:IsValid()) then return end
    net.Start("ForceField.EnableField")
    net.WriteEntity(Field)
    net.WriteBool(Enable)
    net.SendToServer()
    Field:SetEnabled(Enable)
end

function ForceField.AllowByDefault(Field, Allow)
    if not (Field and Field:IsValid()) then return end
    net.Start("ForceField.AllowByDefault")
    net.WriteEntity(Field)
    net.WriteBool(Allow)
    net.SendToServer()
    Field:SetAllowByDefault(Allow)
end

function ForceField.StoreField(Field)
    if not (Field and Field:IsValid()) then return end
    net.Start("ForceField.StoreField")
    net.WriteEntity(Field)
    net.SendToServer()
end

net.Receive("ForceField.CellUse", function(Len)
    local Cell = net.ReadEntity()

    if Cell and Cell:IsValid() then
        Cell:StartInstalling()
    end
end)