util.AddNetworkString("ForceField.CellUse")

function ForceField.SendCellUse(Cell, Ply)
    net.Start("ForceField.CellUse")
    net.WriteEntity(Cell)
    net.Send(Ply)
end

util.AddNetworkString("ForceField.UpdateAllowedTeams")

function ForceField.UpdateAllowed(Field)
    net.Start("ForceField.UpdateAllowedTeams")
    net.WriteEntity(Field)
    net.WriteTable(Field.Allowed)
    net.Broadcast()
end

util.AddNetworkString("ForceField.InstallCell")

net.Receive("ForceField.InstallCell", function(Len, Ply)
    local Cell = net.ReadEntity()
    if not Ply:CanUseForceFields(Cell) then return end
    local Pos = net.ReadVector()
    local Ang = net.ReadAngle()
    local Width = net.ReadUInt(32)
    local Height = net.ReadUInt(32)
    if Width < ForceField.MinWidth or Width > ForceField.MaxWidth or Height < ForceField.MinHeight or Height > ForceField.MaxHeight then return end

    local Settings = {
        Owner = Ply,
        Pos = Pos,
        Ang = Ang,
        Width = Width,
        Height = Height
    }

    Cell:Install(Settings)
end)

util.AddNetworkString("ForceField.UnmountField")

net.Receive("ForceField.UnmountField", function(Len, Ply)
    local Field = net.ReadEntity()

    if Field and Field:IsValid() and (Field:Getowning_ent() == Ply or Ply:IsAdmin()) then
        Field:Unmount()
    end
end)

util.AddNetworkString("ForceField.EnableField")

net.Receive("ForceField.EnableField", function(Len, Ply)
    local Field = net.ReadEntity()

    if Field and Field:IsValid() and (Field:Getowning_ent() == Ply or Ply:IsAdmin()) then
        Field:SetEnabled(net.ReadBool())
    end
end)

util.AddNetworkString("ForceField.AllowByDefault")

net.Receive("ForceField.AllowByDefault", function(Len, Ply)
    local Field = net.ReadEntity()

    if Field and Field:IsValid() and (Field:Getowning_ent() == Ply or Ply:IsAdmin()) then
        Field:SetAllowByDefault(net.ReadBool())
    end
end)

util.AddNetworkString("ForceField.StoreField")

net.Receive("ForceField.StoreField", function(Len, Ply)
    local Field = net.ReadEntity()

    if Field and Field:IsValid() and Ply:IsAdmin() then
        ForceField.Store(Field)
    end
end)