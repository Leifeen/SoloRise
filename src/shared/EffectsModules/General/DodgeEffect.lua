

local EffectsFolder = game:GetService("ReplicatedStorage").Assets.Effects
local EffectsUtility = require(game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

local function DisappearPlr (Char, EfCall)
    local CanSetT = {}
    for _, child in pairs(Char:GetDescendants()) do 
        if child:IsA("BasePart") and child.Transparency == 0 then
            table.insert(CanSetT, child)
        end
    end
    
    local TranspOrder = {1,0}

    for i = 1, #TranspOrder do 
        
        if  TranspOrder[i] == 0 then
            EfCall()            
        end


        for _, child in pairs(CanSetT) do 
            child.Transparency = TranspOrder[i]
         end 
         task.wait(.1)
    end 

    

end


return function (Player: nil, tab: {})
        
        local Target = tab.Target 

        local function DodgeEF (PMusic)
             local DodgeEF = EffectsFolder.Movement.TeleportFX:Clone()
            DodgeEF.Position = ( Target.HumanoidRootPart.Position )

            DodgeEF.Parent = game.Workspace
            DodgeEF.Anchored = true

            local RandomSFX = math.random(1,3)
            local Dodge_SFX  = game.ReplicatedStorage.Assets.SFX.Combat.Teleport
            Dodge_SFX =  Dodge_SFX:Clone()
            Dodge_SFX.Parent = DodgeEF
            Dodge_SFX:Play()

            EffectsUtility.EmitEffect(DodgeEF, 6)

        end

       



        DisappearPlr(Target, DodgeEF)

        

end