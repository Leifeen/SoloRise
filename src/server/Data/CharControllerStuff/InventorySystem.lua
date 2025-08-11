
local InventorySystem = {}

local ItemsDesc = {}

InventorySystem.LastArmorName = nil

for _, Descs in pairs(game.ReplicatedStorage.Shared.Item:GetChildren()) do 
    if Descs:IsA("ModuleScript") then 
        ItemsDesc[Descs.Name] = require(Descs)
    end
end


-- Make Armor's work;
function InventorySystem:__SetupArmory (Armor, ArmoryConfigs, ArmorID)
    
    
    local LocationTo = string.split(ArmorID, "/")
    
    local Category = LocationTo[4]

    --self.EquippedArmor[LocationTo] = ArmorID
    Armor.AttributeChanged:Connect(function(Arg)
        if Arg == "ArmorHealth" then
            
            local FinalText = LocationTo[1] .. "/" .. LocationTo[2] .. "/" .. LocationTo[3] .. "/"  .. LocationTo[4] .. "/"

            local CurrentHealth = Armor:GetAttribute("ArmorHealth") 
            local MaxHealth = Armor:GetAttribute("MaxHealth")

            -- Make a new ID using our current one (it will change the health/maxhealth;)
            FinalText = FinalText .. "." .. CurrentHealth .. "-" .. MaxHealth

            self.EquippedArmor[Category]  = FinalText


        end
    end)


end


function InventorySystem:__ClearOldArmor (ItemName)
   
   
   
    if self.CharOwner:FindFirstChild(ItemName) then
        self.CharOwner:FindFirstChild(ItemName):Destroy()
        self.LastArmorName = ItemName
   end


end




