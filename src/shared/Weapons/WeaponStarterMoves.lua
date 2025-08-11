
local MainMoves = {}
local CameraShaker = require(game:GetService("ReplicatedStorage").ExternalPackages.CameraShaker )

local SharedAtbHandler = require(game:GetService("ReplicatedStorage").Shared.ClientControllers.SharedAttributeHandler )
local EasyInstances = require(game:GetService("ReplicatedStorage").Shared.Utility.EasyInstances)



local RayHandler = require( game:GetService("ReplicatedStorage").Shared.Utility.RaycastHandler )

MainMoves.CurrentCombo = 0
MainMoves.MaxCombo = 4
MainMoves.IsFeintEnabled = false

MainMoves.Connections = {}
MainMoves.Threads = {}

local GoodSignal = require(game:GetService("ReplicatedStorage").Shared.Utility.GoodSignal )

MainMoves.Hierarchys = {
    ["M1"] = {
        MoveName = "M1",
        Hierarchy = 3,
    },

    ["Block"] = {
        MoveName = "Block",
        Hierarchy = 3,
    },
    ["AirAttack"] = {
        MoveName = "AirAttack",
        Hierarchy = 3,
    }
}
               

function  MainMoves:IsClientPerformingMove (MovementState: string)
     local Result = self.Character.GetInfo_LOCAL:InvokeServer({
            Event = "GetCurrentState",
            StateMentioned = MovementState,
        })
    return Result
end

-- Shared Stuff. Both Server/ Client will use--
-- Can't do nothing depending on player Status effect. (Stun, EndLag, etc.)
function MainMoves:CheckIfCanPerform(Attack)
    local Character = self.Character

    local HasPerm = true
    for _, child in pairs(self.StatusBlacklisted[Attack] ) do 
        if Character:GetAttribute(child) then
            HasPerm = false
            break
        end
    end 

    if game:GetService("RunService"):IsServer() then 
        local Result = self.Character.GetCharInfo:Invoke({
            Event = "IsStateInList",
            ListMentioned = "ParkourStates",
        })
        if Result  then
            HasPerm = false
        end
    else 
        
        local Result = self.Character.GetInfo_LOCAL:InvokeServer({
            Event = "IsStateInList",
            ListMentioned = "ParkourStates",
        })
        if Result  then
            HasPerm = false
        end
    end 
    
    return HasPerm

end 

-- CLIENT -- 
 function MainMoves:FollowCameraTorso (AnimTrack)

            if not self._camShakeEffect then 

                    local camera = game.Workspace.CurrentCamera
                    local function ShakeCamera(shakeCf)
                        -- shakeCf: CFrame value that represents the offset to apply for shake effect.
                        -- Apply the effect:
                        camera.CFrame = camera.CFrame * shakeCf
                    end

                                                -- Create CameraShaker instance:
                    local renderPriority = Enum.RenderPriority.Camera.Value + 2
                    self._camShakeEffect = CameraShaker.new(renderPriority, ShakeCamera)
                    self._camShakeEffect:Start()
            end 

                local sucess, err = pcall(function()
                    task.cancel( self.Connections.RenderThread)
                end)
                 -- Disable the rendering.
                local sucess, err = pcall(function()
                    game:GetService("RunService"):UnbindFromRenderStep("RenderToTorso")     
                end)
         
                 self.Connections.TrackReached =  AnimTrack:GetMarkerReachedSignal("Start"):Connect(function(paramString)
                    --self._camShakeEffect:ShakeOnce(1,.1,.1,.1,0,.5 )
                    --self._camShakeEffect:Shake(CameraShaker.Presets.Slash)
                end)

                self.Connections.RenderThread =  task.spawn(function()
                local Char = self.Character
            
                game:GetService("RunService"):BindToRenderStep("RenderToTorso", Enum.RenderPriority.Camera.Value - 5, function()
                    local offset = Char:FindFirstChild("Torso").CFrame:ToObjectSpace(Char.HumanoidRootPart.CFrame).Position
                
                    local camOffset = Vector3.new(-offset.X*0.1 , -offset.Y*0.1 , offset.Z*0.1 )
                    camOffset = camOffset*2

                    local Anim =  game:GetService("TweenService"):Create(Char.Humanoid, TweenInfo.new(.055, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CameraOffset = camOffset * 3 })
                    Anim:Play()
                end)
                
                -------------------------------------
                --------- SHAKE CAMERA --------------
                -------------------------------------


                AnimTrack.Stopped:Wait()
                game:GetService("RunService"):UnbindFromRenderStep("RenderToTorso")
                local Anim =  game:GetService("TweenService"):Create(Char.Humanoid, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CameraOffset =  Vector3.zero })
                Anim:Play()

        end)
