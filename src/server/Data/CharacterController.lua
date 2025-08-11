local CharacterController = {}

CharacterController.Characters = {}

local CodeAssist = require(game:GetService("ReplicatedStorage").Shared.Utility.CodeAssist )
local GoodSL = require(game.ReplicatedStorage.Shared.Utility.GoodSignal)  
local StateMachine = require(game:GetService("ServerScriptService").Server.Data.CharControllerStuff.StateMachine )
local InventorySystem = require(game:GetService("ServerScriptService").Server.Data.CharControllerStuff.InventorySystem)

function CharacterController:PlrMovementReceive ()
    
    self.OnSignalReceive:Connect(function(tab)
        StateMachine:SpecialState(tab.Event, self.Player, self.CharModel)
    end)

end

-- Get Damaged, stuff like that --
function CharacterController:OnStatusChanged ()
    self.Connections.OnAtbChanged =  self.CharModel.AttributeChanged:Connect(function(param)
       if param == "Stunned" then 
            if self.CurrentlyCharacterWeapon then 
                self.WeaponsModules[self.CurrentlyCharacterWeapon]:RunAttributeFunction("Stunned")
            end 
        end 
    end)
end


-- Functions of the Character.
function CharacterController:LoadWeapon (InvFolder)
    

    local function RandomizeModuleName ()
        
        local RandomLetters = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

        local RandomID = RandomLetters[math.random(1, #RandomLetters)]
        for i = 1, 10 do 
            RandomID = RandomID .. RandomLetters[math.random(1, #RandomLetters)] .. tostring(DateTime.now())
        end 

        return RandomID
    
    end


    local WeaponsFolder = game.ReplicatedStorage.Shared.Weapons

    local function FindWeapon (WeaponName: string)
        local ChoosedWeapon = nil
        for _, Child in pairs(WeaponsFolder:GetDescendants()) do 
            if Child:IsA("ModuleScript") and Child.Name == WeaponName then 
                ChoosedWeapon = Child
                break
            end 
        end 

        return ChoosedWeapon
    end

    -- ill load the weapons that the player has equipped.
    for i, Child in pairs(self.EquippedWeapon) do 
        local ChoosedWeapon = FindWeapon(Child)

        if ChoosedWeapon then
        else
            warn("Couldn't find " .. Child .. " Weapon." )
            continue
        end

        local RandomizedID = RandomizeModuleName()
        RandomizedID = CodeAssist.compress(RandomizedID)
        

        if not self.WeaponsModules[Child .. RandomizedID] then 
            self.WeaponsModules[Child .. RandomizedID] = require(ChoosedWeapon) 

            self.WeaponsModules[Child .. RandomizedID].ItemID =  Child .. RandomizedID
        else 
            self.WeaponsModules[Child .. "_" .. tostring(i) .. RandomizedID ] =  require(ChoosedWeapon) 
            -- if same name or anything, add a number into it. 
             self.WeaponsModules[Child .. "_" .. tostring(i) .. RandomizedID ].ItemID =  Child .. "_" .. tostring(i) .. RandomizedID
        end 
    end 


  
    -- Make Player Load the Weapon he got.
    for TableName, Weapon in pairs(self.WeaponsModules) do 
        
        local NewTB = CodeAssist.DeepCopyTable(Weapon)
        setmetatable(NewTB, {__index = Weapon})

        self.WeaponsModules[TableName] = NewTB

        -- Send the moves from Weapon and make it listen to the Player.
        NewTB:SendMoveToClient(self.Player, self.CharModel,  TableName)
        NewTB:ServerListenToPlayer(self.CharModel, self.Player)
        
        local CharTable = self
        function NewTB:CallCharacterForChange (tab, NewValue)
            if tab.Signal == "CharacterChange" then 
                CharTable.CurrentlyCharacterWeapon = NewValue
            end 
        end


         -- Make a Physical Tool
        local Tool = Instance.new("Tool")
        Tool.CanBeDropped = false 
        Tool.Parent = InvFolder
        Tool.Name = Weapon.WeaponName
        Tool:SetAttribute("ItemID", Weapon.ItemID)

        warn("For debug purpose cloned the tool directly into Char.")
        local NewTool = Tool:Clone()
        NewTool.Parent = self.Player.Backpack

    end 


end

-- This will Create our Base Character.
CharacterController.CreateChar = function(Char: Model, Player: Player  )
    
    Char.Parent = game.Workspace.Entity

    local NewCharacter = {

        EquippedWeapon = {"Katana", "Dagger", "GreatSword"},
        CurrentlyCharacterWeapon = nil, -- Ill add the ID of the weapon.
    

        WeaponsModules = {}, -- This will be where i keep the Weapons functionality at.
        Inventory =  InventorySystem.new(Char, Player )
,

        CharModel = Char,
        Player = Player,


        NormalWalkSpeed = 16,
        MaxWalkSpeed = 30,
        Connections = {},
    }
    


    Char:SetAttribute("Posture", 0)
    Char:SetAttribute("MaxPosture", 50)
    Char:SetAttribute("Running", false)
    Char:SetAttribute("InCombat", false)

    -- add weapon class into controller.
    CharacterController.WeaponClass = CodeAssist.DeepCopyTable( require(game:GetService("ReplicatedStorage").Shared.Weapons.WeaponClass ))


    -- Set a unique remote for the Player, it will handle all the weapons needed. --
    CharacterController.WeaponClass.SetToCharacter(Char)

    local CharControl = CodeAssist.DeepCopyTable(CharacterController)
    setmetatable(NewCharacter, {__index =  CharControl} )

    local PlrInv = Instance.new("Folder")
    PlrInv.Name = "DataInventory"
    PlrInv.Parent = Player

    -- Load Weapons 
    NewCharacter:LoadWeapon(PlrInv)

    local Event = Instance.new("RemoteEvent")
    Event.Name = "CharActions"
    Event.Parent = Char

    local GetInfo = Instance.new("BindableFunction")
    GetInfo.Name = "GetCharInfo"
    GetInfo.Parent = Char

    local GetInfoLocal = Instance.new("RemoteFunction")
    GetInfoLocal.Name = "GetInfo_LOCAL"
    GetInfoLocal.Parent = Char

    -- Signal Created for the Module
    NewCharacter.OnSignalReceive =  GoodSL.new("OnPlrCLEvent" .. tostring(Player.UserId))
    NewCharacter.ServerInfoRequest =  GoodSL.new("OnPlrServerEvent" .. tostring(Player.UserId))

    -- Normal Stuff
    local OnServerCalled =  Event.OnServerEvent:Connect(function(player, tab)
        if player == NewCharacter.Player then
           NewCharacter.OnSignalReceive:Fire(tab)     
        end
    end)

    GetInfo.OnInvoke = function(tab)
        
        local Result = nil
        -- depending on event we return what we need
        if tab.Event == "GetState" then 
            Result = NewCharacter.StateMachine:GetState()
        elseif  tab.Event == "IsStateInList"  then  
            Result = NewCharacter.StateMachine:HasStateInList(tab.ListMentioned)

        end 
       return Result
    end
    GetInfoLocal.OnServerInvoke = function(Plr, tab)
        local Result = nil
         if  tab.Event == "IsStateInList"  then  
            Result = NewCharacter.StateMachine:HasStateInList(tab.ListMentioned)
        elseif  tab.Event == "GetCurrentState" then
            
            Result = NewCharacter.StateMachine:GetState()
          
            if Result == tab.StateMentioned then
                return true
            else
                return false
            end

        end 
        return Result
    end


    table.insert(NewCharacter.Connections, OnServerCalled )

    -- Load Player Controlers.
    for _, Module  in pairs(script.Parent.CharControllerStuff:GetDescendants() ) do 
        if Module:IsA("ModuleScript") then else continue end 
        
        NewCharacter[Module.Name] = require(Module)
        
        setmetatable(NewCharacter[Module.Name], {__index = NewCharacter} )
        
        NewCharacter[Module.Name]:Init()

    end 

    NewCharacter:PlrMovementReceive()

    NewCharacter:OnStatusChanged()

  
   -- Add Weapon to Hotbar;
   local Count = 0
    for i, Weapon in pairs(NewCharacter.WeaponsModules) do 
        Count += 1 
        NewCharacter.Inventory.Hotbar[Count] = Weapon.WeaponName .. "/Gear" .. "/" .. Weapon.ItemID .. "DAMAGE:" .. Weapon.Damages["M1"][4]
    end 

   

    return NewCharacter
end




-- This will Init the System -- 
CharacterController.Init = function()
    game.Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(Char)
            
            repeat task.wait()
            until Char and  Char.Humanoid or not player

            local NewChar = CharacterController.CreateChar(Char, player)


        end)
    end)
end

return CharacterController