function InventorySystem:__AddArmorIntoChar (Item, LocationTo)
    
    local ArmorAssets = game:GetService("ReplicatedStorage").Assets.Armor
    local Folders = {
        Common = ArmorAssets.Common,
        Uncommon = ArmorAssets.Uncommon
    }

    local function SearchForArmor(Item, Arg)
       
        local FoundItem = nil
        for _, Folder  in pairs(Folders) do 
            local ItemName = string.split(Item, "/")
            
            print(ItemsDesc.ArmorList)
            local ArmorAcess = ItemsDesc.ArmorList.Armors[ItemName[1]]

            local ArmorName = ArmorAcess[ItemName[4]].Name
            

            local FolderFrom = Folder:FindFirstChild(ItemName[1])

            if FolderFrom then
                FoundItem = FolderFrom:FindFirstChild(ArmorName)
                break
            end
        end 


        for _, child in pairs(FoundItem:GetDescendants()) do 
            if child:IsA("BasePart") or child:IsA("MeshPart") then
                child.Massless = true
                child.CanCollide = false
                child.CanQuery = false
                child.CanTouch = false
            end
        end 

        return FoundItem
    end

    local LocationsEvent = {

        ["Pants"] = function()
            

            local  ArmorName = string.split(Item, "/")
            ArmorName = ArmorName[1]
            
            local Armor = SearchForArmor(Item, "Pants")
            
            local FullName = string.split(Item, "/")
            self:__ClearOldArmor(FullName[1] ..  "/" .. FullName[4])

           
            

            local NewArmor = Armor:Clone()
         

            local CharPartsToAttach = {
                ["LLegMainHandler"] = "Left Leg" ,
                ["RLegMainHandler"]  = "Right Leg",
               -- ["TorsoMainHandler"] = "Torso"
            }

            -- Separate to Armor States,
            -- Health is the First
            local ArmorHealth = string.split(Item, ".")
            ArmorHealth = ArmorHealth[2]
            
            local CurrentHealth = string.find(ArmorHealth, "-")
            CurrentHealth = string.sub(ArmorHealth, 1, CurrentHealth - 1 )

            local MaxHealth = string.split(Item, "-")
            MaxHealth = MaxHealth[2] 

            NewArmor:SetAttribute("ArmorHealth", tonumber(CurrentHealth) )
            NewArmor:SetAttribute("MaxHealth",  tonumber(MaxHealth) )
            
            self:__SetupArmory(NewArmor, {
                ArmorHealth = CurrentHealth,
                MaxHealth = MaxHealth
            }, Item)
            
            for _, child in pairs(NewArmor:GetChildren()) do 
                if  CharPartsToAttach[child.Name] then
                    local W = Instance.new("Weld")
                    W.Parent = child
                    W.Part0 = self.CharOwner:FindFirstChild( CharPartsToAttach[child.Name] )
                    W.Part1 = child

                    local PartC0 =  child:GetAttribute("WeldC0")
                    W.C0 = PartC0

                end
            end 

            
            local DefaultCharSize = {
                ["Left Arm"] = Vector3.new(0.95, 2, 1),
                ["Right Arm"] = Vector3.new(0.95, 2, 1),
                ["Torso"] = Vector3.new(2, 2, 1)
            }


            NewArmor.Parent = self.CharOwner
            NewArmor.Name = FullName[1] .. FullName[4]






        end,

        ["Chest"] = function()
            
            local  ArmorName = string.split(Item, "/")
            ArmorName = ArmorName[1]
            
            local Armor = SearchForArmor(Item, "Top")
            

            local FullName = string.split(Item, "/")
            self:__ClearOldArmor(FullName[1] .. FullName[4])

            local NewArmor = Armor:Clone()
         

            local CharPartsToAttach = {
                ["LArmMainHandler"] = "Left Arm" ,
                ["RArmMainHandler"]  = "Right Arm",
                ["TorsoMainHandler"] = "Torso"

            }

            -- Separate to Armor States,
            -- Health is the First
            local ArmorHealth = string.split(Item, ".")
            ArmorHealth = ArmorHealth[2]
            
            local CurrentHealth = string.find(ArmorHealth, "-")
            CurrentHealth = string.sub(ArmorHealth, 1, CurrentHealth - 1 )

            local MaxHealth = string.split(Item, "-")
            MaxHealth = MaxHealth[2] 

            NewArmor:SetAttribute("ArmorHealth", tonumber(CurrentHealth) )
            NewArmor:SetAttribute("MaxHealth",  tonumber(MaxHealth) )
            
            self:__SetupArmory(NewArmor, {
                ArmorHealth = CurrentHealth,
                MaxHealth = MaxHealth
            }, Item)
            
            for _, child in pairs(NewArmor:GetChildren()) do 
                if  CharPartsToAttach[child.Name] then
                    local W = Instance.new("Weld")
                    W.Parent = child
                    W.Part0 = self.CharOwner:FindFirstChild( CharPartsToAttach[child.Name] )
                    W.Part1 = child

                    local PartC0 =  child:GetAttribute("WeldC0")
                    W.C0 = PartC0

                end
            end 


            NewArmor.Parent = self.CharOwner
            NewArmor.Name = FullName[1] .. FullName[4]


        end

    }

    LocationsEvent[LocationTo]()



end

function InventorySystem:Drop (tab)

    -- Get Bindable;
    local DropItem = game:GetService("ServerScriptService").Server.DropItem

    if table.find(self.Contents, tab.Item) then 
        local ToRemove = table.find(self.Contents, tab.Item)
        self.Contents[ToRemove] = nil
        

         DropItem:Fire(tab.Item, self.CharOwner)
        
        local LocationTo = string.split(tab.Item, "/")
        LocationTo = LocationTo[1]
        
         -- See it;, check what item is equipped at the moment;
        if self.Equipped == LocationTo[1] then
           self.Equipped = nil
        end

         return   
    end 


    for i, child in pairs(self.Hotbar) do 
        if child == tab.Item then
            
            local ItemName = string.split(tab.Item, "/")
            local ID = ItemName[3]

            ItemName = ItemName[1]


            for _, child in pairs(self.CharOwner:GetChildren()) do 
                   if child.Name == ItemName then
                        if child:GetAttribute("ItemID") == ID then
                            child:Destroy()
                            break
                        end
                   end
                end 

            self.Hotbar[i] = nil

            DropItem:Fire(tab.Item, self.CharOwner)

            local LocationTo = string.split(tab.Item, "/")
            LocationTo = LocationTo[1]
            
            -- See it;, check what item is equipped at the moment;
            if self.Equipped == LocationTo[1] then
                self.Equipped = nil
            end

            return
        end
    end 

    local SeparatedName = string.split(tab.Item, "/")

    if SeparatedName[4] then
        if  self.EquippedArmor[SeparatedName[4]] then
            self:__ClearOldArmor(SeparatedName[1] .. SeparatedName[4] )

            self.EquippedArmor[SeparatedName[4]] = nil
                
            DropItem:Fire(tab.Item, self.CharOwner)

            local LocationTo = string.split(tab.Item, "/")
            LocationTo = LocationTo[1]
            
            -- See it;, check what item is equipped at the moment;
            if self.Equipped == LocationTo[1] then
                self.Equipped = nil
            end

            return
        end
    end

    


