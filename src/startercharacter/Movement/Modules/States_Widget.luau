local Debris = game:GetService("Debris")

States_Widget = {}
States_Widget.Cache = {}


States_Widget._TestPart = function(CF)

    local P = Instance.new("Part")
    P.Parent = game.Workspace
    P.Anchored = true
    P.CanCollide = false
    P.BrickColor = BrickColor.new("Really red")
    P.CFrame = CF 



end

States_Widget._ConvertNormalIntoRot = function(u, v, axis)
        local dot, uxv = u:Dot(v), u:Cross(v)
        if (dot < -0.99999) then return CFrame.fromAxisAngle(axis, math.pi) end
        return CFrame.new(0, 0, 0, uxv.x, uxv.y, uxv.z, 1 + dot)
end

States_Widget.GetPlayerSideDash = function(Humanoid, Cam)
    
    --print(Humanoid.MoveDirection:Dot(Cam.CFrame.RightVector) )
    if Humanoid.MoveDirection.Magnitude > 0 then
    else
        return
    end

  
    local Side = nil
    local IsFoward = nil

   
    if (Humanoid.MoveDirection:Dot(Cam.CFrame.RightVector) > 0.1) then
        Side = "Right"
    end

    if (Humanoid.MoveDirection:Dot(-Cam.CFrame.RightVector) > 0.1) then
        Side = "Left"
    end

    if (Humanoid.MoveDirection:Dot(Cam.CFrame.LookVector) > 0.1) then
        Side = "Forward"
        IsFoward = "Forward"

    end
    if (Humanoid.MoveDirection:Dot(-Cam.CFrame.LookVector) > 0.1) then
        Side = "Backward"
        IsFoward = "Backward"

    end

   if not Side and not IsFoward then
        Side = "Forward"
        IsFoward = "Forward"
   end 



    return Side, IsFoward
end

States_Widget.GetDirByMoveDirection = function(Char, velocity)
    local movedir = Char.HumanoidRootPart.CFrame:VectorToObjectSpace(velocity)
    local yDirection = math.atan2(movedir.X, movedir.Z)
    local roundedDirection = math.ceil(math.deg(yDirection) - 0.5)
	
    if roundedDirection >= 5 and roundedDirection <= 150 then --strafing right
        return "Left"
    elseif roundedDirection <= -5 and roundedDirection >= -150  then --strafing left
        return "Right"
    end

end


States_Widget.CheckIfPlrIsLookingToGround = function(Char)

    local dotproduct = Char.HumanoidRootPart.CFrame.LookVector:Dot(Vector3.new(0,3,0))
    if dotproduct == 1  then
        return true
    else
        return false
    end
    
end


States_Widget.EnablePlayerControl = function(Char)
    if Char then
    else
        return
    end
    local humanoid = Char.Humanoid
    humanoid.AutoRotate = true
    humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50 
	humanoid.JumpHeight = 7.19
end

States_Widget.DisablePlayerControl = function(Char)
    local humanoid = Char.Humanoid
    humanoid.AutoRotate = false
    humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	humanoid.JumpHeight = 0
end

States_Widget.CheckIfWallIsNear = function(Char, Dir, RayHandler)

    local IsLookingToGround = States_Widget.CheckIfPlrIsLookingToGround(Char)
    if IsLookingToGround then
        return
    end

    local RootPos = Char.HumanoidRootPart.Position 
    local RayResult = RayHandler.FastRaycast(RootPos, Dir, {Char}, false )

    if RayResult then
        return true
    else
        return false
    end

end

States_Widget.IsFarFromGround = function(Char, RayHandler)
    
    local RootPos = Char.HumanoidRootPart.Position 
    local DirY = Vector3.new(0,-6,0)

    local RayResult = RayHandler.FastRaycast(RootPos, DirY, {Char}, false )
    if RayResult then
        return false 
    else 
        return true
    end

end

