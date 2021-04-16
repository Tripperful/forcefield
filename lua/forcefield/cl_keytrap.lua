KeyTrap = KeyTrap or {}
KeyTrap.Buttons = KeyTrap.Buttons or 0
KeyTrap.PrevButtons = KeyTrap.PrevButtons or 0
KeyTrap.CaptureKeys = KeyTrap.CaptureKeys or false
KeyTrap.ClearMovement = KeyTrap.ClearMovement or false

function KeyTrap.StartKeyCapturing(ClearMovement)
    KeyTrap.CaptureKeys = true

    if ClearMovement then
        KeyTrap.ClearMovement = true
    end
end

function KeyTrap.StopKeyCapturing()
    KeyTrap.CaptureKeys = false
    KeyTrap.ClearMovement = false
end

function KeyTrap.InputKeyPressed(Key)
    return hook.Run("InputKeyPressed", Key)
end

function KeyTrap.InputKeyHeld(Key)
    return hook.Run("InputKeyHeld", Key)
end

function KeyTrap.InputKeyReleased(Key)
    hook.Run("InputKeyReleased", Key)
end

local UseDist = 64

function KeyTrap.HookUserCmd(Ply, Cmd)
    KeyTrap.Buttons = Cmd:GetButtons()

    if bit.band(KeyTrap.Buttons, IN_USE) == IN_USE and bit.band(KeyTrap.PrevButtons, IN_USE) == 0 then
        local Tr = LocalPlayer():GetEyeTrace()

        if Tr.Entity and Tr.Entity:IsValid() and (Tr.HitPos - LocalPlayer():GetShootPos()):Length() <= UseDist and isfunction(Tr.Entity.CSUse) then
            Tr.Entity:CSUse()
        end
    end

    if KeyTrap.CaptureKeys then
        if KeyTrap.ClearMovement then
            Cmd:ClearMovement()
        end

        for Bit = math.log(IN_ATTACK, 2), math.log(IN_GRENADE2, 2) do
            local Key = 2 ^ Bit

            if bit.band(KeyTrap.Buttons, Key) == Key then
                if bit.band(KeyTrap.PrevButtons, Key) == 0 then
                    if KeyTrap.InputKeyPressed(Key) then
                        Cmd:RemoveKey(Key)
                    end
                else
                    if KeyTrap.InputKeyHeld(Key) then
                        Cmd:RemoveKey(Key)
                    end
                end
            elseif bit.band(KeyTrap.PrevButtons, Key) == Key then
                KeyTrap.InputKeyReleased(Key)
            end
        end
    end

    KeyTrap.PrevButtons = KeyTrap.Buttons
end

function KeyTrap.Init()
    hook.Remove("StartCommand", "KeyTrap.HookUserCmd")
    hook.Add("StartCommand", "KeyTrap.HookUserCmd", KeyTrap.HookUserCmd)
end

hook.Add("InitPostEntity", "KeyTrap.Init", function()
    KeyTrap.Init()
end)

KeyTrap.Init()