end

function  InventorySystem:EquipArmory (tab)

    print(tab.Item)

    local LocationTo = string.split(tab.Item, "/")
    LocationTo = LocationTo[1]
        

    if self.Equipped ==  LocationTo then
        local Armor = self.CharOwner:FindFirstChildWhichIsA("Tool")
        if Armor then
            Armor.Parent = self.PlayerOwner.Backpack
        else
            self.Equipped = nil
        end
    end
    


    if table.find(self.Contents, tab.Item) then
        
        local St = table.find(self.Contents, tab.Item)
        self.Contents[St] = nil

        local LocationTo = string.split(tab.Item, "/")
        LocationTo = LocationTo[4]

        local LocationToEquip = self.EquippedArmor[LocationTo]
        if LocationToEquip == nil then 
            self.EquippedArmor[LocationTo] = tab.Item

            self:__AddArmorIntoChar(tab.Item, LocationTo )
            self:__AddArmorIntoChar(tab.Item, LocationToEquip)
            return
        else

            -- Clear it;
            local SeparatedInfo = LocationToEquip
            SeparatedInfo = string.split(SeparatedInfo, "/")

            SeparatedInfo = SeparatedInfo[1] .. SeparatedInfo[4]
            self:__ClearOldArmor(SeparatedInfo)


            table.insert(self.Contents,  LocationToEquip )
            
            self.EquippedArmor[LocationTo] = tab.Item

            self:__AddArmorIntoChar(tab.Item, LocationTo )
            return
        end 


    end


end

function InventorySystem:GetArmory ()

     local NewTB = {}
    for TableName, child in pairs(self.EquippedArmor) do 
        if child == nil then
            NewTB[TableName] = "None"
        else
            NewTB[TableName] = child
        end
    end 


    return  NewTB
end

function  InventorySystem:GetStatus()
    
end


function InventorySystem:GetInventory (tab)

    local NewTB = {}
    for _, child in pairs(self.Contents) do 
        table.insert(NewTB, child)
    end 

    return NewTB
end


function InventorySystem:AddToInventory (tab)
    
    if tab.Item then

        -- is already in Inventory;
        if table.find(self.Contents, tab.Item) then
                print("Added to Inventory!")
            return
        end
        --  Armor Interaction
        local SeparatedName = string.split(tab.Item, "/")
        
        if SeparatedName[4] then
            if  self.EquippedArmor[SeparatedName[4]] then
                self:__ClearOldArmor(SeparatedName[1] .. SeparatedName[4] )
                
                local NewItemText = self.EquippedArmor[SeparatedName[4]]
                table.insert(self.Contents, NewItemText)

                self.EquippedArmor[SeparatedName[4]] = nil
                return
            end
        end

        -- Hotbar Interaction
        local ItemOnHotbar = nil
        for i, child in pairs(self.Hotbar) do 
            if child == tab.Item then
                ItemOnHotbar = i
                break
            end
        end 

        if ItemOnHotbar then
            
            -- Unequip if the plr is equipping this specific tool;
            if self.CharOwner:FindFirstChildWhichIsA("Tool") then
                local Tool = self.CharOwner:FindFirstChildWhichIsA("Tool")
                
                local ItemName = string.split(tab.Item, "/")
                ItemName = ItemName[1]
                
                local ItemID = string.split(tab.Item, "/")
                ItemID = ItemID[3]

                if Tool.Name == ItemName then 
                    if Tool:GetAttribute("ItemID") then
                        print(Tool:GetAttribute("ItemID"))
                        if Tool:GetAttribute("ItemID") == ItemID then
                            Tool.Parent = self.PlayerOwner.Backpack
                            self.Equipped = nil
                        end
                    end
                end 
            end

            -- add it and remove from Hotbar;
            table.insert(self.Contents, tab.Item)
            self.Hotbar[ItemOnHotbar] = nil

        end

    end 

    --local Item = tab.Item
