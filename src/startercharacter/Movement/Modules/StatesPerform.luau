StatesPerform = {}
StatesPerform.LastStateGarbage = {}
StatesPerform.Cooldowns = {}

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

-- Vault 
StatesPerform.Vault = function(LastState, Char)

    StatesPerform.CleanGarbage()
    Char.Humanoid.AutoRotate = false

    -- Will play the animation
    MovementAnims.VaultAction()

    local PosToGo = StatesPerform.TemporalyInfo.LastRayPosForVault

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

    StatesPerform.Cooldowns["Vault"] = os.clock()

    CharPhysics.SpeedBoost += 5
    StatesPerform.SendSignal("Landed")
   
    Char.Humanoid.AutoRotate = true

end

StatesPerform.WallClimbJump = function(LastState, Char)
    StatesPerform.CleanGarbage()

    Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,50,0) + (Char.HumanoidRootPart.CFrame.LookVector * -50)
    MovementAnims.WallJump()
    StatesPerform.SendSignal("JumpAirTime")

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
                        ClimbAnimTrack:Stop()
                        StatesPerform.SendSignal("WallClimbJump")
                        break
                    end

                    if ClimbResult == "NoWall" then
                        ClimbAnimTrack:Stop()
                        StatesPerform.SendSignal("JumpAirTime")
                        break
                    end
                end
    
            end)
            StatesPerform.TemporalyThreads = {}
            table.insert(StatesPerform.TemporalyThreads, VaultOrWall)

            ClimbAnimTrack.Stopped:Wait()
            StatesPerform.SendSignal("JumpAirTime")

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
    AlignPos.Position = PosToGo
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

        AlignPos.Position = PosToGo + Vector3.new(0,3,0) + Char.HumanoidRootPart.CFrame.LookVector * 1.5
        
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


end

StatesPerform.Running = function(LastState, Char)
    
    StatesPerform.CleanGarbage()
    
    -- so others States just stop it.
    StatesPerform.ResetItself = function()
        Char.Humanoid.WalkSpeed = 16
        MovementAnims.StopRunAction()
    end

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()

      StatesPerform.LastStateGarbage.Connections = {}
      StatesPerform.LastStateGarbage.Debounce = false

       while  task.wait() do 
            
            MovementAnims.RunAction()

            StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)

            Char.Humanoid.WalkSpeed = 24 + ( CharPhysics.SpeedBoost * 2 ) 
         
        end

        
    end)

end

StatesPerform.JumpAirTime = function(LastState, Char)

    StatesPerform.CleanGarbage()
    local StillInAir = StateWidget.IsJumpInAir(Char, RayHandler, StatesPerform, BasicCooldowns)
    if StillInAir then 
        StatesPerform.SendSignal("JumpAirTime")
    end 

    if StillInAir then 
        StatesPerform.SendSignal("Falling")
    else
         StatesPerform.SendSignal("Landed")
    end



end

StatesPerform.DoubleJump = function(LastState, Char)

    StatesPerform.CleanGarbage()

    Char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,50,0)

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        task.wait(.3)
        local StillInAir = StateWidget.IsJumpInAir(Char, RayHandler, StatesPerform, BasicCooldowns)
        if StillInAir then 
            StatesPerform.SendSignal("JumpAirTime")
        else 
            StatesPerform.SendSignal("Landed")
        end 
    end)
    
end


-- Roblox States --
StatesPerform.Jump = function(LastState, Char)

    StatesPerform.CleanGarbage()
  

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        
        -- Make This Thread inside so we can continue to Check for Climb Action or Vault.
        local VaultOrWall = task.spawn(function()

            while  task.wait() do
                    -- keep checking for vault  and wall 
                StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)
                local ClimbResult = StateWidget.WallClimbCheck(Char, RayHandler, StatesPerform, BasicCooldowns)     
                if ClimbResult == "CanClimb" then
                    StatesPerform.SendSignal("WallClimb")
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
        StatesPerform.StopRunning(LastState, Char) 
    end 

    StatesPerform.CleanGarbage()

    -- Keep Checking for vault while Falling.
    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        while  task.wait() do
             -- keep checking for vault 
            StateWidget.VaultChecking(Char, RayHandler, StatesPerform, BasicCooldowns)

            local IsCloseToGround = StateWidget.IsCloseToGround(Char, RayHandler, StatesPerform, BasicCooldowns)
            if IsCloseToGround then 
                StatesPerform.SendSignal("Landed")
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

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()
        local Humanoid =  Char.Humanoid
        while  game:GetService("RunService").RenderStepped:Wait() do

            Humanoid.WalkSpeed = 6
            local IsMoving = Humanoid.MoveDirection.X + Humanoid.MoveDirection.Y + Humanoid.MoveDirection.Z
            if IsMoving > 0 then
               
            else
                
            end

        end
    end)



end

StatesPerform.Slide = function(LastState, Char)
    StatesPerform.CleanGarbage()
    local Accel = 1

    StateWidget.DisablePlayerControl(Char)

    StatesPerform.LastStateGarbage.Thread =  task.spawn(function()
        local DistToGo = 50 + (1.3 *  CharPhysics.SpeedBoost)
        local Accel = 1
        while  task.wait() do
            
            Accel = math.clamp(Accel - 0.008, 0, 1)
            print(Accel)
            -- Lerp With the Distance
            Char.HumanoidRootPart.AssemblyLinearVelocity = Char.HumanoidRootPart.AssemblyLinearVelocity:Lerp(Char.HumanoidRootPart.CFrame.LookVector * DistToGo, Accel)

            if Accel <= 0 then
                StateWidget.EnablePlayerControl(Char)
                StatesPerform.SendSignal("Landed")
                break
            end
        end

    end)

end

return StatesPerform