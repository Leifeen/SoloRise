RaycastHandler = {}

function MakeAVisibleLine (startPosition, direction)
        local endPosition = startPosition + direction
        local midpoint = (startPosition + endPosition) /2
        local ray =  Instance.new("Part")
        ray.Parent = workspace
        ray.Size = Vector3.new(0.2,0.2,direction.Magnitude)
        ray.CFrame = CFrame.lookAt(midpoint,startPosition)
        game:GetService("Debris"):AddItem(ray,0.5)
        ray.Color = Color3.fromRGB(250, 66, 66)
        ray.CanCollide = false
        
        ray.Material = "Neon"
        ray.Parent = game.Workspace
        ray.Anchored = true
        return ray
end


RaycastHandler.FastRaycast = function(Origin, Direction, InstToExclude, ShowDebug, CustomParams)
    local workspace = game:GetService("Workspace") 
    
    local newRayParams = nil
    if CustomParams == nil then
        newRayParams = RaycastParams.new()
        newRayParams.FilterType = Enum.RaycastFilterType.Exclude
        newRayParams.IgnoreWater = true
        newRayParams.RespectCanCollide = true
        newRayParams.FilterDescendantsInstances = {InstToExclude}
    
    else
        newRayParams = CustomParams
    end
    

    if ShowDebug then
        local ray = MakeAVisibleLine(Origin, Direction)
        table.insert(newRayParams.FilterDescendantsInstances, ray)
    end

    local newRay = workspace:Raycast(Origin, Direction, newRayParams) 
    
    -- Ignore Players Completly --
    if newRay and newRay.Instance and newRay.Instance.Parent then
        if newRay.Instance.Parent:FindFirstChild("Humanoid") then
            return nil
        end
    end
   
    return newRay
    
end


RaycastHandler.new = function()
    
end



return RaycastHandler