end

function  InventorySystem:AddToHotbar(tab)

    if tab.Item then

        if tab.Pos then
            
            if table.find(self.Contents, tab.Item) then

                local ItemName = string.split(tab.Item, "/")
                ItemName = ItemName[1]
                
                local ItemID = string.split(tab.Item, "/")
                ItemID = ItemID[3]


                local ClonedItem = nil
                for _, child in pairs(self.PlayerOwner.Backpack:GetChildren()) do 
                   if child.Name == ItemName then
                        if child:GetAttribute("ItemID") == ItemID then
                            ClonedItem = child
                            break
                        end
                   end
                end 

                local sucess, err = pcall(function()
                    if not  ClonedItem then
                         ClonedItem = self.PlayerOwner.Backpack:FindFirstChild(ItemName)
                             if not ClonedItem then
                             ClonedItem = self.PlayerOwner.Character:FindFirstChild(ItemName)
                              end
                    
                         ClonedItem.Parent = self.PlayerOwner.Backpack 
                    end
             
                end)
       
             

                -- if the Hotbar already has a item, 
                -- we add the Hotbar one into contents,
                -- and the Inv one in Hotbar. and remove from contents.
                 if self.Hotbar[tab.Pos] == nil then
                    
                    local OnListNB = table.find(self.Contents, tab.Item) 
                    if OnListNB then
                        table.remove(self.Contents, OnListNB)
                    end
                    
                    --table.insert(self.Contents, self.Hotbar[tab.Pos])
                    self.Hotbar[tab.Pos] = tab.Item 
                    

                    return ItemName

                 else
                    local OnListNB = table.find(self.Contents, tab.Item) 
                    if OnListNB then
                        table.remove(self.Contents, OnListNB)
                    end
                    table.insert(self.Contents, tostring(self.Hotbar[tab.Pos]))
                    

                    self.Hotbar[tab.Pos] = tab.Item
                    
                    return ItemName
                 end 
                
            end

        end

        if table.find(self.Contents, tab.Item) then
            local ItemName = string.split(tab.Item, "/")
            ItemName = ItemName[1]
            local ClonedItem = game.ServerStorage:FindFirstChild(ItemName):Clone()
            ClonedItem.Parent = self.PlayerOwner.Backpack
            
            -- Remove from inventory, add to hotbar;
            for i = 1, 9 do 
                if self.Hotbar[i] == nil then
                    local OnListNB = table.find(self.Contents, tab.Item) 
                    if OnListNB then
                        table.remove(self.Contents, OnListNB)
                    end
                    self.Hotbar[i] = tab.Item

                    return
                end
            end 


        end
    end

    -- Check direct from the Hotbar
    local CurrentPos = nil
    for i, HB in pairs(self.Hotbar) do 
        if HB == tab.Item then
            CurrentPos =  i
        end
    end 

    -- Ok it exist, so, we trade between it
    if CurrentPos then
        if tab.Pos then
            
            if self.Hotbar[tab.Pos] ~= nil then
                self.Hotbar[CurrentPos] = self.Hotbar[tab.Pos]
                self.Hotbar[tab.Pos] = tab.Item
            else
                self.Hotbar[CurrentPos] = nil
                self.Hotbar[tab.Pos] = tab.Item
            end


        end
    end


    return false 
    
end


function InventorySystem:UnequipFromBackpack (tab)

    if  self.CharOwner:FindFirstChildWhichIsA("Tool") then
    else
        return
    end

    local Tool = self.CharOwner:FindFirstChildWhichIsA("Tool")
    Tool.Parent = self.PlayerOwner.Backpack
    return Tool
end

