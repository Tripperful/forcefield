local FPPBlockTypes = {"Physgun1", "Spawning1", "Toolgun1"}

function ForceField.ProtectEntityClass(ENT)
    if CLIENT then return end
    ENT.USED = true
    FPP = FPP or {}
    FPP.Blocked = FPP.Blocked or {}

    for I, BlockType in pairs(FPPBlockTypes) do
        FPP.Blocked[BlockType] = FPP.Blocked[BlockType] or {}
        FPP.Blocked[BlockType][ENT.ClassName] = true
    end
end

if SERVER then
    util.AddNetworkString("ForceField.AccessFullUpdate")

    function ForceField.FullUpdate(Ply)
        net.Start("ForceField.AccessFullUpdate")
        net.WriteTable(ForceField.Access)
        net.Send(Ply)
    end

    hook.Add("PlayerInitialSpawn", "ForceField.AccessFullUpdate", ForceField.FullUpdate)
else
    net.Receive("ForceField.AccessFullUpdate", function(Len)
        ForceField.Access = net.ReadTable()
    end)
end

if SERVER then
    util.AddNetworkString("ForceField.FieldFullUpdate")

    function ForceField.FieldFullUpdate(FieldInd)
        local HasAccessData = ForceField.Access[FieldInd] and table.Count(ForceField.Access[FieldInd]) > 0
        net.Start("ForceField.FieldFullUpdate")
        net.WriteUInt(FieldInd, 16)
        net.WriteBool(HasAccessData)

        if HasAccessData then
            net.WriteTable(ForceField.Access[FieldInd])
        end

        net.Broadcast()
    end
else
    net.Receive("ForceField.FieldFullUpdate", function(Len)
        local FieldInd = net.ReadUInt(16)
        local HasAccessData = net.ReadBool()

        if HasAccessData then
            ForceField.Access[FieldInd] = net.ReadTable()
        else
            ForceField.Access[FieldInd] = nil
        end
    end)
end

if SERVER then
    util.AddNetworkString("ForceField.ClearAccessInfo")

    function ForceField.ClearAccessInfo(FieldIndex)
        ForceField.Access[FieldIndex] = nil
        net.Start("ForceField.ClearAccessInfo")
        net.WriteUInt(FieldIndex, 16)
        net.Broadcast()
    end
else
    net.Receive("ForceField.ClearAccessInfo", function(Len)
        ForceField.Access[net.ReadUInt(16)] = nil
    end)
end

local function DisallowFieldPhysgun(Ply, Ent)
    if Ent.ClassName and Ent.ClassName == "forcefield" then return false end
end

hook.Add("PhysgunPickup", "ForceField.BlockPhysgun", DisallowFieldPhysgun)
hook.Add("CanPlayerUnfreeze", "ForceField.BlockPhysgunUnfreeze", DisallowFieldPhysgun)

local function TestFieldCollision(Ent1, Ent2)
    local Field, Ply

    if Ent1.ClassName == "forcefield" then
        Field = Ent1
        Ply = Ent2
    elseif Ent2.ClassName == "forcefield" then
        Field = Ent2
        Ply = Ent1
    end

    if Field and Ply:IsPlayer() then return not Ply:CanPassField(Field) end

    return true
end

hook.Add("ShouldCollide", "ForceField.TestFieldCollision", TestFieldCollision)