end





MainMoves.ClientMoves = {

    AirAttack = function(tab, Extra)
        
        local CandoAttack = tab:CheckIfCanPerform("AirAttack")
        if CandoAttack then 
        else 
           tab:ResetMoveHierarchy(tab.Hierarchys["AirAttack"])
           return 
        end 

        if tab:CheckIfHasHighestHierarchy(tab.Hierarchys["AirAttack"])  then 
        else
           tab:ResetMoveHierarchy(tab.Hierarchys["AirAttack"])
            return
        end 


        local WeaponCommunication = tab.Character.WeaponCommunication
        WeaponCommunication:FireServer("AirAttack")
        tab:ResetMoveHierarchy(tab.Hierarchys["AirAttack"])

    end,

    -- Block -- 
    Block = function(tab, Extra)
       
        if tab:CheckIfHasHighestHierarchy(tab.Hierarchys["Block"])  then 
        else
            return
        end

        -- anim tracks that i already loaded
        local BlockAnim =  tab.LoadedTracks.Blocking
        BlockAnim.Looped = true 

        
        if tab.Blocking then 
           local WeaponCommunication = tab.Character.WeaponCommunication
            WeaponCommunication:FireServer("Block", {
                Enable = true,
                StillBlocking = Extra.IsStillBlocking
            } )

            BlockAnim:Play()
            BlockAnim.Priority = Enum.AnimationPriority.Action3
        else
            local WeaponCommunication = tab.Character.WeaponCommunication
            WeaponCommunication:FireServer("Block", {
                Enable = false,
            } )

            BlockAnim:Stop(.2)
            tab:ResetMoveHierarchy(tab.Hierarchys["Block"])

        end 


    end,

    SprintStrike = function(tab)
            
        local CandoAttack = tab:CheckIfCanPerform("Sprint Strike")
        if CandoAttack then 
        else 
            return 
        end 

        local CurrentMovState = SharedAtbHandler.GetCharLocalAttribute()
        if CurrentMovState == "Running" then
            -- Check on server too 
            local IsPerforming = tab:IsClientPerformingMove("Running")
            if IsPerforming then
                local WeaponCommunication = tab.Character.WeaponCommunication
                WeaponCommunication:FireServer("SprintStrike")
                return true
            end

        end



        return false 


    end,


    Feint = function(tab, Extra)
        
        local WeaponCommunication = tab.Character.WeaponCommunication
        if Extra.Enable then
            -- Player need to HOLD for feint and go for it. 
            WeaponCommunication:FireServer("Feint", {
                Enable = true,
            })
        else
           
            
            WeaponCommunication:FireServer("Feint", {
                Enable = false,
            })
        end
    end,

    -- M1 --
    M1 = function(tab, Combo, Event )
        
        if Event == "PlayTrack" then

        
                -- anim tracks that i already loaded
            local M1Anim =  tab.LoadedTracks

            if tab.LastM1Track then 
                tab.LastM1Track:Stop()

                   -- stop any anim track that inst m1's.
                for _, child in pairs(tab.Character.Humanoid:GetPlayingAnimationTracks()) do 
                    if not child.Looped then 
                        child:Stop()
                     end 
                end 

            end 

            local DeterminedSpeed = tab.AnimTracksSpeed["M1"][Combo]
            M1Anim["Attack" .. tostring(Combo) ]:AdjustSpeed(DeterminedSpeed)


            M1Anim["Attack" .. tostring(Combo) ]:Play()
            M1Anim["Attack" .. tostring(Combo) ]:AdjustWeight(1.5)


            M1Anim["Attack" .. tostring(Combo) ].Priority = Enum.AnimationPriority.Action3

            -- Camera Animation.
            tab:FollowCameraTorso(M1Anim["Attack" .. tostring(Combo) ])

            -- ill change weight of that later
            tab.LastM1Track =  M1Anim["Attack" .. tostring(Combo) ]

            task.delay(.3, function()
                if  M1Anim["Attack" .. tostring(tab.CurrentCombo) ].IsPlaying then
                    M1Anim["Attack" .. tostring(tab.CurrentCombo) ]:AdjustWeight(1)                
                end
            end)

        end


            -- lez go air attack
        if tab.Character.Humanoid.FloorMaterial == Enum.Material.Air then
             local IsOnGround = RayHandler.FastRaycast(tab.Character.HumanoidRootPart.Position, Vector3.new(0,-2,0) )
            if not IsOnGround then
                MainMoves.ClientMoves.AirAttack(tab)
                tab:ResetMoveHierarchy(tab.Hierarchys["M1"])
                return
            end
        end

        if tab:CheckIfHasHighestHierarchy(tab.Hierarchys["M1"])  then 
        else
            return
        end 

        local CandoAttack = tab:CheckIfCanPerform("M1")
        if CandoAttack then 
        else 
            tab:ResetMoveHierarchy(tab.Hierarchys["M1"])
            return 
        end 

        -- Do Sprint Strike (IF we already can do that.)
        local HasSprinted = MainMoves.ClientMoves.SprintStrike(tab)
        if HasSprinted then
            tab:ResetMoveHierarchy(tab.Hierarchys["M1"])
            return   
        end

        local WeaponCommunication = tab.Character.WeaponCommunication
        WeaponCommunication:FireServer("M1")
        
        tab:ResetMoveHierarchy(tab.Hierarchys["M1"])

    end
}


