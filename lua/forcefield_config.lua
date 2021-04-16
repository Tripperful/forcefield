--  ____  _____  ____   ___  ____    ____  ____  ____  __    ____   ___
-- ( ___)(  _  )(  _ \ / __)( ___)  ( ___)(_  _)( ___)(  )  (  _ \ / __)
--  )__)  )(_)(  )   /( (__  )__)    )__)  _)(_  )__)  )(__  )(_) )\__ \
-- (__)  (_____)(_)\_) \___)(____)  (__)  (____)(____)(____)(____/ (___/
-- GUI language (check "forcefield_language" folder to find more)
ForceField.Language = "english"
-- The price of a force field cell
ForceField.Price = 1500
-- How many force fields a player can have
ForceField.MaxPerPlayer = 5
-- Force field health (can be damaged with regular weapons)
-- Set to false to make them unbreakable
ForceField.MaxHealth = 1000
-- If set to true, the force field will drop a cell when it's broken,
-- otherwise it will be removed
ForceField.DropOnBreak = true
-- The minimum width of a force field
ForceField.MinWidth = 32
-- The maximum width of a force field
ForceField.MaxWidth = 512
-- The minimum height of a force field
ForceField.MinHeight = 32
-- The maximum height of a force field
ForceField.MaxHeight = 128
-- If set to true, Force Fields usage is not restricted by any 
-- of the below rules.
ForceField.NotRestricted = false
-- Only the player who bought the field cell can install it
ForceField.OnlyOwnerCanInstall = true

-- A list of user groups that can buy and use force field cells
ForceField.AllowedGroups = {
    superadmin = true,
    admin = true,
    user = true
}

-- A list of jobs that can buy and use force field cells
ForceField.AllowedJobs = {
    ["Civil Protection Chief"] = true,
    ["Mob boss"] = true,
    ["Mayor"] = true
}

-- Do we want to tell a player who's field it is when hi aims at it
ForceField.DisplayFieldOwner = true
-- Do we want to display fields health?
ForceField.DisplayHealth = true
-- Materials and colors used to draw the force field
ForceField.BaseMat = Material("effects/water_warp01")
ForceField.FieldBaseColor = Color(255, 255, 255, 255)
ForceField.OverlayMat = Material("gui/gradient_up")
ForceField.FieldAllowColor = Color(0, 255, 0, 48)
ForceField.FieldRestrictColor = Color(255, 0, 0, 48)