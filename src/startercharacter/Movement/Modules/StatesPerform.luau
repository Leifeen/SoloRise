StatesPerform = {}
StatesPerform.LastStateGarbage = {}
StatesPerform.Cooldowns = {}
local MovesConfigs = game:GetService("ReplicatedStorage").MovementConfigs 
local DbSV = game:GetService("Debris")

-- some states will send info for each other, 
-- like last raycast Pos and stuff like that. 
StatesPerform.TemporalyInfo = {}

StatesPerform.AnimTracks = {}

-- Modules --
local InputMovesHandler = require(game:GetService("ReplicatedStorage").Shared.gameplay.InputMovesHandler)

local CharPhysics = require( script.Parent.CharPhysics )
local RayHandler = require( game:GetService("ReplicatedStorage").Shared.Utility.RaycastHandler )
local FastAnimTrack = require(game:GetService("ReplicatedStorage").Shared.Utility.FastAnimTrack )
local EasyInstances = require(game:GetService("ReplicatedStorage").Shared.Utility.EasyInstances)

local MovementAnims = require( game.Players.LocalPlayer.Character.CharacterScripts.Animation.MovementsAnimationHandler )
local BasicCooldowns = require(game:GetService("ReplicatedStorage").Shared.gameplay.Cooldowns.BasicCooldowns)  
local StateWidget = require(script.Parent.States_Widget )

local EffectsManager = require(game:GetService("ReplicatedStorage").Shared.gameplay.EffectsManager )

StatesPerform._CallForSpeedBoost = function()

    
    if StatesPerform.BoostIncrease then
        task.cancel(StatesPerform.BoostIncrease)
    end
    StatesPerform.BoostIncrease = task.spawn(function()
        for i = 1, 10 do 
            CharPhysics.SpeedBoost += 1
            task.wait()
        end         
        EffectsManager.CallForSimpleEffect("Speedboost", true)    

    end)


    local function SpeedBoostEffect ()
        EffectsManager.CallForSimpleEffect("Speedboost", true)    
        repeat task.wait()
        until CharPhysics.SpeedBoost == 0
        EffectsManager.CallForSimpleEffect("Speedboost", false)    
        
    end

    if not StatesPerform.BoostSpeedEffect then
        StatesPerform.BoostSpeedEffect =  task.spawn(function()
           SpeedBoostEffect() 
        end)
    else
        if coroutine.status(StatesPerform.BoostSpeedEffect) == "dead" then
            task.cancel(StatesPerform.BoostSpeedEffect)
            StatesPerform.BoostSpeedEffect =  task.spawn(function()
                SpeedBoostEffect() 
             end)
        end
    end
    
end


StatesPerform.SendSignal = function(NewState, Method)
    local ReactBD = nil
    if not script:FindFirstChild("ReactionAction") then 
        local NewBindable = Instance.new("BindableEvent")
        NewBindable.Name = "ReactionAction"
        NewBindable.Parent = script
        ReactBD = NewBindable
    else
        ReactBD = script.ReactionAction
    end 

    ReactBD:Fire(NewState, Method)

    return ReactBD
end

-- Clean Threads and other Stuff. --
StatesPerform.CleanGarbage = function()

    local sucess , err = pcall(function()
        for _, child in pairs(StatesPerform.TemporalyThreads) do 
            task.cancel(child)
        end
    end)

    local sucess , err = pcall(function()
        task.cancel(StatesPerform.LastStateGarbage.Thread)
    end)
    local sucess, err = pcall(function()
        StatesPerform.ResetItself()
        StatesPerform.ResetItself = nil
    end)

end
------------
-- Just cancel lol
StatesPerform._CancelAllMoves = function(Char)
    StatesPerform.CleanGarbage()
    StateWidget.EnablePlayerControl(Char)
end

