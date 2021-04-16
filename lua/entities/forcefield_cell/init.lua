AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/maxofs2d/hover_basic.mdl")
    self:PhysicsInitSphere(8, "metal")
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local Phys = self:GetPhysicsObject()
    Phys:SetDamping(5, 0.1)
    Phys:SetMass(50)
    Phys:Wake()
    self:SetUseType(SIMPLE_USE)
end

local TraceMins, TraceMaxs = Vector(-2, -2, -2), Vector(2, 2, 2)

function ENT:Think()
    local Pos = self:WorldSpaceCenter()

    local Tr = {
        start = Pos,
        endpos = Pos + Vector(0, 0, -20),
        filter = self,
        mask = MASK_SOLID,
        mins = TraceMins,
        maxs = TraceMaxs
    }

    Tr = util.TraceHull(Tr)
    self:GetPhysicsObject():ApplyForceCenter(Vector(0, 0, 2000 * (1 - Tr.Fraction)))
    self:NextThink(CurTime())

    return true
end

function ENT:Use(Ply)
    if Ply:CanUseForceFields(self) then
        ForceField.SendCellUse(self, Ply)
    else
        DarkRP.notify(Ply, NOTIFY_ERROR, 5, ForceField.Lang.cantinstall)
    end
end

function ENT:Install(Settings)
    if IsValid(self.Field) then return end
    local Field = ents.Create("forcefield")
    Field.Cell = self
    self.Field = Field
    Field:Setowning_ent(Settings.Owner)
    Field:SetEnabled(true)
    Field:SetPos(Settings.Pos)
    Field:SetAngles(Settings.Ang)
    Field:SetPos(Field:LocalToWorld(Vector(0, 0, Settings.Height / 2)))
    Field:SetWidth(Settings.Width)
    Field:SetHeight(Settings.Height)
    Field:Spawn()
    Field:Activate()
    self:GetPhysicsObject():Sleep()
    self:SetPos(Field:GetPos())
    self:SetAngles(Angle(0, 0, 0))
    self:SetMoveType(MOVETYPE_NONE)
    self:SetNotSolid(true)
    self:SetNoDraw(true)
end

function ENT:OnRemove()
    if self.Field and self.Field:IsValid() and not self.Field.DBID then
        self.Field:Remove()
    end
end