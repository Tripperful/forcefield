AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/effects/teleporttrail.mdl")
    self:PhysInitField()

    if ForceField.MaxHealth then
        self:SetMaxHealth(ForceField.MaxHealth)
        self:SetHealth(ForceField.MaxHealth)
    end
end

function ENT:OnTakeDamage(Dmg)
    if ForceField.MaxHealth then
        self:SetHealth(self:Health() - Dmg:GetDamage())

        if self:Health() <= 0 then
            if ForceField.DropOnBreak then
                self:Unmount()
            else
                self:Remove()
            end
        end
    end

    local Pos = Dmg:GetDamagePosition()
    local Eff = EffectData()
    Eff:SetOrigin(Pos)
    Eff:SetNormal(-Dmg:GetDamageForce())
    util.Effect("cball_bounce", Eff)
end

function ENT:Unmount()
    if not self.DBID then
        local Cell = self.Cell

        if not (Cell and Cell:IsValid()) then
            Cell = ents.Create("forcefield_cell")
            Cell.Field = self
            Cell:Setowning_ent(self:Getowning_ent())
            Cell:Spawn()
            Cell:Activate()
        end

        Cell:SetMoveType(MOVETYPE_VPHYSICS)
        Cell:SetNotSolid(false)
        Cell:SetNoDraw(false)
        Cell:SetPos(self:GetPos())
        Cell:SetAngles(Angle(0, 0, 0))
        Cell:PhysWake()
        Cell.Field = nil
        self.Cell = nil
    end

    self:Remove()
end

hook.Add("ShutDown", "ForceField.ShutDown", function()
    ForceField.ShutDown = true
end)

hook.Add("PreCleanupMap", "ForceField.PreCleanupMap", function()
    ForceField.ShutDown = true
end)

hook.Add("PostCleanupMap", "ForceField,PostCleanupMap", function()
    ForceField.ShutDown = false
    ForceField.LoadFields()
end)

function ENT:OnRemove()
    ForceField.ClearAccessInfo(self:EntIndex())

    if not ForceField.ShutDown then
        ForceField.Unstore(self)
    end

    if self.Cell and self.Cell:IsValid() then
        self.Cell:Remove()
    end
end