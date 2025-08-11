
local WeaponClass = {}

local CodeAssist = require(game:GetService("ReplicatedStorage").Shared.Utility.CodeAssist )
local GoodSignal = require(game:GetService("ReplicatedStorage").Shared.Utility.GoodSignal )

local CodeAssist = require(game:GetService("ReplicatedStorage").Shared.Utility.CodeAssist )

local WeaponSetup =  nil

if game:GetService("RunService"):IsServer() then
    WeaponSetup = require( script.Parent.WeaponMotor6DSetup )
end

function  WeaponClass:RunAttributeFunction (FuncName)
    self.AttributesFuncs[FuncName](self)
end
-- this will be functions that happen during attributes 
function  WeaponClass:_SpecialFuncsForAttributes (NewFunc, FunctionName)
    table.insert(self.Janitor, NewFunc)
    self.AttributesFuncs[FunctionName] = NewFunc
end

function WeaponClass:_AddFunctionsIntoMove ()
    

    self.CurrentyMoveHierarchy = {
        MoveName = "None",
        Hierarchy = 0,
    }

    -- ToDO: in future,
    -- when i get to skills i need to acess the "StarterMoves" and call this function
    -- from there. since i want skills to stop you from using M1, Block, ETC.
    -- VERY IMPORTANT. to make this method. Instead of making the moves "cancel" themself.
    -- and ignore the basic ones (M1, Block, ETc.)
     function self:CheckIfHasHighestHierarchy (move)
        if move.MoveName ~= self.CurrentyMoveHierarchy.MoveName then
            if move.Hierarchy <= self.CurrentyMoveHierarchy.Hierarchy then
                return false
            else
                self.CurrentyMoveHierarchy = {
                   MoveName = move.MoveName,
                   Hierarchy = move.Hierarchy,
                }

                return true
            end

        else            
            self.CurrentyMoveHierarchy = {
                MoveName = move.MoveName,
                Hierarchy = move.Hierarchy,
            }

            return true
        end
        -- ^^ Moves with same Name don't do nothing with each other.
        -- they will have their debounce themselfs.

     end

     function  self:ResetMoveHierarchy (move)
        if move.MoveName == self.CurrentyMoveHierarchy.MoveName then        
            self.CurrentyMoveHierarchy = {
                MoveName = "None",
                Hierarchy = 0,
            }
        end 
     end


end

-- CLIENT SIDE --
function WeaponClass:ClearItself()
    for _, child in pairs(self.MovesConnections) do 
        
        -- some inputs have this so we can use it.
        local sucess, err = pcall(function()
            child:DestroyMove()
        end)

        -- disconnect Remotes and specific stuffs.
        local sucess, err = pcall(function()
            child:Disconnect()
        end)
    end 


    for _, child in pairs(self.Janitor) do 
        -- functions that will help cleaning stuff.
        local sucess, err = pcall(function()
            child()
            child = nil
        end)
    end 

    table.clear(self.Janitor)
    table.clear(self.MovesConnections)

end

-- Load All Anim
function WeaponClass:LoadAnimations (Char: Model, Tracks: Folder)
    
    local Animator = Char.Humanoid:WaitForChild("Animator")

    local LoadedTracks = {}

    for _, Anim in pairs(Tracks:GetChildren()) do 
        if Anim:IsA("Animation") then
           LoadedTracks[Anim.Name] =  Animator:LoadAnimation(Anim)         
        end
    end 

    return LoadedTracks

end

function WeaponClass:Unequip ()
   
     -- Unequip Anim
    local SafeAtb = {"Landed", "Walk", "StopRunning"}

    self.Character.WeaponCommunication:FireServer("Equip", {
        Enable = false,
    })

   
    local WaitForTrack = false
    for _, child in pairs(SafeAtb) do 
            if self.Character:GetAttribute("LocalState") == child then
                 self.LoadedTracks.UnEquip:Play()
                 WaitForTrack = true
                 break            
            end
    end 



    
    --[[

    self.Character.WeaponCommunication:FireServer("Equip", {
        Enable = false,
        WaitForTrack = WaitForTrack, 
    })

    self:ClearItself()      
    --]]

end


----------------------
-- CLIENT SIDE --
----------------------