-- Dash 
StatesPerform.DashCDConfig = {
    LastTime = 10000,
    MaxTime = 2
}
StatesPerform.Dash = function(LastState, Char)
    

    local PlrSide, IsFoward, RightFromCameraAngle, LookVecFromCameraAngle = StateWidget.GetPlayerSideDash(
        game.Players.LocalPlayer.Character.Humanoid, 
        game.Workspace.CurrentCamera
    )
    if PlrSide then
        if typeof(LastState) == "boolean" then

            -- Don't do dash if in cooldown
            if  game.Workspace:GetServerTimeNow() - StatesPerform.DashCDConfig.LastTime > 2 then
                
            else
                return false 
            end


            return true  
        end 
        -- ^ want to verify first.
    else 
        return false
    end 

    StatesPerform.CleanGarbage()

    game.Players.LocalPlayer.Character.CharActions:FireServer(
        {
           Event = "Dash",
        }
    )

    local WaitForResponse = nil 
    WaitForResponse = game.Players.LocalPlayer.Character.CharActions.OnClientEvent:Connect(function(tab)

        if tab and tab.Event == "DashResponse" then 
        else 
            return
        end 

        -- Dash failed.
        if tab and tab.Enable then 
            
        else     
             WaitForResponse:Disconnect()
             WaitForResponse = nil    
            StatesPerform.SendSignal("Landed", "ForceState")
            return 
        end 

        StatesPerform.DashCDConfig = {
            LastTime = tab.CurrentTime, 
            MaxTime = tab.FinalTime 
        }

        local LinearVel, Attach1, Attach2 = EasyInstances.CreateLinearIntoChar(Char)
        LinearVel.ForceLimitMode = Enum.ForceLimitMode.PerAxis
        LinearVel.ForceLimitsEnabled = true 
        LinearVel.MaxForce = 18000
        LinearVel.MaxAxesForce = Vector3.new(math.huge,0,math.huge)
        
        LinearVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        LinearVel.ReactionForceEnabled = false
        LinearVel.VectorVelocity = Vector3.new(0,0,0)


        local ActionsSided = {
            ["Forward"] = function()
                --LinearVel.VectorVelocity = LookVecFromCameraAngle * 3000
                LinearVel.VectorVelocity = Vector3.new(0,0,-50)
                DbSV:AddItem(LinearVel, 0.2)
                DbSV:AddItem(Attach1, 0.2)
                DbSV:AddItem(Attach2, 0.2)
            end,
            ["Backward"] = function()
                --LinearVel.VectorVelocity = LookVecFromCameraAngle * -3000
                LinearVel.VectorVelocity = Vector3.new(0,0,50)
                DbSV:AddItem(LinearVel, 0.2)
                    DbSV:AddItem(Attach1, 0.2)
                DbSV:AddItem(Attach2, 0.2)
            end,
            ["Right"] = function(LookVec)
                --LinearVel.VectorVelocity = RightFromCameraAngle * -3000 + (LookVec)
                LinearVel.VectorVelocity = Vector3.new(50,0,0)
                DbSV:AddItem(LinearVel, 0.2)
                    DbSV:AddItem(Attach1, 0.2)
                DbSV:AddItem(Attach2, 0.2)
            end,
            ["Left"] = function(LookVec)
                --  LinearVel.VectorVelocity = RightFromCameraAngle * 3000 + (LookVec)
                LinearVel.VectorVelocity = Vector3.new(-50,0,0)
                DbSV:AddItem(LinearVel, 0.2)
                    DbSV:AddItem(Attach1, 0.2)
                DbSV:AddItem(Attach2, 0.2)
            end,
        }
        if IsFoward and PlrSide ~= IsFoward then 
            ActionsSided[IsFoward]()
        end 
        ActionsSided[PlrSide]( Vector3.zero )
    
        MovementAnims.Dash(PlrSide)

        DbSV:AddItem(LinearVel, 0.2)

        StatesPerform.SendSignal("Landed", "ForceState")

        WaitForResponse:Disconnect()
        WaitForResponse = nil
    end)

    
    


end


-- Vault 
StatesPerform.Vault = function(LastState, Char)

    StatesPerform.CleanGarbage()
    Char.Humanoid.AutoRotate = false
    StateWidget.DisablePlayerControl(Char)

    -- Will play the animation
    MovementAnims.VaultAction()

    local PosToGo = StatesPerform.TemporalyInfo.LastRayPosForVault

    -- Align and Linear Vel
    local AlignPos, Attach1, Attach2 = EasyInstances.CreateAlignPosIntoChar(Char)
    AlignPos.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    AlignPos.ForceRelativeTo = Enum.ActuatorRelativeTo.World
    AlignPos.MaxAxesForce = Vector3.new(0,10000000,0)
    AlignPos.Responsiveness = 50
    AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    AlignPos.Position = PosToGo
    AlignPos.MaxVelocity = 100000000

    EasyInstances.DestroyWDebris(AlignPos, .3)
    EasyInstances.DestroyWDebris(Attach1, .3)
    EasyInstances.DestroyWDebris(Attach2, .3)

    local LinearVel, Attach1, Attach2 = EasyInstances.CreateLinearIntoChar(Char)
    LinearVel.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    LinearVel.MaxAxesForce = Vector3.new(100000,0,100000)
    LinearVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    LinearVel.VectorVelocity = Vector3.new(0,0,-30)
    

    EasyInstances.DestroyWDebris(LinearVel, .3)
    EasyInstances.DestroyWDebris(Attach1, .3)
    EasyInstances.DestroyWDebris(Attach2, .3)
    task.delay(.3, function()
        StateWidget.EnablePlayerControl(Char)
    end)

    StatesPerform.Cooldowns["Vault"] = os.clock()

    StatesPerform._CallForSpeedBoost()

    StatesPerform.SendSignal("Falling")
   
    Char.Humanoid.AutoRotate = true
    Char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)


end

StatesPerform.WallClimbJump = function(LastState, Char)
    StatesPerform.CleanGarbage()

    Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,30,0) + (Char.HumanoidRootPart.CFrame.LookVector * -50)
    MovementAnims.WallJump()
    StatesPerform.SendSignal("JumpAirTime")

    StatesPerform._CallForSpeedBoost()


end

-- Wall climb 
StatesPerform.WallClimb = function(LastState, Char, HoldingState )
    StatesPerform.CleanGarbage()


    -- Will play the animation
    local ClimbAnimTrack = MovementAnims.WallClimbAction()

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
              -- Make This Thread inside so we can continue to Check for Climb Action or Vault.
            local VaultOrWall = task.spawn(function()
                
                while  task.wait() do
                        -- keep checking for vault  and wall 
                    StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)
                    local ClimbResult = StateWidget.WallClimbCheck(Char, RayHandler, StatesPerform, BasicCooldowns)    
                    Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,30,0)
                    
                    -- not holding W? so do Jump Instead
                    if not  InputMovesHandler.IsHoldingKey( Enum.KeyCode.W ) then
                        ClimbAnimTrack:Stop(.2)
                        StatesPerform.SendSignal("WallClimbJump")
                        break
                    end

                    if ClimbResult == "NoWall" then
                        ClimbAnimTrack:Stop(.2)
                        StatesPerform.SendSignal("JumpAirTime")
                        break
                    end
                end
    
            end)
            StatesPerform.TemporalyThreads = {}
            table.insert(StatesPerform.TemporalyThreads, VaultOrWall)

            ClimbAnimTrack.Stopped:Wait()
            StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)
            
            StatesPerform.SendSignal("Falling", "ForceState")

    end)