function  InventorySystem:EquipFromBackpack(tab)
    

    local Item = tab.Item 
    local CalledInp = tab.SelectedHotbar or 10 

    
    -- check if player actually has it;
    if table.find(self.Contents, Item) then
    else
        return
    end

    if Item then
        Item = string.split(Item, "/")
        Item = Item[1] 
    else 
        return
    end

    -- Unequip Tools, if already equipped;
    if self.Equipped and self.Equipped == self.Hotbar[CalledInp] then
        self:UnequipFromBackpack(tab)
        self.Equipped = nil
        return 
    elseif  self.Equipped and self.Equipped ~= self.Hotbar[CalledInp] then
        self:UnequipFromBackpack(tab)
    end
    
    self.Hotbar[CalledInp] = Item
    self.Equipped = self.Hotbar[CalledInp]

    local NewItem = self.PlayerOwner.Backpack:FindFirstChild(Item)

    NewItem.Parent = self.CharOwner

    return NewItem




end

function  InventorySystem:EquipFromHotbar (tab)
    local Item = tab.Item 

    if Item then
        Item = string.split(Item, "/")
        Item = Item[1] 
    else 
        return
    end

    -- Unequip Tools, if already equipped;
    if self.Equipped and self.Equipped == self.Hotbar[tab.CalledHotbar] then
        self:RemoveFromHotbar(tab)
        self.Equipped = nil
        return 
    elseif  self.Equipped and self.Equipped ~= self.Hotbar[tab.CalledHotbar] then
        self:RemoveFromHotbar(tab)
    end
    

    self.Equipped = self.Hotbar[tab.CalledHotbar]

    local NewItem = self.PlayerOwner.Backpack:FindFirstChild(Item)

    NewItem.Parent = self.CharOwner

    return NewItem
   -- Item.Parent = self.CharOwner
end

function  InventorySystem:RemoveFromHotbar (tab)
    local Tool = self.CharOwner:FindFirstChildWhichIsA("Tool")
    Tool.Parent = self.PlayerOwner.Backpack
    return Tool
end 



function  InventorySystem:GetHotbar(tab)

    local NewTB = {}
    for i = 1, 9 do 
        if self.Hotbar[i] then
            NewTB[i] = tostring( self.Hotbar[i] )
        else
            NewTB[i] = "None"
        end
    end 

    return NewTB
end


-- Very specific name isn't
-- but it will create a tool and add to Player inv,
-- so we just read it and make player equip it. Cool!
function InventorySystem:CreateToolAndSendToPhysicalBackpack (Item)
    
    -- separete it;
    -- remember:  ItemName/Category/ID/Stats
    -- Since the DESC is something that not need to be unique, 
    -- just have the same name as the item, we don't need that into the item id.
    -- thats why it works like that


    
    local ItemArgs = string.split(Item, "/")
    
    local ItemCategory = ItemArgs[2]
    local ItemName = ItemArgs[1]
    local ItemID = ItemArgs[3]



   
    local MainFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets"):FindFirstChild(ItemCategory)
    if MainFolder then
        local ItemTool = MainFolder:FindFirstChild(ItemName)

        ItemTool = ItemTool:Clone()
        ItemTool:SetAttribute("ItemID", ItemID )
        ItemTool.Parent = self.PlayerOwner.Backpack      
    end
  

end