function WeaponClass:Equip ()
    
    -- Load Everything first
    self.Character = game.Players.LocalPlayer.Character
    self.LoadedTracks = self:LoadAnimations(self.Character, self.Animtracks)
     

   
    -- Equip Anim
    local SafeAtb = {"Landed", "Walk", "StopRunning"}

    --[[
  self.Character.WeaponCommunication:FireServer("Equip", {
        Enable = true,
        ItemID = self.ItemID,
        ItemName = self.WeaponName 
    })
        --]]

    task.spawn(function()
        for _, child in pairs(SafeAtb) do 
            if self.Character:GetAttribute("LocalState") == child then
                self.LoadedTracks.Equip:Play()
                break            
            end
        end 
    end)
    

  
    --self.Character.Humanoid:SetAttribute("Class", )


        print("EQUIP!")

    self.Character.WeaponCommunication:FireServer("Equip", {
        Enable = true,
        ItemID = self.ItemID,
        ItemName = self.WeaponName 

    })

    
     -- Basic Moves, M1, Feint, Stuff like that.
    self.StarterMoves = CodeAssist.DeepCopyTable( require(script.Parent.WeaponStarterMoves) )

    function self:IsInInventory ()
        if game.Players.LocalPlayer.Character:GetAttribute("InventoryMode") then
           return true
        else
            return false 
        end
    end

    setmetatable(self.StarterMoves, {__index = self }  )
    self.StarterMoves:_AddFunctionsIntoMove()

    self.StarterMoves:Client()
    
    -- Start all Weapon custom moves too 
    for _, WeaponMove in pairs(self.CustomMoves) do 
        setmetatable(WeaponMove, {__index = self }  )
        WeaponMove:Client()
    end 

end

function WeaponClass:SendMoveToClient (Player, Char)
    
    Char.WeaponCommunication:FireClient(Player, "LoadWeaponMoveset", self.WeaponName, self.ItemID)

end

-- SERVER SIDE --


function WeaponClass:EquipOnServer (tab)

    if self.ItemID == tab.ItemID then
        
    else
        return
    end
    
    local FirstName = tab.ItemID
    FirstName = string.split(FirstName, "/")
   
    --self.Character.Humanoid:SetAttribute("Class", tab.ItemName )
    self.Character.Humanoid:SetAttribute("Class",  self.HandType )

    -- ill warn to the Character Controlle the weapon he equipped.
    -- will be useful for some stuff like atb changed and the char will know what weapon 
    -- he can call some functions too.
   self:CallCharacterForChange({
        Signal = "CharacterChange",
        Param = "CurrentlyCharacterWeapon",
    },
    self.ItemID
   )
   

    self.ClonedModel =  WeaponSetup[self.HandType](self.Character)

    --[[
    -- very place holder since it don't work with other weapons rn    
    local NewModel = self.WeaponModel:Clone()
    local Motor6D = NewModel:FindFirstChildWhichIsA("Motor6D")

    Motor6D.Part0 = self.Character:FindFirstChild("Right Arm")
    Motor6D.Part1 = NewModel


    NewModel.Parent = self.Character
    
    self.ClonedModel = NewModel

       --]]

    -- Basic Moves, M1, Feint, Stuff like that.
    self.StarterMoves = CodeAssist.DeepCopyTable( require(script.Parent.WeaponStarterMoves) )

    setmetatable( self.StarterMoves, {__index = self }  )
    self.StarterMoves:_AddFunctionsIntoMove()


    self.StarterMoves:Server()


    -- Start all Weapon custom moves too 
    for _, WeaponMove in pairs(self.CustomMoves) do 
        setmetatable(WeaponMove, {__index = self }  )
        WeaponMove:Server()
    end

    -- Load Anims -- 
    local TracksAnims = {}
    for _, AnimTracks in pairs(self.Animtracks:GetChildren()) do 
        if AnimTracks:IsA("Animation") then else continue end 
        TracksAnims[AnimTracks.Name] = {}
        TracksAnims[AnimTracks.Name].id = AnimTracks.AnimationId
    end 

    self.Character.Animate.ChangeDefaultAnimations:FireClient(self.Player, TracksAnims )

    --]]



end


