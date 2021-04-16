if CLIENT then
    function ForceField.HSVA(H, S, V, A)
        local Col = HSVToColor(H, S, V)
        Col.a = A

        return Col
    end
end