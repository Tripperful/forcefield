ForceField.Filters = ForceField.Filters or {}
ForceField.Access = ForceField.Access or {}
ForceField.RegisteredFilters = ForceField.RegisteredFilters or {}

function ForceField.CreateFilter(Name, PrintName, Filter, GetValues, PrintValue)
    if ForceField.RegisteredFilters[Name] then return end
    local FilterID = #ForceField.Filters + 1
    local FuncName = "Allow" .. Name
    local PacketName = "ForceField." .. FuncName
    ForceField.RegisteredFilters[Name] = FilterID

    if SERVER then
        util.AddNetworkString(PacketName)
    end

    local SetAccessRaw = function(FieldInd, Val, Allow, DontSend)
        ForceField.Access[FieldInd] = ForceField.Access[FieldInd] or {}
        local FieldAccess = ForceField.Access[FieldInd]
        FieldAccess[FilterID] = FieldAccess[FilterID] or {}
        FieldAccess[FilterID][Val] = Allow

        if Allow == nil and table.Count(FieldAccess[FilterID]) == 0 then
            FieldAccess[FilterID] = nil

            if table.Count(FieldAccess) == 0 then
                ForceField.Access[FieldInd] = nil
            end
        end

        if CLIENT and DontSend then return end
        net.Start(PacketName)
        local Access = 0

        if Allow == false then
            Access = 1
        elseif Allow == true then
            Access = 2
        end

        net.WriteUInt(FieldInd, 16)
        net.WriteType(Val)
        net.WriteUInt(Access, 2)

        if CLIENT then
            net.SendToServer()
        else
            net.Broadcast()
        end
    end

    local SetAccess = function(Field, Val, Allow)
        if not (Field and Field:IsValid()) then return end
        if CLIENT and not LocalPlayer():IsAdmin() and Field:Getowning_ent() ~= LocalPlayer() then return end
        SetAccessRaw(Field:EntIndex(), Val, Allow)
    end

    ForceField[FuncName] = SetAccess

    net.Receive(PacketName, function(Len, Ply)
        local FieldInd = net.ReadUInt(16)
        local Val = net.ReadType()
        local Access = net.ReadUInt(2)
        local Field = Entity(FieldInd)
        if SERVER and not Field:IsValid() then return end
        local Allow = nil

        if Access == 1 then
            Allow = false
        elseif Access == 2 then
            Allow = true
        end

        if CLIENT then
            SetAccessRaw(FieldInd, Val, Allow, true)
        elseif Field:Getowning_ent() == Ply or Ply:IsAdmin() then
            SetAccess(Field, Val, Allow)
        end
    end)

    ForceField.Filters[FilterID] = {
        Name = Name,
        PrintName = PrintName,
        Filter = Filter,
        GetValues = GetValues,
        PrintValue = PrintValue,
        ID = FilterID,
        SetAccess = SetAccess,
        SetAccessRaw = SetAccessRaw
    }

    return FilterID
end

function ForceField.FilterIDByName(Name)
    for FilterID, Filter in pairs(ForceField.Filters) do
        if Filter.Name == Name then return FilterID end
    end
end

function ForceField.FilterValuesList(FilterID)
    return ForceField.Filters[FilterID].GetValues()
end

function ForceField.FilterValue(FieldInd, FilterID, Value)
    local FieldAccess = ForceField.Access[FieldInd]
    if not FieldAccess then return end
    if not FieldAccess[FilterID] then return end

    return FieldAccess[FilterID][Value]
end

function ForceField.FilterEnt(FieldInd, FilterID, Ent)
    local Filter = ForceField.Filters[FilterID].Filter

    return ForceField.FilterValue(FieldInd, FilterID, Filter(Ent))
end

FORCEFIELD_FILTER_PLAYER = ForceField.CreateFilter("Player", ForceField.Lang.players, function(Ent) return Ent:AccountID() end, function()
    local Values = {}

    for I, Ply in pairs(player.GetHumans()) do
        table.insert(Values, Ply:AccountID())
    end

    return Values
end, function(Value)
    for I, Ply in pairs(player.GetAll()) do
        if Ply:AccountID() == Value then return Ply:Nick() end
    end
end)

FORCEFIELD_FILTER_USERGROUP = ForceField.CreateFilter("UserGroup", ForceField.Lang.usergroups, function(Ent) return Ent:GetUserGroup() end, function() return table.GetKeys(ForceField.AllowedGroups) end, function(Value) return Value end)

FORCEFIELD_FILTER_TEAM = ForceField.CreateFilter("Team", ForceField.Lang.jobs, function(Ent) return Ent:Team() end, function()
    local Values = {}

    for Index, Team in pairs(team.GetAllTeams()) do
        if Team.Joinable and Index ~= TEAM_SPECTATOR then
            table.insert(Values, Index)
        end
    end

    return Values
end, function(Value) return team.GetName(Value) end)

local PLAYER = FindMetaTable("Player")

function PLAYER:CanPassField(Field)
    local FieldInd = Field:EntIndex()
    local Default = Field:GetAllowByDefault()
    local FieldAccess = ForceField.Access[FieldInd]
    if not Field:GetEnabled() then return true end
    if not FieldAccess then return Default end

    for FilterID, Access in SortedPairs(FieldAccess) do
        local Result = ForceField.FilterEnt(FieldInd, FilterID, self)
        if Result ~= nil then return Result end
    end

    return Default
end

function PLAYER:CanUseForceFields(Cell)
    if ForceField.NotRestricted then return true end
    if ForceField.AllowedGroups[self:GetUserGroup()] then return true end
    if ForceField.AllowedJobs[team.GetName(self:Team())] then return true end
    if Cell:Getowning_ent() == self then return true end

    return not ForceField.OnlyOwnerCanInstall
end