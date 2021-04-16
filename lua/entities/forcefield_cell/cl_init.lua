include("shared.lua")
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
local FieldMat = Material("effects/com_shield003a")
local Label1 = ForceField.Lang.cell
local Label2 = ForceField.Lang.use_to_install

function ENT:Draw()
    render.MaterialOverrideByIndex(1, FieldMat)
    self:DrawModel()
    local LabelPos = self:WorldSpaceCenter() + Vector(0, 0, 15)
    local Dir = LabelPos - EyePos()
    local Alpha = math.Clamp(600 - Dir:Length() * 3, 0, 255)

    if Alpha > 0 then
        local Ang = EyeAngles()
        Ang = Angle(0, Ang.yaw - 90, -Ang.pitch + 90)
        cam.Start3D2D(LabelPos, Ang, 0.15)
        ForceField.DrawHint(0, -10, Label1)
        ForceField.DrawHint(0, 10, Label2)
        cam.End3D2D()
    end
end

function ENT:StartInstalling()
    KeyTrap.StartKeyCapturing()
    ForceField.InstallingField = self
    ForceField.InstallState = 1

    self.Settings = {
        Pos = Vector(0, 0, 0),
        Ang = Angle(0, 0, 0),
        Width = 0,
        Height = 0
    }
end

function ENT:Install()
    ForceField.SendToInstall(self)
end