function MainMoves:Hit(tab) 
    
    local HitboxModule = self.HitboxModule 
    local HitboxTypes = self.HitboxTypes 

    local Char = self.Character

    local OffsetCF = tab.OffsetCF


    local hitboxParams = {
        SizeOrPart = tab.BoxSize,
        DebounceTime = 0.1,
        Debug = false,
        Blacklist = {Char},
    } :: HitboxTypes.HitboxParams

    local newHitbox, connected = HitboxModule.new(hitboxParams)

    local HittedChars = {}

    local WeaponKnockbackConfigs = tab.KnockbackConfigs

    newHitbox.HitSomeone:Connect(function(hitchars)
        for _, Target in pairs(hitchars) do 
            if table.find(HittedChars, Target) then return end 

            table.insert(HittedChars, Target)

            self:SendDamageRequest({
                Damage = tab.Damage,
                Target = Target,
                Killer = self.Character,
                KillerPlayer = self.Player,
                DamageType = self.DamageType,
                StunTime = tab.StunTime;

                Knockback = {
                     DistanceKiller = WeaponKnockbackConfigs.DistanceKiller;
                     DistanceTarget = WeaponKnockbackConfigs.DistanceTarget;

                     Target = Target;
                     Killer = self.Character;
                     GoTo = self.Character.HumanoidRootPart.CFrame.LookVector;

                     TargetAnimTrack = WeaponKnockbackConfigs.TargetAnimTrack;

                     KnockbackType = WeaponKnockbackConfigs.KnockbackType;
                     SlamOnSurface = WeaponKnockbackConfigs.SlamOnSurface;
                }

            })      
          
        end 
    end)

    newHitbox:Start()

    newHitbox:WeldTo(
        Char.HumanoidRootPart,
        OffsetCF
    )

    task.spawn(function()
        task.wait(.5)
        newHitbox:Destroy()
        table.clear(HittedChars)
        HittedChars = {}
    end)
