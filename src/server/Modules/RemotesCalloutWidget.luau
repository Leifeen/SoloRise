
RemotesCalloutWidget  = {}

RemotesCalloutWidget.EffectsRPL = function(MainRemote)
    MainRemote.OnServerEvent:Connect(function(Plr, Method, Params, Params2)
        MainRemote:FireAllClients(Plr.Name, Method, Params, Params2)
    end)
end


return RemotesCalloutWidget