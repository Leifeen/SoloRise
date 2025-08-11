
local EnemyController = {}
local WeaponsFolder =  game:GetService("ReplicatedStorage").Shared.Weapons  
local CodeAssist = require(game:GetService("ReplicatedStorage").Shared.Utility.CodeAssist )



function EnemyController:CheckIfCanPerform(Attack)
    local Character = self.Character

    local HasPerm = true
    for _, child in pairs(self.Weapon.StatusBlacklisted[Attack] ) do 
        if Character:GetAttribute(child) then
            HasPerm = false
            break
        end
    end 

    return HasPerm

end 


function EnemyController:Hit (tab)
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
            
            self.LastTarget = Target

            self:SendDamageRequest({
                Damage = tab.Damage,
                Target = Target,
                Killer = self.Character,
                KillerPlayer = self.Player,
                DamageType = self.Weapon.DamageType,
                
                StunTime = tab.StunTime,

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

 function EnemyController:Load() 

    self.LoadedTracks = {}

    if self.EquippedWeapon then 
        local Animator = self.Character.Humanoid.Animator 
        for _, Anim in pairs(self.Weapon.Animtracks:GetChildren()) do 
            if Anim:IsA("Animation") then
                self.LoadedTracks[Anim.Name] =  Animator:LoadAnimation(Anim)         
            end 
        end 

    end 

 end 

function EnemyController:M1()
    
    

    if  self:CheckIfCanPerform("M1") == false then
        return 
    end

    if not self.CurrentCombo then 
        self.CurrentCombo = 1
        self.MaxCombo = 4 
    end 

      self.LoadedTracks["Attack" .. tostring(self.CurrentCombo) ]:Play()

      task.wait(.3)
      local tab = self.Weapon
      self:Hit(
            {  
            OffsetCF = tab.HitboxPosition["M1"][tab.CurrentCombo],
            BoxSize = tab.HitboxSize["M1"][tab.CurrentCombo],
            KnockbackConfigs = tab.KnockbackConfigs["M1"][tab.CurrentCombo],
            Damage = tab.Damages["M1"][tab.CurrentCombo],
            StunTime = tab.AttackStunTime["M1"][tab.CurrentCombo],
        }
      )

      if self.CurrentCombo + 1 <= self.MaxCombo then 
         self.CurrentCombo += 1 
      else
        self.CurrentCombo = 1
        task.wait(.5)
      end 


end 

function EnemyController:UnequipWeapon  ()
    
end

function  EnemyController:EquipWeapon  ()
    


    if not self.IsWeaponEquipped then 
        self.IsWeaponEquipped = true
        
        self.LoadedTracks.Equip:Play()

        -- very place holder since it don't work with other weapons rn    
        local NewModel = self.Weapon.WeaponModel:Clone()
        local Motor6D = NewModel:FindFirstChildWhichIsA("Motor6D")

        Motor6D.Part0 = self.Character:FindFirstChild("Right Arm")

        NewModel.Parent = self.Character
            
        self.ClonedModel = NewModel


    end 

     
end


EnemyController.GetWeapon = function(WeaponName)    

    -- See the folder and return the weapon needed.
    for _, child in pairs(WeaponsFolder:GetDescendants()) do 
        if child:IsA("ModuleScript") then 
            if child.Name == WeaponName then 
                return child
            end 
        end 
    end 


end


EnemyController.New = function(Configs)
    
    local NewEnemy = {
        Health = Configs.Health or 100 ,
        EquippedWeapon = Configs.EquippedWeapon or nil,
        Character = Configs.Character,
        Posture = Configs.Posture or 100, 

        IsWeaponEquipped = false,


        -- Utility 
         HitboxModule = require(game.ReplicatedStorage.ExternalPackages.HitboxClass ),
         HitboxTypes = require(game.ReplicatedStorage.ExternalPackages.HitboxClass.Types),


    }

    setmetatable(NewEnemy, {__index =  EnemyController} )

    function NewEnemy:SendDamageRequest (tab)
        game.ServerScriptService.DamageRequest:Fire(tab)
    end 

    if NewEnemy.EquippedWeapon then 
        NewEnemy.Weapon = EnemyController.GetWeapon(NewEnemy.EquippedWeapon)
        NewEnemy.Weapon = CodeAssist.DeepCopyTable( require(NewEnemy.Weapon) )
        setmetatable(NewEnemy.Weapon, {__index =  NewEnemy } )
    end 


    if NewEnemy.EquippedWeapon then 
        NewEnemy.Character.Humanoid.HealthChanged:Connect(function()
            NewEnemy:EquipWeapon()
        end)
    end 

    -- Load anim tracks and stuff
    NewEnemy:Load()


    return NewEnemy

end



return EnemyController