end 



MainMoves.ServerMoves = {

    AirAttack = function(tab, Extra)

        if tab.Character:GetAttribute("Blocking") == true then
            return
        end


        local CandoAttack = tab:CheckIfCanPerform("AirAttack")
        if CandoAttack then else return end 

          -- Cooldown Stuff
        if tab:CheckIfInCooldown("AirAttack") == true then
            tab:ResetMoveHierarchy(tab.Hierarchys["AirAttack"])
            return
        end

        tab:AddToCooldown("AirAttack")
        -- Send to Client so they can have a time in Cooldown;
        local EF_Remote = game:GetService("ReplicatedStorage").UI_Update:FireClient(tab.Player,  "WarnCD",{
            CurrentlyTime = tab:GetTimeSetOnCD("AirAttack"),
            MaxTime = tab:GetSkillMaxTime("AirAttack"),
            SkillName = "Air Attack",
        })

        local WeaponCommunication = tab.Character.WeaponCommunication
        WeaponCommunication:FireClient(tab.Player, "AirAttack")
        
        -- Change for air attack later.
        local EndLagTiming = tab.EndLags["Sprint Strike"]
         local Configs = {
            OffsetCF = tab.HitboxPosition["Sprint Strike"],
            BoxSize = tab.HitboxSize["Sprint Strike"],
            KnockbackConfigs = tab.KnockbackConfigs["Sprint Strike"],
            Damage = tab.Damages["Sprint Strike"],
            StunTime = tab.AttackStunTime["Sprint Strike"],
        }


        task.wait(tab.ServerHitboxTiming["AirAttack"])

        tab:Hit(Configs)
        tab:ResetMoveHierarchy(tab.Hierarchys["AirAttack"])

    end,

    SprintStrike = function(tab, Extra)

    
        local CandoAttack = tab:CheckIfCanPerform("Sprint Strike")
        if CandoAttack then else return end 

        -- Cooldown Stuff
        if tab:CheckIfInCooldown("Sprint Strike") == true then
            return
        end

        -- on blacklist? Then return.
        if tab:IsOnBlacklist({"Sprint Strike"}) then
            return
        end

        tab:AddToCooldown("Sprint Strike")
        -- Send to Client so they can have a time in Cooldown;
        local EF_Remote = game:GetService("ReplicatedStorage").UI_Update:FireClient(tab.Player,  "WarnCD",{
            CurrentlyTime = tab:GetTimeSetOnCD("Sprint Strike"),
            MaxTime = tab:GetSkillMaxTime("Sprint Strike"),
            SkillName = "Sprint Strike",
        })



        local AttributeHandler = tab.AttributeHandler
        AttributeHandler.AddAttribute(tab.Character, "EndLag" )


        local EndLagTiming = tab.EndLags["Sprint Strike"]
         local Configs = {
            OffsetCF = tab.HitboxPosition["Sprint Strike"],
            BoxSize = tab.HitboxSize["Sprint Strike"],
            KnockbackConfigs = tab.KnockbackConfigs["Sprint Strike"],
            Damage = tab.Damages["Sprint Strike"],
            StunTime = tab.AttackStunTime["Sprint Strike"],
        }

        -- Do the Movement
        local WeaponCommunication = tab.Character.WeaponCommunication
        WeaponCommunication:FireClient(tab.Player, "SprintStrike")

        -- Sprint Strike Effect
        local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "SprintStrike",{
            Weapon = tab.ClonedModel
        })
       

         -- Wait until we hit;
        task.wait(tab.ServerHitboxTiming["Sprint Strike"])

       -- Cancel Sprint Strike. No Need.
        WeaponCommunication:FireClient(tab.Player, "SprintStrike_CANCEL")

        local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "SprintStrike",{
            Weapon = tab.ClonedModel,
            Event = "Slash",
            Target = tab.Character
        })
       task.wait(.2)

        AttributeHandler.AddAttribute(tab.Character, "ClashWindow", true, 1)
        AttributeHandler.RemoveATB(tab.Character, "EndLag" )
        --AttributeHandler.AddAttribute(tab.Character, "EndLag", true, EndLagTiming )
        -- removed it bc was a bit too much punishment.
       

        tab:Hit(Configs)

        
    end,

    Block = function(tab, Extra)

        local AttributeHandler = tab.AttributeHandler
        local DidParry = false

        if Extra.Enable == true  and tab.Character:GetAttribute("CanParry") == true then
            
            tab.Character:SetAttribute("Parried", true)
            tab.Character:SetAttribute("CanParry" , false)

            task.spawn(function()
                task.wait(1)
                tab.Character:SetAttribute("CanParry" , true)
            end)

            task.spawn(function()
                task.wait(.3)
                tab.Character:SetAttribute("Parried", false)
            end)

             local WeaponCommunication = tab.Character.WeaponCommunication
             WeaponCommunication:FireClient(tab.Player, "Parry")
            
   
             local EndLagTiming = tab.EndLags["M1"][tab.CurrentCombo]
             AttributeHandler.AddAttribute(tab.Character, "EndLag", true, EndLagTiming )
            

             DidParry = true

        end

        if  Extra.Enable == false or not Extra.StillBlocking then 
           
             if tab.Threads["ParryToBlockDelay"] then 
                local sucess, err = pcall(function()
                    task.cancel(tab.Threads["ParryToBlockDelay"])                    
                end)
            end 
           
            tab.AttributeHandler.RemoveATB(tab.Character, "Blocking", nil )
             
            local WeaponCommunication = tab.Character.WeaponCommunication
            WeaponCommunication:FireClient(tab.Player, "CancelBlock")
            
           

            return
        end 

        -- Blocking -- 
        if DidParry then 
            tab.Threads["ParryToBlockDelay"] =  task.spawn(function()
                task.wait(.3)
                 tab.AttributeHandler.AddAttribute(tab.Character, "Blocking", true )
                 tab.Threads["ParryToBlockDelay"] = nil
            end)
        else
            tab.AttributeHandler.AddAttribute(tab.Character, "Blocking", true )

        end 
        
     

      

    end,

    Feint = function(tab, Extra)
        
        -- Don't want to add Attribute.
        if Extra.CancelledM1 then 

            tab.Character:SetAttribute("InM1", nil)

              local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "FeintEffect",{
                Weapon = tab.ClonedModel
             })

             local WeaponCommunication = tab.Character.WeaponCommunication
            WeaponCommunication:FireClient(tab.Player, "Feint")

            return
        end 

        if Extra.Enable  then 
            tab.IsFeintEnabled = true
        else
            tab.IsFeintEnabled = false
        end 

    end,

    M1 = function(tab)
        
        -- Reset the combo
        if  os.time()  - tab.LastTick > 1 then
            tab.CurrentCombo = 1
        end
        tab.LastTick = os.time()

        local CandoAttack = tab:CheckIfCanPerform("M1")
        if CandoAttack then else return end 
        
        -- no need to use sprint strike or any skill
        tab:AddToBlacklist({"Sprint Strike", "Skills"})

        local sucess, err = pcall(function()
            task.cancel( tab.MovesThreads["ResetBList"]  )
        end)

        -- Play M1 Anim
        local WeaponCommunication = tab.Character.WeaponCommunication
        WeaponCommunication:FireClient(tab.Player, "M1",  {
            Event = "M1_Combo_Track",
            CurrentCombo = tab.CurrentCombo
        } )
        
        -- Trail Effect
        local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "Weapontrail",{
           Weapon = tab.ClonedModel
        })

        local AttributeHandler = tab.AttributeHandler
        AttributeHandler.AddAttribute(tab.Character, "InM1" )


        local WeaponCommunication = tab.Character

        -- Wait until we hit;
        task.wait(tab.ServerHitboxTiming["M1"][tab.CurrentCombo])
        
        -- Feint! -- 
        if tab.IsFeintEnabled  then 
            MainMoves.ServerMoves.Feint(tab, {
                CancelledM1 = true
            })
            return
        end 

        local SlashSFX = game.ReplicatedStorage.Assets.SFX:FindFirstChild(tab.WeaponName)
        local RandomSFX = math.random(1,3)

        SlashSFX = SlashSFX:FindFirstChild("slash" .. tostring(RandomSFX)):Clone()
        SlashSFX.Parent = tab.Character.HumanoidRootPart
        SlashSFX:Play()

        local Configs = {
            OffsetCF = tab.HitboxPosition["M1"][tab.CurrentCombo],
            BoxSize = tab.HitboxSize["M1"][tab.CurrentCombo],
            KnockbackConfigs = tab.KnockbackConfigs["M1"][tab.CurrentCombo],
            Damage = tab.Damages["M1"][tab.CurrentCombo],
            StunTime = tab.AttackStunTime["M1"][tab.CurrentCombo],
        }
        -- hit;
        tab:Hit(Configs)

        
        local EndLagTiming = tab.EndLags["M1"][tab.CurrentCombo]
        AttributeHandler.AddAttribute(tab.Character, "EndLag", true, EndLagTiming )
        AttributeHandler.RemoveATB(tab.Character, "InM1" )


        if tab.CurrentCombo < tab.MaxCombo then 
             tab.CurrentCombo += 1 
        else
             tab.CurrentCombo = 1
        end 
        
        tab.MovesThreads["ResetBList"] =  task.spawn(function()
            task.wait(1)
            tab:ClearBlacklist()
        end)



    end
}

