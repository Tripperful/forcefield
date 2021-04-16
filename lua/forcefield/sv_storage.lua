function ForceField.StoreMapID(Map)
    local MapID = 1

    MySQLite.query([[SELECT ID FROM ForceField_Maps ORDER BY ID DESC LIMIT 1]], function(Res)
        if Res then
            MapID = Res[1].ID + 1
        end

        MySQLite.query(string.format([[INSERT INTO ForceField_Maps ( ID, Map ) VALUES ( %d, '%s' )]], MapID, Map), function(Res1)
            ForceField.CacheMapID(Map)
        end, function(Err)
            print(Err)
        end)
    end, function(Err)
        print(Err)
    end)
end

function ForceField.CacheMapID(Map)
    MySQLite.query(string.format([[SELECT * FROM ForceField_Maps WHERE Map = '%s']], Map), function(Res)
        if Res then
            ForceField.MapID = Res[1].ID
            ForceField.LoadFields()
        else
            ForceField.StoreMapID(Map)
        end
    end, function(Err)
        print(Err)
    end)
end

function ForceField.InitTables()
    local Map = game.GetMap()
    local Table1Exists = false
    local Table2Exists = false

    MySQLite.tableExists("ForceField", function(Exists)
        if Exists then
            Table1Exists = true

            if Table2Exists then
                ForceField.CacheMapID(Map)
            end
        else
            local AutoIncrement = MySQLite.isMySQL() and "AUTO_INCREMENT" or "AUTOINCREMENT"

            MySQLite.query([[CREATE TABLE ForceField ( ID INTEGER PRIMARY KEY ]] .. AutoIncrement .. [[, MapID INTEGER, Data TEXT )]], function(Res)
                Table1Exists = true

                if Table2Exists then
                    ForceField.CacheMapID(Map)
                end
            end)
        end
    end)

    MySQLite.tableExists("ForceField_Maps", function(Exists)
        if Exists then
            Table2Exists = true

            if Table1Exists then
                ForceField.CacheMapID(Map)
            end
        else
            MySQLite.query([[CREATE TABLE ForceField_Maps ( ID INTEGER PRIMARY KEY, Map TEXT )]], function(Res)
                Table2Exists = true

                if Table1Exists then
                    ForceField.CacheMapID(Map)
                end
            end)
        end
    end)
end

function ForceField.InitStorage()
    ForceField.InitTables()
end

hook.Add("DatabaseInitialized", "ForceField.InitStorage", ForceField.InitStorage)

function ForceField.Serialize(FieldInd)
    local Field = Entity(FieldInd)
    if not (Field and Field:IsValid()) then return end
    local Data = string.format("e=%d;d=%d;p=%s;a=%s;w=%d;h=%d", Field:GetEnabled() and 1 or 0, Field:GetAllowByDefault() and 1 or 0, tostring(Field:GetPos()), tostring(Field:GetAngles()), Field:GetWidth(), Field:GetHeight())
    local FieldAccess = ForceField.Access[FieldInd]

    if FieldAccess and table.Count(FieldAccess) > 0 then
        local AccessData = ""

        for FilterID, AccessTable in SortedPairs(FieldAccess) do
            if table.Count(AccessTable) > 0 then
                local FilterName = ForceField.Filters[FilterID].Name
                AccessData = AccessData .. FilterName .. "="

                for Val, Access in SortedPairs(AccessTable) do
                    AccessData = AccessData .. tostring(Val) .. "=" .. (Access and "1" or "0") .. " "
                end

                AccessData = AccessData .. ","
            end
        end

        if #AccessData > 0 then
            Data = Data .. ";f=" .. AccessData
        end
    end

    return Data
end

