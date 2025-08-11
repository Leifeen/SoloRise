local InCombatWarn = {}

local TweenSV = game:GetService("TweenService")

InCombatWarn.Char = nil
InCombatWarn.OldConnections = {}

InCombatWarn.OnCombatEnter = function()
    local InCombatGUI = game.Players.LocalPlayer.PlayerGui.InCombatWarn
    InCombatGUI.Enabled = true

    local TGUI = InCombatGUI.Frame.TextLabel

    TGUI.TextTransparency = 1
    TGUI.Visible = true 

    local Anim = TweenSV:Create(TGUI,TweenInfo.new(0.3), {
        TextTransparency = 0
    } )
    Anim:Play()


end
InCombatWarn.LeaveCombat =function()
     local InCombatGUI = game.Players.LocalPlayer.PlayerGui.InCombatWarn

    local TGUI = InCombatGUI.Frame.TextLabel
    TGUI.Visible = true 

    TGUI.TextTransparency = 0
    
    local Anim = TweenSV:Create(TGUI,TweenInfo.new(0.3), {
        TextTransparency = 1
    } )
    Anim:Play()

end

InCombatWarn.OnAtb = function(Char)
    
    if Char then
    else
        return
    end

    local sucess, err = pcall(function()
        for _, child in pairs(InCombatWarn.OldConnections) do 
            child:Disconnect()
        end 
    end)


    InCombatWarn.OldConnections["OnAtb"] = Char.AttributeChanged:Connect(function(atb)
        if atb == "InCombat" then
            if Char:GetAttribute("InCombat") then
                InCombatWarn.OnCombatEnter()
            else
                InCombatWarn.LeaveCombat()
            end
        end
    end)

end


InCombatWarn.Init = function()
    local Char = game.Players.LocalPlayer.Character

    InCombatWarn.OnAtb(Char)
    game.Players.LocalPlayer.CharacterAdded:Connect(function(Char)
        InCombatWarn.Char = Char
        InCombatWarn.OnAtb(InCombatWarn.Char)
    end)
end

return InCombatWarn