-- Server Side -- 
function  MainMoves:Server ()
    
    -- Add a function so it will render during a specific state
    self:_SpecialFuncsForAttributes( function()

         if self:CheckIfInCooldown("Sprint Strike") == false then
             self:AddToCooldown("Sprint Strike")
            
             game:GetService("ReplicatedStorage").UI_Update:FireClient(self.Player,  "WarnCD",{
                CurrentlyTime = self:GetTimeSetOnCD("Sprint Strike"),
                MaxTime = self:GetSkillMaxTime("Sprint Strike"),
                SkillName = "Sprint Strike",
             })

        end
        
        if self:CheckIfInCooldown("AirAttack") == false then
            self:AddToCooldown("AirAttack")

            game:GetService("ReplicatedStorage").UI_Update:FireClient(self.Player,  "WarnCD",{
                CurrentlyTime = self:GetTimeSetOnCD("AirAttack"),
                MaxTime = self:GetSkillMaxTime("AirAttack"),
                SkillName = "AirAttack",
            })
        end 

    end, "Stunned" )

    -- Variables
    local HitboxModule = require(game.ReplicatedStorage.ExternalPackages.HitboxClass )
    local HitboxTypes = require(game.ReplicatedStorage.ExternalPackages.HitboxClass.Types)

    local AttributeHandler = require(game.ServerScriptService.Server.Modules.AttributeHandler)

    self.CurrentCombo = 1 
    self.MaxCombo = 4
    self.LastTick = os.time()

    -- Set it to the Module itself. --
    self.HitboxModule = HitboxModule
    self.HitboxTypes = HitboxTypes
    self.AttributeHandler = AttributeHandler

    -- set stuff into char
    if not self.Character:GetAttribute("CanParry") then
        self.Character:SetAttribute("CanParry", true)    
    end
    

    -- if Player die, unequip weapon, or anything, this will execute.
    local OnServerEvent = nil
    self:AddToJanitor(function()
        local sucess, err = pcall(function()
            task.cancel(self.Threads["ParryToBlockDelay"])                    
        end)
        local sucess, err = pcall(function()
            OnServerEvent:Disconnect()
        end)

        self.Character:SetAttribute("InM1", nil)
        self.Character:SetAttribute("CanParry", nil)
    end)


    OnServerEvent = self.Character.WeaponCommunication.OnServerEvent:Connect(function(Player, Event, tab)
        if Player == self.Player and self.ServerMoves[Event] then
            self.ServerMoves[Event](self, tab)
        end
    end)
    table.insert( self.MovesConnections, OnServerEvent)



