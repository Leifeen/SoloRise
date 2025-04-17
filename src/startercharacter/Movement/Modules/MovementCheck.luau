
MovementCheck = {}

MovementCheck.CharPhysics = require(script.Parent.CharPhysics)
local RayHandler = require(game:GetService("ReplicatedStorage").Shared.Utility.RaycastHandler ) 

-- Important -- 
MovementCheck.CheckIfCanVault = function(Char)

    local Hroot = Char.HumanoidRootPart
    local Origin = Hroot.Position 
    local Direction = Hroot.Position + (Hroot.CFrame.LookVector * 5)

    local Result = RayHandler.FastRaycast(Origin, Direction, {Char}, true)
    
    if Result then
        
    end


end






return MovementCheck
