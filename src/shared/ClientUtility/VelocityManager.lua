
VelocityManager = {}

VelocityManager.RenderVel = function(Velocity)
    

    if not Velocity then
         return 
    end
    -- it will replicate anyways.
    if Velocity.Parent.Parent == game.Players.LocalPlayer.Character then
        print("Not responsible for it.")
        return
    end

    local OriginalVel = Velocity
    OriginalVel.Enabled = false 

    local NewVel = OriginalVel:Clone()
    NewVel.Parent = Velocity.Parent 
    NewVel.Enabled = true

    local WaitUntilDestroyed = nil
    WaitUntilDestroyed = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        if OriginalVel and OriginalVel.Parent  then 
           
        else
            NewVel:Destroy() 
            WaitUntilDestroyed:Disconnect()
        end 
    end)


end


VelocityManager.ClientInit = function()
    local VelocityRP = game.ReplicatedStorage:WaitForChild("VelocityReplication")
    
    VelocityRP.OnClientEvent:Connect(function(Velocity)
        VelocityManager.RenderVel(Velocity)
    end)

end

VelocityManager.CallClients = function(Velocity)
    game.ReplicatedStorage.VelocityReplication:FireAllClients(Velocity)
end

VelocityManager.ServerInit = function()
    local REvent = Instance.new("RemoteEvent")
    REvent.Parent = game.ReplicatedStorage
    REvent.Name = "VelocityReplication"
end

return VelocityManager