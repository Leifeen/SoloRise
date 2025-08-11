
local ServerRemotesHandler = {}
ServerRemotesHandler.ExistingRemotes = {}
local RemotesCalloutWidget = require(script.Parent.RemotesCalloutWidget)

ServerRemotesHandler.AvaibleRemotes = {
    ClientEffects = "EffectsRPL",
    UI_SignalSender = "UI_Update" -- this is for cooldowns and other extra stuff;
    -- cliend side only ^
}

ServerRemotesHandler.GetRemote = function(RemoteName: string)
    if ServerRemotesHandler.ExistingRemotes[RemoteName] then
        return ServerRemotesHandler.ExistingRemotes[RemoteName]
    end
end

ServerRemotesHandler.Init = function()
    
    -- This will be for Effect RPL
    local EffectRPL = Instance.new("RemoteEvent")
    EffectRPL.Parent = game.ReplicatedStorage
    EffectRPL.Name = "EffectsRPL"
    ServerRemotesHandler.ExistingRemotes[EffectRPL.Name] = EffectRPL
    RemotesCalloutWidget.EffectsRPL(EffectRPL)

    local UISignalHandler = Instance.new("RemoteEvent")
    UISignalHandler.Parent = game.ReplicatedStorage
    UISignalHandler.Name = "UI_Update"
    ServerRemotesHandler.ExistingRemotes[UISignalHandler.Name] = UISignalHandler

end



return ServerRemotesHandler