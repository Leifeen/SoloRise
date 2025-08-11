
local KatanaHeavy = {}
local EasyInstances = require(game:GetService("ReplicatedStorage").Shared.Utility.EasyInstances)

KatanaHeavy.Hierarchy = {
    MoveName = "Heavy",
    Hierarchy = 3,
}


function KatanaHeavy:Hit(tab) 

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

    task.wait(.5)
    newHitbox:Destroy()
    table.clear(HittedChars)
    HittedChars = {}

end 

function KatanaHeavy:ActionServer() 

    if self:CheckIfInCooldown("Heavy") == true then
        return
    end

    self:AddToCooldown("Heavy")
    -- Send to Client so they can have a time in Cooldown;
    local EF_Remote = game:GetService("ReplicatedStorage").UI_Update:FireClient(self.Player,  "WarnCD",{
           CurrentlyTime = self:GetTimeSetOnCD("Heavy"),
           MaxTime = self:GetSkillMaxTime("Heavy"),
           SkillName = "Heavy",
    })


    local StarterMovesTB = self.StarterMoves
    local HasHighestHierarchy = StarterMovesTB:CheckIfHasHighestHierarchy(self.Hierarchy)
    if HasHighestHierarchy then
    else
        return
    end

    -- add the skill to Cooldown since the player used it.
    self:AddToCooldown("Heavy")

    local WeaponCommunication = self.Character.WeaponCommunication
    WeaponCommunication:FireClient(self.Player, "Heavy", {
        Event = "PlayTrack"    
    } )

    task.wait(self.ServerHitboxTiming["Heavy"])

    local Configs = {
            Damage = self.Damages["Heavy"][1],
            StunTime = self.AttackStunTime["Heavy"];
            BoxSize = self.HitboxSize["Heavy"];
            OffsetCF = self.HitboxPosition["Heavy"];

            KnockbackConfigs = self.KnockbackConfigs["Heavy"];
    }

    self:Hit(Configs)
    -- Send info to reset the Move since we ended it.
    WeaponCommunication:FireClient(self.Player, "Heavy", {
        Event = "End"    
    } )
    self.StarterMoves:ResetMoveHierarchy(self.Hierarchy)

end 



-- Server
function KatanaHeavy:Server()
   
    local HitboxModule = require(game.ReplicatedStorage.ExternalPackages.HitboxClass )
    local HitboxTypes = require(game.ReplicatedStorage.ExternalPackages.HitboxClass.Types)

    local AttributeHandler = require(game.ServerScriptService.Server.Modules.AttributeHandler)

    self.HitboxModule = HitboxModule
    self.HitboxTypes = HitboxTypes
    self.AttributeHandler = AttributeHandler

    local HeavyServerRM = nil
    self:AddToJanitor(function()
        
        local sucess, err = pcall(function()
            HeavyServerRM:Disconnect()
        end)

    end)

    local WeaponCommunication = self.Character.WeaponCommunication
    HeavyServerRM = WeaponCommunication.OnServerEvent:Connect(function(Plr, Event, tab)
        if Plr == self.Player then
            if Event == "Heavy" then
                self:ActionServer()
            end
        end
    end)

end 

function KatanaHeavy:ActionClient()

    local StarterMovesTB = self.StarterMoves
    local HasHighestHierarchy = StarterMovesTB:CheckIfHasHighestHierarchy(self.Hierarchy)
    if HasHighestHierarchy then
    else
        return
    end

    local WeaponCommunication = self.Character.WeaponCommunication
    WeaponCommunication:FireServer("Heavy", {})

    
end 



-- Client 
function KatanaHeavy:Client()
    
    local WeaponCommunication = self.Character.WeaponCommunication
   
    local HeavyEvent = game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == Enum.KeyCode.R then
            self:ActionClient()
        end
    end)


    local WeaponCL = nil
    self:AddToJanitor(function()
        local sucess, err = pcall(function()
            HeavyEvent:Disconnect()
        end)

        local sucess, err = pcall(function()
            WeaponCL:Disconnect()
        end)
        
    end)

    WeaponCL = WeaponCommunication.OnClientEvent:Connect(function(Event, tab)
        if Event == "Heavy" then
            if tab.Event == "PlayTrack" then

            -- Stop all tracks 
            for _, Tracks in pairs(self.Character.Humanoid.Animator:GetPlayingAnimationTracks() ) do 
                if not Tracks.Looped then
                    Tracks:Stop()
                end
            end 

            self.LoadedTracks.Heavy:Play()

            local LinearVel, Attach1, Attach2 = EasyInstances.CreateLinearIntoChar(self.Character)
            LinearVel.ForceLimitMode = Enum.ForceLimitMode.PerAxis
            LinearVel.ForceLimitsEnabled = true
            LinearVel.MaxAxesForce = Vector3.new(math.huge,0,math.huge )
            
            LinearVel.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            
            -- do the sprint and also stop the force momentum after some time
            local CurrentVel = 50
            game:GetService("RunService"):BindToRenderStep("HeavySprint", 1, function(delta)
                CurrentVel -= 3 * (delta*20)
                LinearVel.VectorVelocity = Vector3.new(0,0,-CurrentVel)
                if CurrentVel <= 0 then
                    LinearVel:Destroy()
                    Attach1:Destroy()
                    Attach2:Destroy()
                    game:GetService("RunService"):UnbindFromRenderStep("HeavySprint")
                end
            end)
                
            elseif tab.Event == "End"  then
                self.StarterMoves:ResetMoveHierarchy(self.Hierarchy)
            end
        end
    end)

end 

return KatanaHeavy