States_Widget.WallRunChecking = function(Char, RayHandler, StatesPerform, BasicCooldowns)
        local RootPos = Char.HumanoidRootPart.Position 
        local Dir = Char.HumanoidRootPart.CFrame.RightVector * -1.3
        local RayResult = RayHandler.FastRaycast(RootPos, Dir, {Char}, false )

        if RayResult then
            StatesPerform.TemporalyInfo.LastRayForWallRun = RayResult 
            StatesPerform.TemporalyInfo.DirForWallRun = Dir 
            StatesPerform.TemporalyInfo.AnimDir = -1

            StatesPerform.SendSignal("OnWallRunAction")
            return true
        end

        local RootPos = Char.HumanoidRootPart.Position 
        local Dir = Char.HumanoidRootPart.CFrame.RightVector * 1.3
        local RayResult = RayHandler.FastRaycast(RootPos, Dir, {Char}, false )
        if RayResult then
            StatesPerform.TemporalyInfo.LastRayForWallRun = RayResult 
            StatesPerform.TemporalyInfo.DirForWallRun = Dir 
            StatesPerform.TemporalyInfo.AnimDir = 1

            StatesPerform.SendSignal("OnWallRunAction")
            return true
        end
        
        return false
end

States_Widget.WallClimbCheck = function(Char, RayHandler, StatesPerform, BasicCooldowns)

    local IsLookingToGround = States_Widget.CheckIfPlrIsLookingToGround(Char)
    if IsLookingToGround then
        return
    end

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
    
    local IsLookingToGround = States_Widget.CheckIfPlrIsLookingToGround(Char)
    if IsLookingToGround then
        return
    end

    local function CheckForVault (RootPos, RootCF)
                
        local RayResult = RayHandler.FastRaycast(RootPos, RootCF.LookVector * 5, {Char}, false )

        -- Search what is in front of the player --
        if RayResult then
            if RayResult.Normal.Y > 0 then
                return
            end

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

States_Widget.CanSlide = function(Char, RayHandler, StatesPerform, BasicCooldowns)
    local RootPos = Char.HumanoidRootPart.Position 
    local DirY = Vector3.new(0,-4,0)
    
    local RayResult = RayHandler.FastRaycast(RootPos, DirY, {Char}, false )
    if RayResult then
        return true 
    else 
        return false
    end

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

States_Widget.SlidingCheck = function(Char, RayHandler, StatesPerform, BasicCooldowns)


    local RootPos = Char.HumanoidRootPart.Position 
    local DirY = Vector3.new(0,-10,0) 
    
    local FirstResult = RayHandler.FastRaycast(RootPos, DirY, {Char}, false )

    if FirstResult then
    
        local RootPos = Char.HumanoidRootPart.Position + ( Char.HumanoidRootPart.CFrame.LookVector * 3)
        local DirY = Vector3.new(0,-3,0) 
        
        --[[
        if true then
            return FirstResult
        end
        - -]]

        local RayResult = RayHandler.FastRaycast(RootPos, DirY, {Char}, false )
        if RayResult then
            return RayResult
        else 
            return FirstResult
        end
    end

    
end


States_Widget.PoleCheck = function(Char, RayHandler, StatePerform, BasicCooldowns, LastState )

    local rootPart = Char.HumanoidRootPart
    local CurrentC = game.Workspace.CurrentCamera.CFrame

    local MaxSize = Vector3.new(15,15,15)
    local InitialCF = rootPart.CFrame + CurrentC.LookVector * 2

    -- if we have a Last State, we change the Range 
    if LastState and LastState == "PoleJump" or LastState and LastState == "JumpFromWallrun"  then
         MaxSize = Vector3.new(15,15,20)
         InitialCF = rootPart.CFrame  + CurrentC.LookVector * (20)
         InitialCF = CFrame.lookAt(rootPart.Position  ,   InitialCF.Position )
         InitialCF = InitialCF * CFrame.new(0,0,-20/2)

         --[[
         -- Just for debug
        local P = Instance.new("Part")
        P.CFrame = InitialCF
        P.Size = MaxSize
        P.Anchored = true
        P.CanCollide = false
        P.Parent = game.Workspace
        P.Transparency =0.5
        game:GetService("Debris"):AddItem(P, 2)
        --]]
    end

    local Overlap = OverlapParams.new()
    Overlap.MaxParts = 50
    Overlap.FilterType = Enum.RaycastFilterType.Exclude
    Overlap.FilterDescendantsInstances = {Char}

    local PartsNear = workspace:GetPartBoundsInBox(InitialCF, MaxSize,Overlap )

    local PoleList = {}
    for _, Part in pairs(PartsNear) do 
        if  game:GetService("CollectionService"):HasTag(Part, "Pole") then 
            table.insert(PoleList, Part)

            --Part.BrickColor = BrickColor.new("Really red")
            task.delay(1,function()
             --   Part.BrickColor = BrickColor.new("Grey")
            end)
        end 
    end 

    -- Return Val
    if #PoleList > 0 then
         return PoleList, InitialCF
            else
         return InitialCF
    end