end
-- Wall Hang 
StatesPerform.WallHang = function(LastState, Char, HoldingState)
    StatesPerform.CleanGarbage()
    
    -- will use it to Hang the Player for the position we want.
    local PosToGo =  StatesPerform.TemporalyInfo.LastPosRayForWallClimb
    StateWidget.WallClimbCheck(Char, RayHandler, StatesPerform, BasicCooldowns)     

    Char.Humanoid.AutoRotate = false

    MovementAnims.HangIdle()

    -- Align Pos to stay on Hang pos
    local AlignPos, Attach1, Attach2 = EasyInstances.CreateAlignPosIntoChar(Char)
    AlignPos.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    AlignPos.ForceRelativeTo = Enum.ActuatorRelativeTo.World
    AlignPos.MaxAxesForce = Vector3.new(100000,100000,100000)
    AlignPos.Responsiveness = 50
    AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    AlignPos.Position = PosToGo + Vector3.new(0,-1.2,0) + (Char.HumanoidRootPart.CFrame.LookVector * -1.5)
    AlignPos.ReactionForceEnabled = true

    local AlignOrien, Attach3, Attach4 = EasyInstances.CreateAlignOrient(Char)
    AlignOrien.MaxTorque = 100000
    AlignOrien.PrimaryAxisOnly = true
    AlignOrien.AlignType = Enum.AlignType.PrimaryAxisPerpendicular


    local OnSpacePressed = InputMovesHandler.Create("ClimbWall", Enum.KeyCode.Space, {InputMovesHandler.States.Began}, 100, "TemporalyAction")
    OnSpacePressed:OnKeyActionReceive():Connect(function(Action)
        OnSpacePressed:DestroyMove()


        -- We don't need it anymore. so... 
        local ClimbAnim = MovementAnims.HangClimb()
        AlignPos.Responsiveness = 10

        task.spawn(function()
            local LastV = Char.HumanoidRootPart.CFrame.LookVector
            AlignPos.Position = PosToGo + Vector3.new(0,3,0) + Char.HumanoidRootPart.CFrame.LookVector * -1.5
            repeat
                task.wait()
            until ClimbAnim.TimePosition > 1 or not ClimbAnim or not ClimbAnim.IsPlaying
            AlignPos.Position = PosToGo + Vector3.new(0,3.5,0) + LastV * 1.5
        end)

        
        ClimbAnim.Stopped:Wait()
        AlignPos.Responsiveness = 50
        task.wait(.1)

        AlignPos:Destroy()
        Char.Humanoid.AutoRotate = true

        StatesPerform.SendSignal("Landed")
    end)

end

StatesPerform.StopRunning = function(LastState, Char)

    StatesPerform.CleanGarbage()
    Char.Humanoid.WalkSpeed = 16
    MovementAnims.StopRunAction()


end

StatesPerform.Running = function(LastState, Char, HoldingState, CanDoMov)
    
    StatesPerform.CleanGarbage()
    
    -- so others States just stop it.
    StatesPerform.ResetItself = function()
        Char.Humanoid.WalkSpeed = 16
        CharPhysics.StayBoost = false
        MovementAnims.StopRunAction()

        task.cancel(StatesPerform.LastStateGarbage.SpeedIncrease)

    end

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()

      StatesPerform.LastStateGarbage.Connections = {}
      StatesPerform.LastStateGarbage.Debounce = false

      StatesPerform.LastStateGarbage.SpeedIncrease =  task.delay(4, function()
            StatesPerform._CallForSpeedBoost()
       end)


       while  task.wait() do 
            CharPhysics.StayBoost = true 

            MovementAnims.RunAction()

            StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)

            Char.Humanoid.WalkSpeed = 24 + ( CharPhysics.SpeedBoost * 2 ) 

            -- if is in air we cancel the Running
            local IsCloseToGround = StateWidget.CanSlide(Char, RayHandler, StatesPerform, BasicCooldowns)
            if not IsCloseToGround then 
                StatesPerform.SendSignal("Falling", "ForceState")
                break
            end 

            -- Stop if running during stun!
            if CanDoMov("Running") then 
            else 
                StatesPerform.SendSignal("StopRunning", "ForceState")
                break
            end 



        end

        
    end)

end

StatesPerform.JumpAirTime = function(LastState, Char)

    StatesPerform.CleanGarbage()
   
    local OnSpacePressed = InputMovesHandler.Create("TryToClimb", Enum.KeyCode.Space, {InputMovesHandler.States.Began}, 100, "TemporalyAction")

    -- Lets Create it!
       OnSpacePressed:OnKeyActionReceive():Connect(function(Action)
            local ClimbResult = StateWidget.WallClimbCheck(Char, RayHandler, StatesPerform, BasicCooldowns)     
           if ClimbResult == "CanClimb" then
               StatesPerform.SendSignal("WallClimb", "ForceState")
               OnSpacePressed:DestroyMove()            
           end
      end)

    StatesPerform.ResetItself = function()
        MovementAnims.FallAnim(false)
        OnSpacePressed:DestroyMove()            
    end

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        while  task.wait() do
            local StillInAir = StateWidget.CanSlide(Char, RayHandler, StatesPerform, BasicCooldowns)
            
            MovementAnims.FallAnim(true)

            if  StillInAir then 
                StatesPerform.SendSignal("Landed", "ForceState")  
                MovementAnims.FallAnim(false)

            else

            end
        end
    end)

end

StatesPerform.DoubleJump = function(LastState, Char)

    -- Check First.
    if typeof( LastState) ~= "string" then
       if  StatesPerform.TemporalyInfo.ExecutedDoubleJump then
            return false
              else
            return true 
       end

    end 

    StatesPerform.TemporalyInfo.ExecutedDoubleJump = true

    StatesPerform.CleanGarbage()

    Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,50,0)

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        task.wait(.3)
        local StillInAir = StateWidget.CanSlide(Char, RayHandler, StatesPerform, BasicCooldowns)
        if not StillInAir then 
            StatesPerform.SendSignal("JumpAirTime")
            -- we just do it after the JUMP (if we want to do it again)
        else 
           
            StatesPerform.SendSignal("Landed")
        end 
    end)
    
