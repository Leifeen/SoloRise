

local EffectsFolder = game:GetService("ReplicatedStorage").Assets.Effects
local EffectsUtility = require(game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )


return function (Plr: nil, tab: {})
    
    local weapon = tab.Weapon 
    local Feint = game.ReplicatedStorage.Assets.Effects.CombatGeneral.Feint.Attachment

    local FP = Feint:Clone()
    FP.Parent = weapon
    FP.CFrame = CFrame.new(0,4,0)
    
    EffectsUtility.EmitEffect(FP, .2)
    

    game:GetService("Debris"):AddItem(FP, .2)
    

end