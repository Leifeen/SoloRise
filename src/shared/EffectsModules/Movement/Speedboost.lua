
local EffectUtility = require( game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

local AlreadyRendering = {}


return function (Player, RenderEF)
    
    -- Make sure we don't render again for players that already has the effect
    if not AlreadyRendering[Player] then
        AlreadyRendering[Player] = {}
    end

    if  not  RenderEF  then
        
        local sucess, err = pcall(function()
            for _, child in pairs( EffectUtility.Threads[Player .. "_Speedboost"].Garbage) do 
                for _, EF in pairs ( child:GetChildren(child) ) do 
                    if EF:IsA("Trail") then
                        EF.Enabled = false
                    end
                end 
            end 
            task.wait(4)
            for _, child in pairs( EffectUtility.Threads[Player .. "_Speedboost"].Garbage) do 
                for _, EF in pairs ( child:GetChildren(child) ) do 
                    if EF:IsA("Trail") then
                        EF:Destroy()
                    end
                end 
            end 
            EffectUtility.Threads[Player .. "_Speedboost"] = nil

            AlreadyRendering[Player].IsRendering = false

        end)
        
        return 

        else
        
            -- No need to render again.
         if  AlreadyRendering[Player].IsRendering == true then
            return
         end
    end
    
    

    local Plr =  game.Players:FindFirstChild(Player)
    
    if Plr and Plr.Character then
    else
        return
    end
    local Char = Plr.Character

    local VFX = EffectUtility.GetEffect("Movement", "speedboostvfx"):Clone()
    local Attach = VFX:FindFirstChild("Attachment")

    local function SetupBeam(Attach, Arm)
        local NewEF = Attach:Clone()
        local NewEF2 = Attach.Parent.Attachment2:Clone()

        NewEF.Parent = Arm
        NewEF2.Parent = Arm

        for _, Beam in pairs(NewEF:GetChildren()) do 
            if Beam:IsA("Trail") then
                Beam.Attachment0 = NewEF
                Beam.Attachment1 = NewEF2
            end 
        end 

        return NewEF, NewEF2
    end

    EffectUtility.Threads[Player .. "_Speedboost"] = {}

    local  Attach1, Attach2 =  SetupBeam(Attach, Char:FindFirstChild("Right Arm") )
    local  Attach3, Attach4 =  SetupBeam(Attach, Char:FindFirstChild("Left Arm") )
    local  Attach5, Attach6 =  SetupBeam(VFX:FindFirstChild("Torso"), Char:FindFirstChild("Torso") )

    AlreadyRendering[Player].IsRendering = true 

    EffectUtility.Threads[Player .. "_Speedboost"].Garbage = {Attach1, Attach2, Attach3, Attach4,Attach5,Attach6}


end

