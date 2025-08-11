
local EffectUtility = require( game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

return function (Player, RenderEF, Side)
    

    if  not  RenderEF  then
     
        local sucess, err  = pcall(function()
            task.cancel(EffectUtility.Threads[Player .. "_wallrun" ].Thread)            
        end)

        local sucess, err = pcall(function()
            for _, EF  in pairs( EffectUtility.Threads[Player .. "_wallrun" ].Garbage ) do 
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

       
        EffectUtility.Threads[Player .. "_wallrun" ] = nil
        return 
    end

    local Plr =  game.Players:FindFirstChild(Player)
    
    if Plr and Plr.Character then
    else
        return
    end
    local Char = Plr.Character

    local VFX = nil
    if Side >= 1 then
         VFX = EffectUtility.GetEffect("Movement", "wallrunvfxRIGHT"):Clone()
         VFX.Parent = game.Workspace
         EffectUtility.SetupEffectPart(VFX)
         EffectUtility.WeldInto(VFX, Char.HumanoidRootPart, {
            C0 = CFrame.new(-1.3,0,0)
        } )
    else
         VFX = EffectUtility.GetEffect("Movement", "wallrunvfxLEFT"):Clone()
         VFX.Parent = game.Workspace
         EffectUtility.SetupEffectPart(VFX)
         
         EffectUtility.WeldInto(VFX, Char.HumanoidRootPart, {
            C0 = CFrame.new(1.3,0,0)
        } )
    end
    
  

    EffectUtility.Threads[Player .. "_wallrun"] = {}
    EffectUtility.Threads[Player .. "_wallrun"].Garbage = {VFX}

    EffectUtility.Threads[Player .. "_wallrun" ].Thread = task.spawn(function()
        while true do
            local delta = game:GetService("RunService").Heartbeat:Wait()
            
            EffectUtility.EmitEffect(VFX)
            task.wait(5 * (delta*30) )
        end
    end)


end

