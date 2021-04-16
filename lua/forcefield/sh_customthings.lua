local function AddCustomThings()
    local FieldData = {
        ent = "forcefield_cell",
        model = "models/maxofs2d/hover_basic.mdl",
        price = ForceField.Price,
        max = ForceField.MaxPerPlayer,
        cmd = "buyforcefield",
        allowed = {}
    }

    for Index, Team in pairs(team.GetAllTeams()) do
        if ForceField.AllowedJobs[Team.Name] then
            table.insert(FieldData.allowed, Index)
        end
    end

    DarkRP.createEntity("Force Field Cell", FieldData)
end

hook.Add("loadCustomDarkRPItems", "ForceField", AddCustomThings)