end


-- Pole Mechanic -- 
StatesPerform.PoleJump = function(LastState, Char)
    

      local HasPoleNear, CFVal = StateWidget.PoleCheck(Char, RayHandler, StatesPerform, BasicCooldowns, "PoleJump")   
     
      local ClosestPole = nil
      if typeof(HasPoleNear) == "table" then
      -- Get Closest Pole 
         ClosestPole = StateWidget.GetClosestPole(Char, RayHandler, StatesPerform, BasicCooldowns, HasPoleNear)
      end 
    
      if HasPoleNear and ClosestPole then
            
        StatesPerform.TemporalyInfo.Poles = HasPoleNear

            local PoleFL = MovementAnims.PoleFollow()
            StatesPerform.TemporalyInfo.PoleJumpTrack = PoleFL
            task.wait(.15)
            -- Clean Stuff from others States
            
            StatesPerform.PoleMechanic("PoleJump", Char)

            return
       end

       
       
       StatesPerform.TemporalyInfo.PoleJumpCancelled = true 
       
       MovementAnims._StopAllAnimtracks()
       local AnimTrack = MovementAnims.PoleLastJump()
       repeat
            task.wait()
       until  AnimTrack.TimePosition > 2
       Char.Humanoid.AutoRotate = true 

       StatesPerform.CleanGarbage()

       Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,20,0) 

       if CFVal then 
            Char.HumanoidRootPart.AssemblyLinearVelocity = Char.HumanoidRootPart.AssemblyLinearVelocity + (CFVal.LookVector * 100)        
       else
            Char.HumanoidRootPart.AssemblyLinearVelocity = Char.HumanoidRootPart.AssemblyLinearVelocity + (HasPoleNear.LookVector * 100)        
       end 

       StatesPerform._CallForSpeedBoost()

       StatesPerform.SendSignal("JumpAirTime")
       StatesPerform.TemporalyInfo.PoleJumpCancelled = false

end

StatesPerform.PoleMechanic = function(LastState, Char )
    
   

    -- Just want to verify.
    if  typeof(LastState) ~= "string" then
        local CanDoAction = StateWidget.PoleCheck(Char, RayHandler, StatesPerform, BasicCooldowns)   
        StatesPerform.TemporalyInfo.Poles = CanDoAction


        if CanDoAction and typeof(CanDoAction) == "table" then


             -- Normal Action
             local PolesList: {} =  StatesPerform.TemporalyInfo.Poles 

             -- Get Closest Pole 
             local ClosestPole = StateWidget.GetClosestPole(Char, RayHandler, StatesPerform, BasicCooldowns, PolesList)

            if ClosestPole then 
                return true
            else
                return false
            end 

        else
            return false
        end 
    end
    -- Clean Stuff from others States
    StatesPerform.CleanGarbage()

  
    
    -- Align Pos to stay on Hang pos
    local AlignPos, Attach1, Attach2 = EasyInstances.CreateAlignPosIntoChar(Char)
    local AlignOrien, Attach3, Attach4 = EasyInstances.CreateAlignOrient(Char)
    -- ALign Orient to follow the Pole orient ^

    local PosToGo = nil 
    -- ^ ill set this in future

    local FuncsThreads = {}
    -- First Grab so we play this
    if LastState ~= "PoleJump" then
        MovementAnims.PoleGrab()
        MovementAnims.EnablePoleIdle(true)       
    else


        FuncsThreads.WaitForTrack =  task.spawn(function()
            --StatesPerform.TemporalyInfo.PoleJumpTrack:AdjustWeight(0.1)
            --task.wait(.45)
            StatesPerform.SendSignal("PoleMechanic", "ReturnState")
            
            MovementAnims.PoleGrab(.6, 1)

            --AlignPos.Responsiveness = 50
            --MovementAnims.PoleGrab(.2)      
        end)
    end

    -- Normal Action
    local PolesList: {} =  StatesPerform.TemporalyInfo.Poles 

    -- Get Closest Pole 
    local ClosestPole = StateWidget.GetClosestPole(Char, RayHandler, StatesPerform, BasicCooldowns, PolesList)

    if ClosestPole then

        PosToGo = StateWidget.GetPoleY(ClosestPole, RayHandler, Char)

        if PosToGo then
        else
            StatesPerform.SendSignal("Falling", "ForceState")
            return
        end
        
        Char.Humanoid.AutoRotate = false 
        
        local FrontView = true

        PosToGo = Char.HumanoidRootPart.CFrame:Lerp(CFrame.new(0,0,0) + PosToGo + Vector3.new(0,.8,0) , 1)
        PosToGo = PosToGo.Position

        local InitialLookV = CFrame.lookAt(Char.PrimaryPart.Position,  Vector3.new(PosToGo.X,Char.PrimaryPart.Position.Y,PosToGo.Z)  )

        AlignPos.ForceLimitMode = Enum.ForceLimitMode.PerAxis
        AlignPos.ForceRelativeTo = Enum.ActuatorRelativeTo.World
        AlignPos.MaxAxesForce = Vector3.new(100000,100000,100000)

        if LastState ~= "PoleJump" then
            local Calc = (Char.HumanoidRootPart.Position - PosToGo).Magnitude
            AlignPos.Responsiveness = 11 + ( 200 / (Calc*0.3  )  )
        else 
            local Calc = (Char.HumanoidRootPart.Position - PosToGo).Magnitude
            AlignPos.Responsiveness = 11 + (  Calc*0.3 + (Char.HumanoidRootPart.Position.Y - PosToGo.Y)  )  

            AlignPos.Responsiveness = math.clamp(AlignPos.Responsiveness, 15,30)

        end 
     

        AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
        AlignPos.Position = PosToGo
        --AlignPos.ReactionForceEnabled = true
        
        AlignOrien.MaxTorque = 1000000
        AlignOrien.RigidityEnabled = true
        AlignOrien.Responsiveness = 200
        AlignOrien.AlignType = Enum.AlignType.AllAxes
        AlignOrien.CFrame = InitialLookV
        AlignOrien.Mode = Enum.OrientationAlignmentMode.OneAttachment

        print(AlignPos.Responsiveness)

        -- we wait for animationtrack
        if LastState == "PoleJump" or LastState == "JumpFromWallrun" then
            task.wait(.45)
        end

        -- rotate the player if he sees behind
        StatesPerform.LastStateGarbage.Thread = task.spawn(function()
            local DB = false
            local MaxResponsiveness = 200
            local InitialResponsiveness =  AlignPos.Responsiveness
            
            while task.wait() do
                
                -- This will update our align position
                if InitialResponsiveness < MaxResponsiveness then 
                    local Calc = (Char.HumanoidRootPart.Position - AlignPos.Position).Magnitude
                    InitialResponsiveness += 1 + (1 * (Calc/100))
                   -- AlignPos.Responsiveness = InitialResponsiveness
                end 

                if DB == true then
                    continue
                end

                local CamerDot = InitialLookV.LookVector:Dot(Vector3.new(game.Workspace.CurrentCamera.CFrame.LookVector.X,Char.HumanoidRootPart.Position.Y,game.Workspace.CurrentCamera.CFrame.LookVector.Z ))
                
                if CamerDot <= -0.6 and FrontView == true then
                    AlignOrien.CFrame = InitialLookV * CFrame.Angles(0,math.rad(180),0)   
                    DB = true
                    FrontView = false

                    MovementAnims.PoleTurn(1)

                    task.wait(.5)
                    DB = false
                elseif CamerDot >= 0.6 and  FrontView == false then
                    AlignOrien.CFrame = InitialLookV  
                    DB = true
                    FrontView = true

                    MovementAnims.PoleTurn(-1)

                    task.wait(.5)
                    DB = false
                end

            end
        end)
        
         -- Make a new Input for playe leaving from the Pole
         local OnSpacePress = InputMovesHandler.Create("PoleLeave", Enum.KeyCode.Space,{"Began"}, 100, "Movement")
        

        StatesPerform.ResetItself = function()
            AlignPos:Destroy()
            Attach2:Destroy()
            Attach1:Destroy()

            AlignOrien:Destroy()
            Attach3:Destroy()
            Attach4:Destroy()

            OnSpacePress:DestroyMove()

            local sucess, err = pcall(function()
                task.cancel(FuncsThreads.WaitForTrack)  
            end)        
        end

      
      

        OnSpacePress:OnKeyActionReceive():Connect(function()

            local sucess, err = pcall(function()
                task.cancel(FuncsThreads.WaitForTrack)                
            end)

            StatesPerform.SendSignal("PoleJump", "ForceState")

          

            OnSpacePress:DestroyMove()
            OnSpacePress = nil
        end)

        return
    end

   -- StatesPerform.SendSignal("PoleJump", "ForceState")


