
States_Widget = {}

States_Widget.WallClimbCheck = function(Char, RayHandler, StatesPerform, BasicCooldowns)

    local RootPos = Char.HumanoidRootPart.Position
    local RootCF = Char.HumanoidRootPart.CFrame
    local RayResult = RayHandler.FastRaycast(RootPos, RootCF.LookVector * 3, {Char}, false )
    if RayResult then
        local ClimbInitialPos = RayResult.Position + Vector3.new(0,10,0) + (Char.HumanoidRootPart.CFrame.LookVector * .5)
        local ClimbFinalPos = Vector3.new(0,-3,0)  
       
        local EasyClimbResult = RayHandler.FastRaycast(ClimbInitialPos , ClimbFinalPos, {Char}, false )
        if EasyClimbResult then 
            StatesPerform.TemporalyInfo.LastPosRayForWallClimb = EasyClimbResult.Position + Vector3.new(0,-1,0) + (Char.HumanoidRootPart.CFrame.LookVector * -.5)
            StatesPerform.SendSignal("WallHang")
        else
            return "CanClimb"
        end 

    else
        return "NoWall"
    end

end

States_Widget.VaultChecking = function(Char, RayHandler, StatesPerform, BasicCooldowns)
    local function CheckForVault (RootPos, RootCF)
                
        local RayResult = RayHandler.FastRaycast(RootPos, RootCF.LookVector * 5, {Char}, false )
        -- Search what is in front of the player --
        if RayResult then
            -- Search if it is worth to vault
            local RayResult = RayHandler.FastRaycast(RayResult.Position + (Char.HumanoidRootPart.CFrame.LookVector * .3) + Vector3.new(0,3,0) , Vector3.new(0,-4,0), {Char}, false )
            
            -- Check if the Player can actually Vault it 
            if RayResult then
                local LastRayResult = RayHandler.FastRaycast(RayResult.Position + (Char.HumanoidRootPart.CFrame.LookVector * .3) + Vector3.new(0,3,0) , Vector3.new(0,5,0), {Char}, false )
                
                if not LastRayResult and not StatesPerform.LastStateGarbage.Debounce  then
                    
                    -- Check the small cooldown window that we have.
                    if   StatesPerform.Cooldowns["Vault"] then 
                        if  os.clock() -  StatesPerform.Cooldowns["Vault"]  < BasicCooldowns.ReactionMovesCooldowns.Vault then 
                            return 
                        end 
                    end 
    
                    StatesPerform.TemporalyInfo.LastRayPosForVault = RayResult.Position + (Char.HumanoidRootPart.CFrame.LookVector * .3) + Vector3.new(0,3,0)
                    StatesPerform.SendSignal("Vault")
                    StatesPerform.LastStateGarbage.Debounce = true
                end      
            end
    
        end
    
    end
    
    -- Will do 2 Checks. -- 
    
    CheckForVault(Char.HumanoidRootPart.Position, Char.HumanoidRootPart.CFrame )
    CheckForVault(Char.HumanoidRootPart.Position + Vector3.new(0,-1.5,0) , Char.HumanoidRootPart.CFrame )
    
        
end

States_Widget.IsCloseToGround = function(Char, RayHandler, StatesPerform, BasicCooldowns)

    local RootPos = Char.HumanoidRootPart.Position + Vector3.new(0,-3,0)
    local DirY = Vector3.new(0,-4,0)

    local RayResult = RayHandler.FastRaycast(RootPos, DirY, {Char}, false )
    if RayResult then
        return true 
    else 
        return false
    end

end

States_Widget.IsJumpInAir = function(Char, RayHandler, StatesPerform, BasicCooldowns)
    local RootPos = Char.HumanoidRootPart.Position + Vector3.new(0,-3,0)
    local DirY = Vector3.new(0,-2,0)

    local RayResult = RayHandler.FastRaycast(RootPos, DirY, {Char}, false )
    if RayResult then
        return true 
    else 
        return false
    end
end


return States_Widget