function InventorySystem:CreateArmorTools (Item)

    
    if Item then
        
    else 
        return
    end



    local Splitted = string.split(Item, "/")
    
    print(ItemsDesc.ArmorList[Splitted[1]])
    
    if Splitted[4] == "Chest" then
            
        -- Create a Armor Tool, PlaceHolder
        local Tool = Instance.new("Tool")
        Tool.Name = "Adventurer Armor"
        Tool.Parent = self.PlayerOwner.Backpack
        
        local Handle = Instance.new("Part")
        Handle.Size = Vector3.new(5,5,5)
        Handle.Transparency = 1
        Handle.Name = "Handle"
        Handle.Parent = Tool

        local Armor = game:GetService("ReplicatedStorage").Assets.Armor.Common.ScoutsArmor

        Armor = Armor:FindFirstChild("Scout’s Trousers")
        local OriginalArmor = Armor

        Armor = OriginalArmor:Clone()
        Armor.Parent = Tool

        Tool:SetAttribute("ItemID", "2")

        for _, child in pairs(OriginalArmor:GetDescendants()) do 
        
            if child:IsA("Part") and child:GetAttribute("WeldC0") then
            
                local Weld = Instance.new("Weld")
                Weld.Parent = Handle
                
                for _, ArmorCH in pairs(Armor:GetDescendants()) do 
                    if ArmorCH.Name == child.Name then
                        Weld.Part0 = ArmorCH
                    end
                end 

                Weld.Part1 = Handle

                Weld.C0 = child:GetAttribute("WeldC0")
            end
        end 
       
    elseif  Splitted[4] == "Pants"  then 

         -- Create a Armor Tool, PlaceHolder
        local Tool = Instance.new("Tool")
        Tool.Name = "Adventurer Armor"
        Tool.Parent = self.PlayerOwner.Backpack
        
        local Handle = Instance.new("Part")
        Handle.Size = Vector3.new(5,5,5)
        Handle.Transparency = 1
        Handle.Name = "Handle"
        Handle.Parent = Tool

        local Armor = game:GetService("ReplicatedStorage").Assets.Armor.Common.ScoutsArmor
        Armor = Armor:FindFirstChild("Scout’s Trousers")

        local OriginalArmor = Armor

        Armor = OriginalArmor:Clone()
        Armor.Parent = Tool

        Tool:SetAttribute("ItemID", "2")

        for _, child in pairs(OriginalArmor:GetDescendants()) do 
        
            if child:IsA("Part") and child:GetAttribute("WeldC0") then
            
                local Weld = Instance.new("Weld")
                Weld.Parent = Handle
                
                for _, ArmorCH in pairs(Armor:GetDescendants()) do 
                    if ArmorCH.Name == child.Name then
                        Weld.Part0 = ArmorCH
                        
                    end
                end 

                Weld.Part1 = Handle

                Weld.C0 = child:GetAttribute("WeldC0")
            end
        end 

    end
    print(Splitted)

end

