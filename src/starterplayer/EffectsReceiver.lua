EffectsReceiver = {}
EffectsReceiver.EffectsFunctions = {}
local EF_Remote = game:GetService("ReplicatedStorage"):WaitForChild("EffectsRPL")

EffectsReceiver.RenderEffect = function(Plr ,Method, Params, Params2)
    -- If it didn't load properly, this will catch it and load.
    if not EffectsReceiver.EffectsFunctions[Method] then
        local FindedEF = game:GetService("ReplicatedStorage").Shared.EffectsModules:FindFirstChild(Method)
        if FindedEF then
            EffectsReceiver.EffectsFunctions[Method] = require(FindedEF)
        end
    end

    -- after that we just do the Effect and be happy
    if EffectsReceiver.EffectsFunctions[Method] then
        EffectsReceiver.EffectsFunctions[Method](Plr, Params, Params2)
    end


end

EffectsReceiver.Init = function()
    for _, child in pairs(game:GetService("ReplicatedStorage").Shared.EffectsModules:GetDescendants()  ) do
        -- filter only Modules
        if child:IsA("ModuleScript") then
         else
            continue
        end

        if not EffectsReceiver.EffectsFunctions[child.Name] then
            EffectsReceiver.EffectsFunctions[child.Name] = require(child)
        end 
    end 

    EF_Remote.OnClientEvent:Connect(function(Plr, Method, Params, Params2)
        EffectsReceiver.RenderEffect(Plr,  Method, Params, Params2)
    end)


end


return EffectsReceiver