end




-- WallRun --
-- This is more of a reaction than a Action -- 
StatesPerform.JumpFromWallrun = function(LastState, Char)
    StatesPerform.CleanGarbage()


    -- RESET Double Jump, so player can jump in Air
    StatesPerform.TemporalyInfo.ExecutedDoubleJump = false 

    local JumpAnim = MovementAnims.JumpFromWallRun(StatesPerform.TemporalyInfo.AnimDir)

    local FowardForce = Char.HumanoidRootPart.CFrame.LookVector * MovesConfigs.WallBoost.ForwardVelocity.Value 
    Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, MovesConfigs.WallBoost.Height.Value, 0) + -( StatesPerform.TemporalyInfo.DirForWallRun * MovesConfigs.WallBoost.SideVelocity.Value) + FowardForce

    -- Pole Mechanic --
    -- ill add here for better gameplay, we casually check if we can do a pole directly
    local CanDoAction = StateWidget.PoleCheck(Char, RayHandler, StatesPerform, BasicCooldowns)   
    local HasPoleNear, CFVal = StateWidget.PoleCheck(Char, RayHandler, StatesPerform, BasicCooldowns, "PoleJump")   
     
    local ClosestPole = nil
    if typeof(HasPoleNear) == "table" then
    -- Get Closest Pole 
       ClosestPole = StateWidget.GetClosestPole(Char, RayHandler, StatesPerform, BasicCooldowns, HasPoleNear)
       if ClosestPole then 
            StatesPerform.TemporalyInfo.Poles = HasPoleNear
            StatesPerform.PoleMechanic("JumpFromWallrun", Char)
            StatesPerform.SendSignal("PoleMechanic", "ReturnState")

           return
       end 
       
       
    end 

    -- if we don't find any pole, goes normal.

    StatesPerform.SendSignal("JumpAirTime")
    StatesPerform._CallForSpeedBoost()

end