end

-- Client Side -- 
function MainMoves:Client ()
    

    -- Variables
    local InputMovesHandler = require(game:GetService("ReplicatedStorage").Shared.gameplay.InputMovesHandler)

    local OnM1Press = InputMovesHandler.Create("M1", Enum.UserInputType.MouseButton1,{"OnClickBegan"}, 100, "Combat"  )
    local OnM2Press =  InputMovesHandler.Create("M2", Enum.UserInputType.MouseButton2,{"OnClickBegan", "OnClickEnded"}, 100, "Combat"  )
    local OnBlockPress = InputMovesHandler.Create("Block", Enum.KeyCode.F,{"Began", "Ended"}, 100, "Combat"  )

 -- if Player die, unequip weapon, or anything, this will execute.
    local ClientEventReceiver = nil -- For the remote later on.

    local Garbages = {} -- linear vel  and stuff

    self:AddToJanitor(function()


        local sucess, err = pcall(function()
                for _, AnimTracks in pairs(self.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do 
                local Blacklisted = {"Attack1", "Attack2", "Attack3", "Attack4", "Animation1"}

                if table.find(AnimTracks.Name, Blacklisted) then 
                    AnimTracks:AdjustWeight(1,0.1)
                    AnimTracks:Stop(.3)
                end
            end     
        end)
        

        -- Disconnect Track function.
        local sucess, err = pcall(function()
             self.Connections.TrackReached:Disconnect()            
        end)

        local sucess, err = pcall(function()
            OnM1Press:DestroyMove()
            OnM2Press:DestroyMove()
            OnBlockPress:DestroyMove()

            for _, child in pairs(self.MovesConnections) do 
                  child:Disconnect()
             end 
        end)

        local sucess, err = pcall(function()
            ClientEventReceiver:Disconnect()
        end)
        
        local sucess, err = pcall(function()
            for _, child in pairs(Garbages) do 
                child:Destroy()
            end 
        end)

        game:GetService("RunService"):UnbindFromRenderStep("AirAttack")
        game:GetService("RunService"):UnbindFromRenderStep("Sprint Strike")
        

    end)

    self.CurrentCombo = 1 
    self.MaxCombo = 4
    self.Blocking = false

 

    -- Client will call for the Moves.
    local OnM1 = OnM1Press:OnKeyActionReceive():Connect(function()

         if self:IsInInventory() then
            return
        end

        self.ClientMoves.M1(self)
    end)

    local OnM2 = OnM2Press:OnKeyActionReceive():Connect(function(Event)

        if self:IsInInventory() then
            return
        end

        if Event == InputMovesHandler.States.OnClickBegan then
             self.ClientMoves.Feint(self, {
                 Enable = true
             } )
        else
            self.ClientMoves.Feint(self, {
                 Enable = false
             } )
        end
    end)

    local Inp_Buffer = function (Key)
        local FramesToCount = 2 
        
         local accumulateddelta = 0
         local OnRenderStep = nil
        local IsFKeyDown = true

        repeat
            local deltatime = game:GetService("RunService").RenderStepped:Wait()
            FramesToCount -= (deltatime * 20)
            
            if game:GetService("UserInputService"):IsKeyDown(Key) then
                IsFKeyDown = true
            else
                IsFKeyDown = false
            end

        until FramesToCount <= 0 or not IsFKeyDown

        return IsFKeyDown


    end


    local OnBlock =  OnBlockPress:OnKeyActionReceive():Connect(function(Action)
        if Action == InputMovesHandler.States.Began then

            local Block_Buffer = Inp_Buffer(Enum.KeyCode.F)

             self.Blocking = true
             self.ClientMoves.Block(self, {
                IsStillBlocking = Block_Buffer
             } )
        else
            self.Blocking = false
             self.ClientMoves.Block(self)
        end
    end)

    
    table.insert(self.MovesConnections, OnM1Press)
    table.insert(self.MovesConnections, OnBlockPress)
    table.insert(self.MovesConnections, OnM2Press)

    local WeaponCommunication = self.Character.WeaponCommunication
    ClientEventReceiver =  WeaponCommunication.OnClientEvent:Connect(function(Event, Extra)
        

        if Extra then
            if Extra.Event == "M1_Combo_Track" then
                self.ClientMoves.M1(self, Extra.CurrentCombo, "PlayTrack")
            end
        end

        -- place holder, will make a unique system for this connection.
        if Event == "Parry" then

            self.LoadedTracks.Parry_Hit:Play()
            self.LoadedTracks.Parry_Hit:AdjustSpeed(1.5)
            self.LoadedTracks.Parry_Hit.Priority = Enum.AnimationPriority.Action4 
            
            self:ResetMoveHierarchy(self.Hierarchys["Block"])

        elseif  Event == "Feint" then
            
            for _, child in pairs(self.LoadedTracks) do 
                if child.IsPlaying then 
                    child:Stop(0.5)                    
                end
            end 

        elseif  Event == "CancelBlock" then
            self.LoadedTracks.Blocking:Stop()
            self.Blocking = false     


        elseif Event == "SprintStrike_CANCEL"  then

            local sucess, err = pcall(function()
                for _, child in pairs(Garbages) do 
                    child:Destroy()
                end 
            end)

            game:GetService("RunService"):UnbindFromRenderStep("SprintSt")

        elseif  Event == "SprintStrike" then

            local M1Anim =  self.LoadedTracks
            M1Anim.RunM1:Play()
            M1Anim.RunM1:AdjustSpeed(self.AnimTracksSpeed["Sprint Strike"] )

            local LinearVel, Attach1, Attach2 = EasyInstances.CreateLinearIntoChar(self.Character)
            LinearVel.ForceLimitMode = Enum.ForceLimitMode.PerAxis
            LinearVel.ForceLimitsEnabled = true
            LinearVel.MaxAxesForce = Vector3.new(math.huge,0,math.huge )
            
            
            LinearVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            
            table.insert(Garbages, LinearVel)
            table.insert(Garbages, Attach1)
            table.insert(Garbages, Attach2)

            -- do the sprint and also stop the force momentum after some time -- 
            local CurrentVel = 50
            game:GetService("RunService"):BindToRenderStep("SprintSt", 1, function(delta)
                CurrentVel -= 3 * (delta*20)
                LinearVel.VectorVelocity = Vector3.new(0,0,-CurrentVel)
                if CurrentVel <= 0 then
                    LinearVel:Destroy()
                    Attach1:Destroy()
                    Attach2:Destroy()
                    game:GetService("RunService"):UnbindFromRenderStep("SprintSt")
                end
            end)

        elseif Event ==  "AirAttack" then
            
            for _, Tracks in pairs(self.Character.Humanoid.Animator:GetPlayingAnimationTracks() ) do 
                if not Tracks.Looped then
                    Tracks:Stop()
                end
            end 

            local AirAttack =  self.LoadedTracks.AirAttack
            AirAttack.Priority = Enum.AnimationPriority.Action4
            AirAttack:Play()

            local LinearVel, Attach1, Attach2 = EasyInstances.CreateLinearIntoChar(self.Character)
            LinearVel.ForceLimitMode = Enum.ForceLimitMode.PerAxis
            LinearVel.ForceLimitsEnabled = true
            LinearVel.MaxAxesForce = Vector3.new(math.huge,0,math.huge )
            
            
            LinearVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            
            -- do the sprint and also stop the force momentum after some time
            local CurrentVel = 50
            game:GetService("RunService"):BindToRenderStep("AirAttack", 1, function(delta)
                CurrentVel -= 3 * (delta*20)
                LinearVel.VectorVelocity = Vector3.new(0,0,-CurrentVel)
                if CurrentVel <= 0 then
                    LinearVel:Destroy()
                    Attach1:Destroy()
                    Attach2:Destroy()
                    game:GetService("RunService"):UnbindFromRenderStep("AirAttack")
                end
            end)

        end

    end)

    


    
end



return MainMoves