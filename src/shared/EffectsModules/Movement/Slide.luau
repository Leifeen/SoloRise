local EffectUtility = require( game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

return function (Player, RenderEF)
    if  not  RenderEF  then

        local sucess, err  = pcall(function()
            task.cancel(EffectUtility.Threads[Player .. "_slide" ].Thread)            
        end)

        local sucess, err = pcall(function()
            for _, EF  in pairs( EffectUtility.Threads[Player .. "_slide" ].Garbage ) do 
                local W = EF:FindFirstChildWhichIsA("Weld")
                W:Destroy()
                
                for _, child in pairs(EF:GetDescendants()) do 
                    if child:IsA("ParticleEmitter") then
                        child.Enabled = false                        
                    end
                end 

                EF.Anchored = true
                EffectUtility.DBSV:AddItem(EF, 5)
                
            end 
        end)

       
        EffectUtility.Threads[Player .. "_slide" ] = nil
        return 
    end

    local Plr =  game.Players:FindFirstChild(Player)
    
    if Plr and Plr.Character then
    else
        return
    end
    local Char = Plr.Character

    local VFX = EffectUtility.GetEffect("Movement", "slidevfx"):Clone()
    
    VFX.Parent = game.Workspace
    EffectUtility.SetupEffectPart(VFX)

    EffectUtility.WeldInto(VFX, Char.HumanoidRootPart, {
        C0 = CFrame.new(0,0,0),
        C1 = CFrame.new(0,1.5,1.1) * CFrame.Angles(0, math.rad(180),0)
    } )

    EffectUtility.Threads[Player .. "_slide"] = {}
    EffectUtility.Threads[Player .. "_slide"].Garbage = {VFX}

    EffectUtility.Threads[Player .. "_slide" ].Thread = task.spawn(function()
        while true do
            local delta = game:GetService("RunService").Heartbeat:Wait()
            
            EffectUtility.EmitEffect(VFX)
            task.wait(5 * (delta*30) )
        end
    end)

end