-- This is more of a reaction than a Action -- 
StatesPerform.OnWallRunAction = function(LastState, Char)
    StatesPerform.CleanGarbage()

    local RayInfo =  StatesPerform.TemporalyInfo.LastRayForWallRun
    local OriginalDir =  StatesPerform.TemporalyInfo.DirForWallRun
    local Normal = RayInfo.Normal
    
    -- Render our Effect for all plrs
    EffectsManager.CallForSimpleEffect("Wallrun", true, StatesPerform.TemporalyInfo.AnimDir )

    local AlignX = Normal:Cross(Char.PrimaryPart.CFrame.UpVector)
    local AlignY = Normal:Cross(Char.PrimaryPart.CFrame.UpVector)
	local FromMatrixResult = CFrame.fromMatrix(Char.PrimaryPart.Position, AlignY, Normal, AlignX )
    -- Lets Create a linear and Orientation for it 

    Char.Humanoid.AutoRotate = false

    local AlignOrien, Attach3, Attach4 = EasyInstances.CreateAlignOrient(Char)
    AlignOrien.PrimaryAxisOnly = true
    AlignOrien.AlignType = Enum.AlignType.PrimaryAxisPerpendicular
	AlignOrien.Parent = Char.HumanoidRootPart
	AlignOrien.Responsiveness = 200
	AlignOrien.Mode = Enum.OrientationAlignmentMode.OneAttachment
	AlignOrien.CFrame = FromMatrixResult * CFrame.Angles(0,90,0)
	AlignOrien.MaxTorque = 10000
	AlignOrien.PrimaryAxisOnly = true
	AlignOrien.AlignType = Enum.AlignType.PrimaryAxisPerpendicular
	AlignOrien.RigidityEnabled = true

    -- Align Pos -- 
    local AlignPos, Attach1, Attach2 = EasyInstances.CreateAlignPosIntoChar(Char)
    AlignPos.ForceLimitMode = Enum.ForceLimitMode.PerAxis
    AlignPos.ForceRelativeTo = Enum.ActuatorRelativeTo.World
    AlignPos.MaxAxesForce = Vector3.new(10000,10000,10000)
    AlignPos.Responsiveness = 100
    AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    AlignPos.Position = RayInfo.Position

    local ACCL = Vector3.new()

    -- will Play the WallRun animation 
    local WallRunAnim = MovementAnims.WallRunAction(StatesPerform.TemporalyInfo.AnimDir)

    local function DestroyLinears ()
        AlignOrien:Destroy()
        Attach1:Destroy()
        Attach3:Destroy()
        Attach4:Destroy()
        Attach2:Destroy()
        AlignPos:Destroy()
    end

    -- This Action Here ill use so the player can Leave from the Wall if he wants.
    local OnSpacePressed = InputMovesHandler.Create("JumpFromWallrun", Enum.KeyCode.Space, {InputMovesHandler.States.Began}, 100, "TemporalyAction")

    -- so others States just stop it.
    StatesPerform.ResetItself = function()
        WallRunAnim:Stop()
        Char.Humanoid.AutoRotate = true
        local sucess, err = pcall(function()
            OnSpacePressed:DestroyMove()            
        end)
        -- This Callout is to stop the effect.
        EffectsManager.CallForSimpleEffect("Wallrun", false)

    end

    -- Lets Create it!
    OnSpacePressed:OnKeyActionReceive():Connect(function(Action)
        DestroyLinears()
        StatesPerform.SendSignal("JumpFromWallrun")
    end)

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()

        while true  do

                local Delta = game:GetService("RunService").RenderStepped:Wait()

                ACCL = Char.HumanoidRootPart.CFrame.LookVector * ( ( Char.Humanoid.WalkSpeed * 0.05 )  + CharPhysics.SpeedBoost * 0.3  ) * (Delta*60) + Vector3.new( 0,(-game.Workspace.Gravity * 0.001)* (Delta*60),0)
                local MaxACCL = 5
                ACCL = Vector3.new( math.clamp(ACCL.X,-MaxACCL, MaxACCL), math.clamp(ACCL.Y,-MaxACCL, MaxACCL), math.clamp(ACCL.Z,-MaxACCL, MaxACCL) )

                AlignPos.Position = AlignPos.Position +  ACCL

                local HasWall = StateWidget.CheckIfWallIsNear(Char, OriginalDir, RayHandler  )
                local IsOnGround = StateWidget.CanSlide(Char, RayHandler, StatesPerform, BasicCooldowns)

                if not HasWall then
                    DestroyLinears()
                    StatesPerform.SendSignal("JumpFromWallrun")

                    break
                end

                if  IsOnGround then
                    DestroyLinears()
                    StatesPerform.SendSignal("Landed")

                    break
                end

            end

    end)    

end

StatesPerform.WallRun = function(LastState, Char)

    local HasPerform = StateWidget.WallRunChecking(Char, RayHandler, StatesPerform, BasicCooldowns)
    if HasPerform  then
        if LastState :: boolean then
            return true
        end
    else
        if LastState :: boolean then
            return false
        end
        --StatesPerform.SendSignal("Falling", "ForceState")
        --StatesPerform.SendSignal("JumpAirTime", "ForceState")
    end

end
-------

-- Roblox States --
StatesPerform.Jump = function(LastState, Char)

    StatesPerform.CleanGarbage()
    -- Make able to Double.
    StatesPerform.TemporalyInfo.ExecutedDoubleJump = false

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        
        -- Make This Thread inside so we can continue to Check for Climb Action or Vault.
        local VaultOrWall = task.spawn(function()

            while  task.wait() do
                    -- keep checking for vault  and wall 
                StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)
                local ClimbResult = StateWidget.WallClimbCheck(Char, RayHandler, StatesPerform, BasicCooldowns)     
                if ClimbResult == "CanClimb" then
                    StatesPerform.SendSignal("WallClimb", "ForceState")
                end
            end

        end)
        StatesPerform.TemporalyThreads = {}
        table.insert(StatesPerform.TemporalyThreads, VaultOrWall)
        
        -- After some time we go to Jump Air Time. Pretty cool.
        task.wait(.3)
        local StillInAir = StateWidget.IsJumpInAir(Char, RayHandler, StatesPerform, BasicCooldowns)
        if StillInAir then 
            StatesPerform.SendSignal("JumpAirTime")
        else
            StatesPerform.SendSignal("Landed")
        end 
    end)

