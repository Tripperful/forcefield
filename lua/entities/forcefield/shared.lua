ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Force Field"
ENT.Author = "Tripperful"
ENT.Spawnable = false
ENT.Category = "Force Fields"
ENT.ClassName = "forcefield"
ForceField.ProtectEntityClass(ENT)

function ENT:PhysInitField()
    local W, H = self:GetWidth(), self:GetHeight()
    local HW, HH = W / 2, H / 2

    self:PhysicsFromMesh({
        {
            pos = Vector(0, -HW, -HH)
        },
        {
            pos = Vector(0, HW, -HH)
        },
        {
            pos = Vector(0, HW, HH)
        },
        {
            pos = Vector(0, HW, HH)
        },
        {
            pos = Vector(0, -HW, HH)
        },
        {
            pos = Vector(0, -HW, -HH)
        }
    })

    self:EnableCustomCollisions(true)
    self:SetCustomCollisionCheck(true)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local boundsMin, boundsMax = Vector(-5, -HW - 5, -HH - 5), Vector(5, HW + 5, HH + 5)

    if CLIENT then
        self:SetRenderBounds(boundsMin, boundsMax)
    else
        self:SetCollisionBounds(boundsMin, boundsMax)
    end

    local Phys = self:GetPhysicsObject()
    Phys:SetMaterial("player_control_clip")
    Phys:EnableMotion(false)
    Phys:Sleep()
end

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Bool", 0, "Enabled")
    self:NetworkVar("Bool", 1, "AllowByDefault")
    self:NetworkVar("Int", 0, "Width")
    self:NetworkVar("Int", 1, "Height")
end

function ENT:Think()
    local Phys = self:GetPhysicsObject()

    if not (Phys and Phys:IsValid()) then
        self:PhysInitField(self:GetWidth(), self:GetHeight())
    end
end