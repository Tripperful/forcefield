--  ____  _____  ____   ___  ____    ____  ____  ____  __    ____   ___
-- ( ___)(  _  )(  _ \ / __)( ___)  ( ___)(_  _)( ___)(  )  (  _ \ / __)
--  )__)  )(_)(  )   /( (__  )__)    )__)  _)(_  )__)  )(__  )(_) )\__ \
-- (__)  (_____)(_)\_) \___)(____)  (__)  (____)(____)(____)(____/ (___/
local GUI = {}
-- GUI Colors customization, HSVA format is Hue, Saturation, Value, Alpha
-- You can use regular Color( r, g, b, a ) here as well
GUI.TextColor = ForceField.HSVA(178, 0.2, 1, 255)
GUI.FieldMenuColor = ForceField.HSVA(178, 0.5, 0.5, 200)
GUI.FilterMenuColor = ForceField.HSVA(178, 0.9, 0.5, 200)
GUI.CloseButtonColor = ForceField.HSVA(0, 1, 1, 90)
GUI.UnmountButtonColor = ForceField.HSVA(40, 1, 1, 90)
GUI.StoreButtonColor = ForceField.HSVA(160, 1, 1, 90)
GUI.FilterButtonColor = ForceField.HSVA(178, 0.5, 0.2, 64)
GUI.ValueButtonColor = ForceField.HSVA(178, 0.9, 0.2, 64)
GUI.ValueButtonRestrictColor = ForceField.HSVA(0, 1, 1, 64)
GUI.ValueButtonAllowColor = ForceField.HSVA(120, 1, 1, 64)
GUI.HintBGColor = ForceField.HSVA(178, 0.6, 0.2, 255)
GUI.HintColor = ForceField.HSVA(178, 0.6, 1, 255)
-- Default width and height of some windows
GUI.FieldMenuWidth = 400
GUI.FieldMenuHeight = 300
GUI.FilterMenuWidth = 380
GUI.FilterMenuHeight = 280
-- Radius of round corners, I don't really recommend changing it
GUI.CornerRadius = 8
-- There are the fonts that are used in the addon GUI
local BaseFont = "Verdana"

surface.CreateFont("ForceField.FieldMenuHeader", {
    font = BaseFont,
    size = 20
})

surface.CreateFont("ForceField.SmallButton", {
    font = BaseFont,
    size = 16
})

surface.CreateFont("ForceField.FilterList", {
    font = BaseFont,
    size = 18
})

surface.CreateFont("ForceField.Hint", {
    font = BaseFont,
    size = 20
})

surface.CreateFont("ForceField.HintBG", {
    font = BaseFont,
    size = 20,
    blursize = 3,
    scanlines = 3
})

ForceField.GUI = GUI