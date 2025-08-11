
DamageController = {}
local KnockbackService = require ( game:GetService("ReplicatedStorage").Shared.Utility.KnockbackService )
local AttributeHandler = require(game:GetService("ServerScriptService").Server.Modules.AttributeHandler)

DamageController.CancelTarget = function(target)

     local WeaponCommunication = target:FindFirstChild("WeaponCommunication")
    
    -- for test purpose. This will need to be a global function inside weapon class,
    -- so cancel everything needed.
     if WeaponCommunication then
        local Plr = game.Players:GetPlayerFromCharacter(target)
        if Plr then
            WeaponCommunication:FireClient(Plr, "CancelBlock")          
            target:SetAttribute("Blocking", nil)  
        end
    end


end



DamageController.HasClashed = function(Arguments: {} )
   
    if Arguments.Target:GetAttribute("InClash") then
        return 
    end

    if Arguments.Target:GetAttribute("ClashWindow") and Arguments.Killer:GetAttribute("ClashWindow") then
        
        Arguments.Target:SetAttribute("InClash", true)
        Arguments.Killer:SetAttribute("InClash", true)

        local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "Clash",{
            Target = Arguments.Target,
            Killer = Arguments.Killer,
            Event = "ClashLoop",
        })

        KnockbackService.Clash(Arguments.Killer, Arguments.Target)


        return true
    end
end

DamageController.HasDodged = function(Arguments: {} )
    if Arguments.Target:GetAttribute("DodgeWindow") then
            local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "DodgeEffect",{
                Target = Arguments.Target,
        })

        return true
    end
end

DamageController.HasParried = function(Arguments: {} )
    if Arguments.Target:GetAttribute("Parried") then

    local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "ParryHit",{
        Target = Arguments.Killer,
        NewKiller = Arguments.Target,
        DamageType = Arguments.DamageType,
        KillerDir = Arguments.Killer.HumanoidRootPart.Position,
        Weapon = Arguments.WeapoonModel
    })

        AttributeHandler.AddAttribute(Arguments.Killer, "Stunned", true, 1.5 )

        Arguments.Target:SetAttribute("CanParry", true)

        return  true
    end
end

DamageController.HasBlocked = function(Arguments: {})
    if Arguments.Target:GetAttribute("Blocking") then

        if Arguments.Target:GetAttribute("Posture") then
            Arguments.Target:SetAttribute("Posture", Arguments.Target:GetAttribute("Posture") + 10 )

            if Arguments.Target:GetAttribute("Posture") > Arguments.Target:GetAttribute("MaxPosture") then
                Arguments.Target:SetAttribute("Posture", 0)

                
                local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "GuardBroke",{
                    Target = Arguments.Target,
                    KillerDir = Arguments.Killer.HumanoidRootPart.Position
                    
                })

                return false
            end

        end

        local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "BlockHit",{
            Target = Arguments.Target,
            DamageType = Arguments.DamageType,
            KillerDir = Arguments.Killer.HumanoidRootPart.Position
        })

        return  true
    end
end


DamageController.Damage = function(Arguments: {} )
    
    -- if we didn't list it, we know its prob the default one.
    if not Arguments.StatusBlacklisted then
        Arguments.StatusBlacklisted = {"Stunned", "Parried", "Blocking"}
    end

    -- Cancel needed moves from weapon

    -- check if plr has this atb.
    for _, Status in pairs (Arguments.StatusBlacklisted) do 
        if AttributeHandler.HasATB(Arguments.Killer, Status) then
            return
        end
    end 


    local Killer = Arguments.Killer 
    local Target = Arguments.Target 

    -- We're In Combat!
    AttributeHandler.AddAttribute(Killer, "InCombat", true, 5 )
    AttributeHandler.AddAttribute(Target, "InCombat", true, 5 )



    local Damage = Arguments.Damage
    
    if DamageController.HasClashed(Arguments) then
        return
    end
    -- Parried / Blocked / Dodged
    if DamageController.HasParried(Arguments) then
        return 
    end

    if DamageController.HasDodged(Arguments) then
        return
    end

    if DamageController.HasBlocked(Arguments) then
        return 
    end

    for _, Armor in pairs(Target:GetDescendants()) do 
        if Armor:GetAttribute("ArmorHealth") then
            local ChangedHealth = Armor:GetAttribute("ArmorHealth") - Damage
            Damage = Damage - Armor:GetAttribute("ArmorHealth") 

            Armor:SetAttribute("ArmorHealth", ChangedHealth)

            if Damage > 0 then
                
            else
                return
            end

        end
    end 


    Target.Humanoid:TakeDamage(Damage)
    local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "Hit",{
        Target = Target,
        Killer = Killer,
        DamageType = Arguments.DamageType,
        KillerDir = Killer.HumanoidRootPart.Position
    })

    -- we have stun. Lets go!
    if Arguments.StunTime then 
        AttributeHandler.AddAttribute(Target, "Stunned", true, Arguments.StunTime )
    end 

    DamageController.CancelTarget(Target)
    
    -- Apply knockback after the HIT
    local NewKnockback = KnockbackService.newKnockback(Arguments.Knockback)
    NewKnockback:ApplyKnockback()

end

DamageController.Init = function()
    local DamageEvent = Instance.new("BindableEvent")
    DamageEvent.Parent = game.ServerScriptService
    DamageEvent.Name = "DamageRequest"
    
    DamageEvent.Event:Connect(function(tab)
        DamageController.Damage(tab)
    end)

end

return DamageController