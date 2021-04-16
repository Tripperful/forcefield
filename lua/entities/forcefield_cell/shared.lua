ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Force Field Cell"
ENT.Author = "Tripperful"
ENT.Spawnable = true
ENT.Category = "Force Fields"
ENT.ClassName = "forcefield_cell"
ForceField.ProtectEntityClass(ENT)

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end