local PhysicalStatus = {}
PhysicalStatus.LastChar = {}
PhysicalStatus.Threads = {}


PhysicalStatus.Stunned = function(ReturnBack)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 4
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = 0

    if ReturnBack then 
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end 
end

PhysicalStatus.InM1 = function(ReturnBack)
     game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 10

    if ReturnBack then 
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end 
end

PhysicalStatus.InClash = function(ReturnBack)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 0
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = 0
    game.Players.LocalPlayer.Character.Humanoid.AutoRotate = false

    if ReturnBack then 
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        game.Players.LocalPlayer.Character.Humanoid.AutoRotate = true
    end 

end

PhysicalStatus.EndLag = function(ReturnBack)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 8

    if ReturnBack then 
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end 

end


PhysicalStatus.Init = function()

    for _, Connections in pairs(PhysicalStatus.LastChar) do 
        Connections:Disconnect()
    end 

    -- Make Player Receive these states.
    PhysicalStatus.LastChar.OnAdded =  game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
        PhysicalStatus.LastChar.ATB_Changed =  character.AttributeChanged:Connect(function(ATB)
            if ATB and PhysicalStatus[ATB] then
                if PhysicalStatus.Threads[ATB] then 
                    task.cancel( PhysicalStatus.Threads[ATB] )
                end 

                -- Init it 
                 PhysicalStatus.Threads[ATB] =  task.spawn(function()
                    while character:GetAttribute(ATB) do
                        task.wait()
                        PhysicalStatus[ATB]()
                    end    
                    PhysicalStatus[ATB]("ReturnBack")

                end)
            end
        end)             
    end)

end

return PhysicalStatus