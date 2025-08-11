
SharedAtbHandler = {}


SharedAtbHandler.GetCharLocalAttribute = function()
    local CharMovementState = game.Players.LocalPlayer.Character:GetAttribute("LocalState")
    return CharMovementState
end


return SharedAtbHandler