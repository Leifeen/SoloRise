local CharPhysics = {}

CharPhysics.SpeedBoost = 0


CharPhysics.Initialize = function()
    local Char = game.Players.LocalPlayer.Character
    
    game:GetService("RunService").Stepped:Connect(function(deltaTime)
        CharPhysics.SpeedBoost -= 0.0003 * (30* deltaTime )
        CharPhysics.SpeedBoost = math.clamp(CharPhysics.SpeedBoost, 0, 10)
    end)

end

return CharPhysics 