function WeaponClass:UnnequipOnServer(tab)
    
    
    if self.ClonedModel then 
        if tab.WaitForTrack then
             game:GetService("Debris"):AddItem(self.ClonedModel, .5)            
        else
             game:GetService("Debris"):AddItem(self.ClonedModel, 0)            
        end
        self.ClonedModel = nil
    end 
    self:ClearItself()

    -- ill warn to the Character Controlle the weapon he equipped.
    -- will be useful for some stuff like atb changed and the char will know what weapon 
    -- he can call some functions too.
   self:CallCharacterForChange({
        Signal = "CharacterChange",
        Param = "CurrentlyCharacterWeapon",
    },
    nil
   )

    self.CurrentlyCharacterWeapon = nil
    self.Character.Animate.ChangeDefaultAnimations:FireClient(self.Player, nil )
    --]]

end


function WeaponClass:ServerListenToPlayer (Char, Player)
    self.Character = Char
    self.Player = Player

    local Events = {
        ["Equip"] = function(tab)
            if tab.Enable == true then
                self:EquipOnServer({ItemID =  tab.ItemID})
            else
                self:UnnequipOnServer(tab)
            end
        end
    }

    -- Client will call for equip/unnequip
    local RemoteEvent = Char.WeaponCommunication.OnServerEvent:Connect(function(Player, Event, tab)
        if Player == self.Player then 
            if Events[Event] then 
                Events[Event](tab)
            end 
        end 
    end)

  
    
end


WeaponClass.SetToCharacter = function(Char)
   local RemoteEvent = Instance.new("RemoteEvent")
   RemoteEvent.Parent = Char
   RemoteEvent.Name = "WeaponCommunication"
   RemoteEvent:SetAttribute("PlayerFrom", game.Players:GetPlayerFromCharacter(Char).UserId )
end

