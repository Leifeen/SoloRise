local CharPhysics = {}

CharPhysics.SpeedBoost = 0
CharPhysics.StayBoost = true


CharPhysics.Initialize = function()
    local Char = game.Players.LocalPlayer.Character
    
    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        if not CharPhysics.StayBoost then
            CharPhysics.SpeedBoost -= 0.2 * (30* deltaTime )
        end

         CharPhysics.SpeedBoost = math.clamp(CharPhysics.SpeedBoost, 0, 2)      
    end)

end

return CharPhysics 