end

States_Widget.GetClosestPole = function(Char, RayHandler, StatePerform, BasicCooldowns,PoleList )
    
    local HrootCompar = Char.HumanoidRootPart.Position + (Char.HumanoidRootPart.CFrame.LookVector * 15)
    
    -- Check the Closest and return it.
    local LastPole = nil
    for _, Pole in pairs(PoleList) do
        
        -- If its the same pole the player is currently in,
        -- we ignore.
        if States_Widget.Cache.CurrentPole  then
            if States_Widget.Cache.CurrentPole == Pole then
               continue 
            end
        end


        if not LastPole then
            LastPole = Pole
        end

        local Magn = (Pole.Position - HrootCompar).Magnitude
        local Magn2 = (LastPole.Position - HrootCompar).Magnitude

        if Magn < Magn2 then
            LastPole = Pole
        end
    end 

    return LastPole

end

States_Widget.GetPoleY = function(Pole, RayHandler, Char)
    
    local function  GetHighestAxis(Part)
        if Part.Size.Z > Part.Size.X then
            return Part.Size.Z , CFrame.new(0,0,1) 
        elseif  Part.Size.X < Part.Size.Z then
            return Part.Size.X, CFrame.new(1,0,0) 
        elseif Part.Size.Y > Part.Size.Z  then
            return Part.Size.Y, CFrame.new(0,1,0) 
        elseif  Part.Size.Y < Part.Size.Z then
            return Part.Size.Z, CFrame.new(0,0,1) 
        elseif  Part.Size.Y > Part.Size.X then
            return Part.Size.Y, CFrame.new(0,1,0)
        
        elseif  Part.Size.Y < Part.Size.X then
            return Part.Size.X, CFrame.new(1,0,0)
        end
    end
    local HighestAxis, CF =  GetHighestAxis(Pole)
    local ActualSize = HighestAxis/2
    --  ^^ ill get what direction the part is going depending on the size,
    -- and calc that to set where our player will go so he don't go to the middle of the part

    local function GetClosest (Pole)
        local Closest = nil

        local function  Multiply(XArg, Div)
            return (XArg*0.7) * (ActualSize/ Div)
        end
        
        -- Detect with Positives Numbers
        for i = 1, 5 do 
            if Closest == nil then
                Closest =  Pole.CFrame *  ( CF *  CFrame.new(Multiply(CF.X,i),Multiply(CF.Y,i),Multiply(CF.Z,i)  )   )
                Closest = Closest.Position 
            end
            
            local Current = Pole.CFrame *   ( CF *  CFrame.new(Multiply(CF.X,i),Multiply(CF.Y,i),Multiply(CF.Z,i)  )   )
            Current = Current.Position

            local Magn = (Current - Char.HumanoidRootPart.Position).Magnitude 
            local Magn2 = (Closest - Char.HumanoidRootPart.Position).Magnitude 
            
            if Magn < Magn2 then
                Closest = Current
            end
        end 
        -- Detect with negatives 
        for i = 1, 5 do   
            local Current = Pole.CFrame *  ( CF *  CFrame.new(Multiply(CF.X,-i),Multiply(CF.Y,-i),Multiply(CF.Z,-i)  )   )
            Current = Current.Position

            local Magn = (Current - Char.HumanoidRootPart.Position).Magnitude 
            local Magn2 = (Closest - Char.HumanoidRootPart.Position).Magnitude 
            
            if Magn < Magn2 then
                Closest = Current
            end
        end 

        return Closest
    end
    local ClosestPos = GetClosest(Pole)

    local Origin =  ClosestPos + Vector3.new(0,-50,0)
    local Direction =  Vector3.new(0,100,0) 


    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.CollisionGroup = "ParkourOBJ"
    Params.IgnoreWater = true
    
    Pole.CollisionGroup = "ParkourOBJ"

    local RayResult = RayHandler.FastRaycast(Origin, Direction, {}, false, Params )
    
    if RayResult then   
        Pole.CollisionGroup = "Default"
        States_Widget.Cache.CurrentPole = Pole
        return RayResult.Position + Vector3.new(0,-3,0)
    end

end



return States_Widget