function ForceField.CreateFromStorage(DBID, Data)
    local DataFields = string.Explode(";", Data)
    local FieldData = {}

    for I, DataField in pairs(DataFields) do
        local Key, Val = string.Left(DataField, 1), string.Right(DataField, #DataField - 2)

        if Key == "p" then
            local P = string.Explode(" ", Val)
            FieldData.Pos = Vector(tonumber(P[1]), tonumber(P[2]), tonumber(P[3]))
        elseif Key == "a" then
            local A = string.Explode(" ", Val)
            FieldData.Ang = Angle(tonumber(A[1]), tonumber(A[2]), tonumber(A[3]))
        elseif Key == "w" then
            FieldData.Width = tonumber(Val)
        elseif Key == "h" then
            FieldData.Height = tonumber(Val)
        elseif Key == "e" then
            FieldData.Enabled = Val == "1"
        elseif Key == "d" then
            FieldData.AllowByDefault = Val == "1"
        elseif Key == "f" then
            FieldData.Access = {}
            local Access = FieldData.Access

            for J, FilterAccess in pairs(string.Explode(" ,", Val)) do
                local Separator = string.find(FilterAccess, "=", 1, true)

                if Separator then
                    local FilterName = string.Left(FilterAccess, Separator - 1)
                    FilterID = ForceField.FilterIDByName(FilterName)

                    -- This condition is for backwards compatibility with versions under 1.2.2
                    if FilterID then
                        Access[FilterID] = {}

                        for K, AccessPair in pairs(string.Explode(" ", string.Right(FilterAccess, #FilterAccess - Separator))) do
                            local Pair = string.Explode("=", AccessPair)
                            local Num = tonumber(Pair[1])
                            Access[FilterID][Num or Pair[1]] = Pair[2] == "1"
                        end
                    end
                end
            end
        end
    end

    local Field = ents.Create("forcefield")
    Field:SetEnabled(FieldData.Enabled)
    Field:SetAllowByDefault(FieldData.AllowByDefault or false)
    Field:SetPos(FieldData.Pos)
    Field:SetAngles(FieldData.Ang)
    Field:SetWidth(FieldData.Width)
    Field:SetHeight(FieldData.Height)
    Field:Spawn()
    Field:Activate()
    Field.DBID = DBID
    local FieldInd = Field:EntIndex()
    ForceField.Access[FieldInd] = FieldData.Access
    ForceField.FieldFullUpdate(FieldInd)

    return Field
end

function ForceField.Store(Field)
    local FieldInd = Field:EntIndex()
    local FieldData = ForceField.Serialize(FieldInd)

    if Field.DBID then
        MySQLite.query(string.format([[UPDATE ForceField SET Data = '%s' WHERE ID = %d]], FieldData, Field.DBID), function(Res) end, function(Err)
            print(Err)
        end)
    else
        MySQLite.query(string.format([[INSERT INTO ForceField ( MapID, Data ) VALUES ( %d, '%s' )]], ForceField.MapID, FieldData), function(Res)
            MySQLite.query([[SELECT ID FROM ForceField WHERE MapID = ForceField.MapID ORDER BY ID DESC LIMIT 1]], function(Res1)
                Field.DBID = Res1[1].ID

                if Field.Cell and Field.Cell:IsValid() then
                    Field.Cell:Remove()
                end

                Field:Setowning_ent(nil)
            end, function(Err)
                print(Err)
            end)
        end, function(Err)
            print(Err)
        end)
    end
end

function ForceField.Unstore(Field)
    if Field.DBID then
        MySQLite.query(string.format([[DELETE FROM ForceField WHERE ID = %d]], Field.DBID), function(Res) end, function(Err)
            print(Err)
        end)
    end
end

function ForceField.LoadFields()
    MySQLite.query(string.format([[SELECT * FROM ForceField WHERE MapID = '%d']], ForceField.MapID), function(Res)
        local FieldsLoaded = 0

        if Res then
            for I, Row in pairs(Res) do
                FieldsLoaded = FieldsLoaded + 1
                ForceField.CreateFromStorage(Row.ID, Row.Data)
            end
        end

        if FieldsLoaded > 0 then
            print(string.format("ForceField: Loaded %d stored force fields", FieldsLoaded))
        end
    end, function(Err)
        print(Err)
    end)
end