end

StatesPerform.Falling = function(LastState, Char, HoldingState)


    if LastState == "Running" then 
       -- StatesPerform.StopRunning(LastState, Char) 
    end 


    StatesPerform.CleanGarbage()

   
    -- so others States just stop it.
    StatesPerform.ResetItself = function()
        MovementAnims.FallAnim(false)
    end

    -- Keep Checking for vault while Falling.
    StatesPerform.LastStateGarbage.Thread = task.spawn(function()

        if  StateWidget.IsFarFromGround(Char, RayHandler) and Char.Humanoid.FloorMaterial == Enum.Material.Air then 
            MovementAnims.FallAnim(true)
        else 
            MovementAnims.FallAnim(false)
        end 

        while  task.wait() do
             -- keep checking for vault 
            StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)

            local IsCloseToGround = StateWidget.CanSlide(Char, RayHandler, StatesPerform, BasicCooldowns)
            if IsCloseToGround then 
                StatesPerform.SendSignal("Landed", "ForceState")
                break
            end 
        end     
    end)
   
end

StatesPerform.Landed = function(LastState, Char, HoldingState)

    if HoldingState == "Running" then 
        StatesPerform.SendSignal("Running") 
        return 
    else
        StatesPerform.SendSignal("StopRunning") 
    end 

end

-- do nothing.
StatesPerform.Idle = function()
    StatesPerform.CleanGarbage()
end

StatesPerform.Walk = function(LastState, Char)

    StatesPerform.CleanGarbage()

    StatesPerform.StopRunning(LastState, Char)
end

StatesPerform.StopCrouch = function(LastState, Char)
    StatesPerform.CleanGarbage()
    Char.Humanoid.WalkSpeed = 16

    StatesPerform.SendSignal("Idle")
end

StatesPerform.Crouch = function(LastState, Char, HoldingState )
    StatesPerform.CleanGarbage()

    if HoldingState == "Running" then
        StatesPerform.SendSignal("Slide")
        return
    end


       -- so others States just stop it.
    StatesPerform.ResetItself = function()
        Char.Humanoid.WalkSpeed = 16
        MovementAnims.StopCrouchAction()
    end
    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        local Humanoid =  Char.Humanoid
        while  game:GetService("RunService").RenderStepped:Wait() do

            Humanoid.WalkSpeed = 6
            local IsMoving = Humanoid.MoveDirection.X + Humanoid.MoveDirection.Y + Humanoid.MoveDirection.Z
            if  Humanoid.MoveDirection.Magnitude > 0 then
               MovementAnims.CrouchWalk()
               MovementAnims.UpdateCrouchTrackPos()
            else
                MovementAnims.CrouchIdle()
            end

        end
    end)



end

-- Slide 
StatesPerform.SlideJump = function(LastState, Char )

    StatesPerform.CleanGarbage()

    MovementAnims.SlideJump()
    Char.HumanoidRootPart.AssemblyLinearVelocity = (Char.HumanoidRootPart.CFrame.LookVector * 100) +  Vector3.new(0,50,0)

    StatesPerform.SendSignal("JumpAirTime")
   
    StatesPerform._CallForSpeedBoost()



end

