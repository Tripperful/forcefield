--[[-------------------------------------------------------------------------
ForceField addon initialization file
---------------------------------------------------------------------------]]
ForceField = ForceField or {}
ForceField.Version = "1.2.2"

if SERVER then
    -- AddCSLua (shared)
    AddCSLuaFile()
    AddCSLuaFile("forcefield/sh_util.lua")
    AddCSLuaFile("forcefield_config.lua")
    AddCSLuaFile("forcefield/sh_access.lua")
    AddCSLuaFile("forcefield/sh_forcefield.lua")
    AddCSLuaFile("forcefield/sh_customthings.lua")
    -- AddCSLua (clientside)
    AddCSLuaFile("forcefield_gui.lua")
    AddCSLuaFile("forcefield/cl_keytrap.lua")
    AddCSLuaFile("forcefield/cl_gui.lua")
    AddCSLuaFile("forcefield/cl_forcefield.lua")
end

-- Shared includes
include("forcefield/sh_util.lua")
include("forcefield_config.lua")
local LangFile = "forcefield_language/" .. ForceField.Language .. ".lua"

if SERVER then
    AddCSLuaFile(LangFile)
end

include(LangFile)
include("forcefield/sh_access.lua")
include("forcefield/sh_forcefield.lua")
include("forcefield/sh_customthings.lua")

if SERVER then
    -- Serverside includes
    include("forcefield/sv_forcefield.lua")
    include("forcefield/sv_storage.lua")
else
    -- Clientside includes
    include("forcefield_gui.lua")
    include("forcefield/cl_keytrap.lua")
    include("forcefield/cl_gui.lua")
    include("forcefield/cl_forcefield.lua")
end