InventorySystem.new = function(Char, Player)
    
    local NewInventory = {}
    -- Hotbar;
    NewInventory.Hotbar = {}
    NewInventory.PlayerOwner = Player
    NewInventory.CharOwner = Char

    NewInventory.Equipped = nil

    for i = 1, 9 do 
        NewInventory.Hotbar[i] = nil
    end 
    -- Extra;
    NewInventory.Hotbar[10] = nil

    -- Armor;
    NewInventory.EquippedArmor = {
        Helmet = nil,
        Chest = nil,
        Pants = nil,
        Boots = nil,
        Ring1 = nil,
        Ring2 = nil,
        Necklace = nil,
        Artifact = nil
    }

    -- Contents; ill just load it later on. but for now, do that;
    NewInventory.Contents = {}
    table.insert(NewInventory.Contents, "Apple/Consumable/2" )
    table.insert(NewInventory.Contents, "Apple/Consumable/3" )
    table.insert(NewInventory.Contents, "Water/Consumable/2" )
    table.insert(NewInventory.Contents, "ScoutsArmor/Gear/2/Chest/.100-200")
    table.insert(NewInventory.Contents, "ScoutsArmor/Gear/3/Pants/.100-200")
    table.insert(NewInventory.Contents,  "RaidersArmor/Gear/3/Chest/.100-200")

   
    --table.insert(NewInventory.Contents, "Experiencied Armor/Gear/2/Chest/.100-200")

    -- will use the "-" signal to calculate the Armor


    
    -- create Remote Events
    NewInventory.RFunction = Instance.new("RemoteEvent")
    NewInventory.RFunction.Name = "Inventory_Communication"
    NewInventory.RFunction.Parent = Char

    -- set mt
    setmetatable(NewInventory, {__index =  InventorySystem})

    -- Events Response;
    local Events = {

        -- Actions;
        ["DropItem"] = function(tab)
            NewInventory:Drop(tab)
        end,
        
        -- Main Inv Stuff;
        ["AddToArmory"] = function(tab)
            NewInventory:EquipArmory(tab)
        end,

        ["GetArmory"] = function(tab)
            local InvList = NewInventory:GetArmory()

            NewInventory.RFunction:FireClient(NewInventory.PlayerOwner, {
                Event = "GetArmory",
                List = InvList,
            } )

            return InvList
        end,


        ["GetInventory"] = function(tab)
            local InvList = NewInventory:GetInventory()

            NewInventory.RFunction:FireClient(NewInventory.PlayerOwner, {
                Event = "GetInventory",
                List = InvList,
            } )

            return InvList
        end,

        ["AddToBackpack"] = function(tab)
            local ItemAdded = NewInventory:AddToInventory(tab)
            return ItemAdded
        end,

        ["AddToHotbar"] = function(tab)
            local ItemAdded =  NewInventory:AddToHotbar(tab)
            return ItemAdded
        end,

        -- Hotbar Related;
        ["EquipFromHotbar"] = function(tab)
            return NewInventory:EquipFromHotbar(tab)
        end,

        ["EquipFromBackpack"] = function(tab)
            return NewInventory:EquipFromBackpack(tab)
        end,

        ["RemoveFromHotbar"] = function(tab)
            return NewInventory:RemoveFromHotbar(tab)
        end,

        ["GetHotbar"] = function(tab)
            local HotbarList = NewInventory:GetHotbar()
            
            NewInventory.RFunction:FireClient(NewInventory.PlayerOwner, {
                Event = "GetHotbar",
                List = HotbarList,
            } )
           

            return HotbarList
        end,

        ["Drop"] = function(tab)
            return NewInventory:Drop()
        end 
        
 
    }

    -- Server Event;
    NewInventory.RFunction.OnServerEvent:Connect(function(Player, tab)
        -- Check if the Player is the actual Owner;
        if Player ~= NewInventory.PlayerOwner then
            Player:Kick("You don't have perm to acess inventory from others.")
            return
        end

        -- Check if event exist and run it;
        if Events[tab.Event] then
            local Result = Events[tab.Event](tab)
            return Result
        end

    end)


    for _, Item in pairs(NewInventory.Contents) do 
        NewInventory:CreateToolAndSendToPhysicalBackpack(Item)
        NewInventory:CreateArmorTools(Item)
    end 


    NewInventory.CreateArmorTools()

   


    -- if a player picka item via prompt, 
    -- it will active;
    local BD = Instance.new("BindableEvent")
    BD.Name = "ItemPick"
    BD.Parent = NewInventory.CharOwner
    BD.Event:Connect(function(Item)
       
            -- Create a Tool for this item;
            table.insert(NewInventory.Contents, Item)

            local Category = string.split(Item, "/")
            local CategoryPartC1 = Category[2]
            local CategoryPartC2 = Category[4]
            

            
            if CategoryPartC1 == "Gear" then

                    -- Temporaly;
                    if Category[1] == "Adventurer Armor" then
                            -- Create a Armor Tool, PlaceHolder
                        local Tool = Instance.new("Tool")
                        Tool.Name = "Adventurer Armor"
                        Tool.Parent = NewInventory.PlayerOwner.Backpack
                        
                        local Handle = Instance.new("Part")
                        Handle.Size = Vector3.new(5,5,5)
                        Handle.Transparency = 1
                        Handle.Name = "Handle"
                        Handle.Parent = Tool

                        local Armor = game:GetService("ReplicatedStorage").Assets.Armor.Common.AdventurerArmor

                        Armor = Armor.AdventurerArmor_Top
                        local OriginalArmor = Armor

                        Armor = OriginalArmor:Clone()
                        Armor.Parent = Tool

                        Tool:SetAttribute("ItemID", "2")

                        for _, child in pairs(OriginalArmor:GetDescendants()) do 
                        
                            if child:IsA("Part") and child:GetAttribute("WeldC0") then
                            
                                local Weld = Instance.new("Weld")
                                Weld.Parent = Handle
                                
                                for _, ArmorCH in pairs(Armor:GetDescendants()) do 
                                    if ArmorCH.Name == child.Name then
                                        Weld.Part0 = ArmorCH
                                        
                                    end
                                end 

                                Weld.Part1 = Handle

                                Weld.C0 = child:GetAttribute("WeldC0")
                            end
                        end        
                    end
                 
            else
                NewInventory:CreateToolAndSendToPhysicalBackpack(Item)
            end


            local InvList = NewInventory:GetInventory()
            local InvListArmory = NewInventory:GetArmory()

            -- Fire!
            NewInventory.RFunction:FireClient(NewInventory.PlayerOwner, {
                Event = "GetInventory",
                List = InvList,
            } )

            NewInventory.RFunction:FireClient(NewInventory.PlayerOwner, {
                Event = "GetArmory",
                List = InvListArmory,
            } )


    end)






    return NewInventory



end


return InventorySystem