StatesPerform.Slide = function(LastState, Char)
    StatesPerform.CleanGarbage()
    local Accel = 1

    local IsOnGround = StateWidget.CanSlide(Char, RayHandler, StatesPerform, BasicCooldowns)
    if not IsOnGround then
        StatesPerform.SendSignal("Falling", "ForceState")
    end

    -- Render our Effect for all plrs
    EffectsManager.CallForSimpleEffect("Slide", true)

    StateWidget.DisablePlayerControl(Char)

      -- This Action Here ill use so the player can Leave from the Wall if he wants.
      local OnSpacePressed = InputMovesHandler.Create("SlideJump", Enum.KeyCode.Space, {InputMovesHandler.States.Began}, 100, "TemporalyAction")

      local SlideAnim = MovementAnims.SlideAction()

      local InitialLookV =  Char.HumanoidRootPart.CFrame.LookVector
      local ModifiedLookV = Char.HumanoidRootPart.CFrame.LookVector
      
      local InitialUp = Char.HumanoidRootPart.CFrame.UpVector
      local InitialRight = Char.HumanoidRootPart.CFrame.RightVector
      -- Create Align Orientation
      local AlignOrien, Attach3, Attach4 = EasyInstances.CreateAlignOrient(Char)
      AlignOrien.Mode = Enum.OrientationAlignmentMode.OneAttachment
      AlignOrien.MaxTorque = 100000
      AlignOrien.AlignType = Enum.AlignType.AllAxes
      AlignOrien.Responsiveness = 200
      AlignOrien.CFrame  = Char.HumanoidRootPart.CFrame + InitialLookV

      local AlignOrienY, Attach5, Attach6 = EasyInstances.CreateAlignOrient(Char)
      AlignOrienY.Mode = Enum.OrientationAlignmentMode.OneAttachment
      AlignOrienY.MaxTorque = 10000000
      AlignOrienY.AlignType = Enum.AlignType.AllAxes
      AlignOrienY.Responsiveness = 50
      AlignOrienY.CFrame  = Char.HumanoidRootPart.CFrame + InitialLookV

      --YOrientation.CFrame  = Char.HumanoidRootPart.CFrame + InitialLookV



      -- so others States just stop it.
      StatesPerform.ResetItself = function()
          local sucess, err = pcall(function()
              OnSpacePressed:DestroyMove()            
          end)
         Char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

          SlideAnim:AdjustWeight(0,.2)
          SlideAnim:Stop(.4)

          Char.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
          EffectsManager.CallForSimpleEffect("Slide", false)

          StateWidget.EnablePlayerControl(Char)
          AlignOrien:Destroy()
          Attach3:Destroy()
          Attach4:Destroy()

          AlignOrienY:Destroy()
          Attach5:Destroy()
          Attach6:Destroy()

      end
  

  -- Lets Create it!
     OnSpacePressed:OnKeyActionReceive():Connect(function(Action)
         StatesPerform.SendSignal("SlideJump")
         OnSpacePressed:DestroyMove()        
    end)



    StatesPerform.LastStateGarbage.Thread =  task.spawn(function()

        -- Depending on terrain angle this will go up or down.
        local TerrainAdvantage = 1
        -- if the player is going down, more speed, if not,
        -- not so much.

        local DistToGo = 60  + (2.3 *  (CharPhysics.SpeedBoost * TerrainAdvantage) )
        local Accel = 1
      
        local StartLook = InitialLookV
        while  true do
            
            local Delta = game:GetService("RunService").RenderStepped:Wait()

            InitialLookV = Char.HumanoidRootPart.CFrame.LookVector * TerrainAdvantage

            AlignOrien.Responsiveness = 50

            Accel = math.clamp(Accel - 0.038 * (Delta * 20) , 0, 1)
            -- Lerp With the Distance
            Char.HumanoidRootPart.AssemblyLinearVelocity = Char.HumanoidRootPart.AssemblyLinearVelocity:Lerp(  ModifiedLookV * DistToGo  , Accel)
            Char.HumanoidRootPart.AssemblyLinearVelocity = Char.HumanoidRootPart.AssemblyLinearVelocity + Char.HumanoidRootPart.CFrame.UpVector * -10 * (3* Accel)
            Char.Humanoid:ChangeState(Enum.HumanoidStateType.StrafingNoPhysics)
            
            local Lastcf = Char.HumanoidRootPart.CFrame
            local Dir = StateWidget.GetDirByMoveDirection(Char, Char.Humanoid.MoveDirection)

            if Dir == "Left" then
                ModifiedLookV = InitialLookV 
                AlignOrien.CFrame  = ( Char.HumanoidRootPart.CFrame + InitialLookV ) * CFrame.Angles(0, math.rad(-45),0 ) 
            elseif Dir == "Right"  then
                ModifiedLookV = InitialLookV 
                AlignOrien.CFrame  = (Char.HumanoidRootPart.CFrame  + InitialLookV  )  * CFrame.Angles(0, math.rad(45),0 )
            else
                ModifiedLookV = InitialLookV    
            end
            

            

            -- stopped acceleration? stop slide!
            if Accel <= 0 then
                Char.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                
                AlignOrien:Destroy()
                AlignOrienY:Destroy()
                Attach3:Destroy()
                Attach4:Destroy()
                Attach5:Destroy()
                Attach6:Destroy()

                StateWidget.EnablePlayerControl(Char)
                StatesPerform.SendSignal("Landed")
                StatesPerform._CallForSpeedBoost()

                SlideAnim:Stop(.4)

                break
            end

            -- If we're not in ground, we jump
            local IsOnGround = StateWidget.SlidingCheck(Char, RayHandler, StatesPerform, BasicCooldowns)
           
            -- print(Rotation)

            if  not IsOnGround then
                Char.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                
                AlignOrien:Destroy()
                AlignOrienY:Destroy()
                Attach3:Destroy()
                Attach4:Destroy()
                Attach5:Destroy()
                Attach6:Destroy()


                StateWidget.EnablePlayerControl(Char)
                StatesPerform.SendSignal("Landed")
                SlideAnim:Stop(.2)
                break
            else

                -- will use normal for changing Y dir    
                local Normal = IsOnGround.Normal * 5
                
                local TerrainAngle =  Char.HumanoidRootPart.CFrame.LookVector:Dot(Normal)
                
                local TestAngle = nil
                local DownVector = Vector3.yAxis

                local rightVector = DownVector:Cross(Normal)
                
                -- See if Player is Looking into the Slope LookVector,
                -- this dir look will always look to the ground so we just need to see if our player
                -- look vector is going in there too.
                local DirLook = CFrame.fromMatrix(Char.HumanoidRootPart.Position+Vector3.yAxis*5,rightVector,Normal)
                TestAngle = DirLook.LookVector.Unit:Dot(Char.HumanoidRootPart.CFrame.LookVector)

                if TestAngle > 0.3 then
                    TerrainAdvantage -= 0.15 * (Delta *20)
                    InitialLookV = DirLook
                    -- for downwards is cool to send where ou DirLook is going,
                    -- since player LookVector can change totally if he change direction.
                elseif  TestAngle <= -0.2 then
                    TerrainAdvantage += 0.015 * (Delta *20)
                end
                -- With that we add values ^ 
                

                local RotateToFlrCF = StateWidget._ConvertNormalIntoRot(Char.HumanoidRootPart.CFrame.UpVector, Normal, Vector3.new(51,0,0) )
                
                --AlignOrienY.CFrame = AlignOrien.CFrame *  RotateToFlrCF * CFrame.Angles(0,0, math.rad(Accel * 10) )
               local newvec = Char.HumanoidRootPart.CFrame.RightVector:Cross(Normal)

               -- AlignOrienY.CFrame = CFrame.new(0,0,0) + (Vector3.new(0,1,0) * Normal)
                
                local NewCF = CFrame.fromMatrix(Char.HumanoidRootPart.Position,  Char.HumanoidRootPart.CFrame.RightVector, Normal, newvec)
                AlignOrienY.CFrame = AlignOrien.CFrame:Lerp(NewCF, .4)
                
                -- StateWidget._TestPart(Char.HumanoidRootPart.CFrame * RotateToFlrCF.Rotation )
                --AlignOrien.Enabled = false
                --task.wait()
                --AlignOrien.Enabled = true
            end

        end

    end)

end

return StatesPerform