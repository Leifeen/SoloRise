StatesPerform = {}
StatesPerform.LastStateGarbage = {}
StatesPerform.Cooldowns = {}

-- some states will send info for each other, 
-- like last raycast Pos and stuff like that. 
StatesPerform.TemporalyInfo = {}

StatesPerform.AnimTracks = {}

local MovementCheck = require( script.Parent.MovementCheck )
local CharPhysics = require( script.Parent.CharPhysics )
local RayHandler = require( game:GetService("ReplicatedStorage").Shared.Utility.RaycastHandler )
local FastAnimTrack = require(game:GetService("ReplicatedStorage").Shared.Utility.FastAnimTrack )
local EasyInstances = require(game:GetService("ReplicatedStorage").Shared.Utility.EasyInstances)

local MovementAnims = require( game.Players.LocalPlayer.Character.CharacterScripts.Animation.MovementsAnimationHandler )
local BasicCooldowns = require(game:GetService("ReplicatedStorage").Shared.gameplay.Cooldowns.BasicCooldowns)  

StatesPerform.SendSignal = function(NewState)
    local ReactBD = nil
    if not script:FindFirstChild("ReactionAction") then 
        local NewBindable = Instance.new("BindableEvent")
        NewBindable.Name = "ReactionAction"
        NewBindable.Parent = script
        ReactBD = NewBindable
    else
        ReactBD = script.ReactionAction
    end 

    ReactBD:Fire(NewState)

    return ReactBD
end

-- Clean Threads and other Stuff. --
StatesPerform.CleanGarbage = function()
    local sucess , err = pcall(function()
        task.cancel(StatesPerform.LastStateGarbage.Thread)
    end)
end
------------

-- Vault 
StatesPerform.Vault = function(LastState, Char)

    StatesPerform.CleanGarbage()

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
    StatesPerform.SendSignal("Running")
    

end


StatesPerform.StopRunning = function(LastState, Char)

    StatesPerform.CleanGarbage()
    Char.Humanoid.WalkSpeed = 16
    MovementAnims.StopRunAction()

end

StatesPerform.Running = function(LastState, Char)
    
    StatesPerform.CleanGarbage()
    

    StatesPerform.LastStateGarbage.Thread = task.spawn(function()

      StatesPerform.LastStateGarbage.Connections = {}
      StatesPerform.LastStateGarbage.Debounce = false

       while  task.wait() do 
            
            MovementAnims.RunAction()

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

            Char.Humanoid.WalkSpeed = 24 + ( CharPhysics.SpeedBoost * 2 ) 
            print(Char.Humanoid.WalkSpeed)
        end

        
    end)

end



return StatesPerform