WeaponClass.new = function(Configs: {})
    
    local NewWeapon = {
        
        WeaponName = Configs.WeaponName;

        Type  = Configs.Type; -- Type (Heavy, Light, Medium)
        BlockableDamageTypes = Configs.BlockableDamageTypes; -- Can Block Blade? Can't?...
        DamageType = Configs.DamageType; -- It's a blade? None? 
        Damages = Configs.Damages; -- Damages from all attacks. 

        CanByPass = Configs.CanByPass or {},

        HandType =  Configs.HandType or  "Dagger",


        StatusBlacklisted = Configs.StatusBlacklisted; -- Attacks and what will stop them from performing.
        Animtracks = Configs.Animtracks; -- AnimTracks FOLDER.
        AnimTracksSpeed = Configs.AnimTracksSpeed; -- Anim Track speed.
        ServerHitboxTiming = Configs.ServerHitboxTiming; -- Time to appear hitbox after attack
        AttackStunTime = Configs.AttackStunTime or {}; -- Time You get stunned after their attack.

        HitboxSize = Configs.HitboxSize; -- hitbox size
        HitboxPosition = Configs.HitboxPosition;
        EndLags = Configs.EndLags; -- M1 EndLag and other's skillset.
        
        WeaponModel = Configs.WeaponModel; -- Just the Model that we will use for it.
        
        DefaultCooldown = Configs.DefaultCooldown;

        Character = nil;  -- when a character equip this we will have it. The Server will set it.

        WeaponStatus = {}; -- Can Block or not, doing m1, stuff like that
        InCooldown = {};

        BaseCooldowns = Configs.BaseCooldowns or  {
            ["Heavy"] = 3,
            ["Feint"] = 1,
            ["Sprint Strike"] = 5,
            ["AirAttack"] = 2
        };
        CustomCooldowns = Configs.CustomCooldowns or {};

        KnockbackConfigs = Configs.KnockbackConfigs or  {
            
            ["Heavy"] = {
                DistanceKiller = 0;
                DistanceTarget = 50;
                SlamOnSurface = true;
                KnockbackType = "Normal";
                TargetAnimTrack = "Hit";
            },

            ["Sprint Strike"] = {
                DistanceKiller = 0;
                DistanceTarget = 10;
                SlamOnSurface = false;
                KnockbackType = "Normal";
                TargetAnimTrack = "Hit";
            },

            ["M1"] = {
                 [1] = {
                    DistanceKiller = 0;
                    DistanceTarget = 10;
                    SlamOnSurface = false;
                    KnockbackType = "Normal";
                    TargetAnimTrack = "Hit";
                 },
                 [2] = {
                    DistanceKiller = 0;
                    DistanceTarget = 10;
                    SlamOnSurface = false;
                    KnockbackType = "Normal";
                    TargetAnimTrack = "Hit";
                 },
                 [3] = {
                    DistanceKiller = 0;
                    DistanceTarget = 10;
                    SlamOnSurface = false;
                    KnockbackType = "Normal";
                    TargetAnimTrack = "Hit";
                 },
                 [4] = {
                    DistanceKiller = 5;
                    DistanceTarget = 50;
                    SlamOnSurface = true;
                    KnockbackType = "Normal";
                    TargetAnimTrack = "Knockback";
                 },
            }
        };

    }


   
    NewWeapon.MovesConnections = {}
    NewWeapon.MovesThreads = {}
    NewWeapon.Janitor = {}
    NewWeapon.AttributesFuncs = {} 
    -- Special functions depending on attributes,
    -- for example, if player get Stunned some skill will be in cooldown.

    local ClassCopy = CodeAssist.DeepCopyTable(WeaponClass)
    setmetatable(NewWeapon, {__index =  ClassCopy } )


   function NewWeapon:CheckIfInCooldown (Skill)

        -- if is not in table then is not in cooldown obviously.
        if not NewWeapon.InCooldown[Skill] then
            return false 
        end

        local CD_Timer =   game.Workspace:GetServerTimeNow() - NewWeapon.InCooldown[Skill] 
        
        local IsOnCD = false

        local function CheckIfisHighest (CD_Difference)
            if CD_Timer > CD_Difference then
                IsOnCD = false
            else
                IsOnCD = true
            end
        end

        if NewWeapon.BaseCooldowns[Skill] then
            CheckIfisHighest(NewWeapon.BaseCooldowns[Skill] )
        elseif  NewWeapon.CustomCooldowns[Skill] then
            CheckIfisHighest(NewWeapon.CustomCooldowns[Skill]  )
        end
        
        return IsOnCD

   end
    
   -- Get the Time we set this, will send for Client.
   function NewWeapon:GetSkillMaxTime (Skill)
        if NewWeapon.BaseCooldowns[Skill] then
            return NewWeapon.BaseCooldowns[Skill]
        elseif  NewWeapon.CustomCooldowns[Skill] then
            return NewWeapon.CustomCooldowns[Skill]
        end
   end
   function  NewWeapon:GetTimeSetOnCD (Skill)
        if  NewWeapon.InCooldown[Skill] then
            return NewWeapon.InCooldown[Skill]
        end
        return 0.1
   end

   function  NewWeapon:AddToCooldown(Skill)
        if not NewWeapon.InCooldown[Skill] then
            NewWeapon.InCooldown[Skill] = game.Workspace:GetServerTimeNow()
        else
            NewWeapon.InCooldown[Skill] = game.Workspace:GetServerTimeNow()
        end
   end


   --[[ Some attacks can cancel specific attacks, or 
    add into a specific tag list like "General" and other stuffs
   --]]
   NewWeapon.BlacklistedAttacks = {}
   
   -- Will Handle stuff like, add into a table. 
   -- so some attacks dont perform during each other.
   function NewWeapon:AddToBlacklist (tab)
        for _, Attacks in pairs(tab) do 
            table.insert(NewWeapon.BlacklistedAttacks, Attacks)
        end 
   end
   function  NewWeapon:IsOnBlacklist(tab)
       for _, Attacks in pairs(tab) do 
            if table.find(NewWeapon.BlacklistedAttacks, Attacks) then
                return true
            end
        end 
        return
   end
   function  NewWeapon:ClearBlacklist()
        table.clear(NewWeapon.BlacklistedAttacks)
        NewWeapon.BlacklistedAttacks = {}
   end

    -- Call for server when needed to damage.
    function NewWeapon:SendDamageRequest (tab)
        game.ServerScriptService.DamageRequest:Fire(tab)
    end 

    -- Events that i make inside scripts, so we can clear stuff when we unequip.
    function NewWeapon:AddToJanitor (action )
        table.insert(NewWeapon.Janitor, action)        
    end 
    

    return NewWeapon

end




return WeaponClass