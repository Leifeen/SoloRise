EffectsManager = {}

-- Effects that just need one method, no params or anything different.
EffectsManager.CallForSimpleEffect = function(Method, Params, Params2 )
    game.ReplicatedStorage.EffectsRPL:FireServer(Method, Params, Params2)
end


return EffectsManager