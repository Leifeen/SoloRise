local DropItem = {}
DropItem.DroppedItemList = {}


DropItem.EquipItem = function(Item, ItemName, Char)
    
    -- If someone already picked this Item,
    -- we don't check for it;
    if  DropItem.DroppedItemList[Item]  then
        if  DropItem.DroppedItemList[Item].Debounce then
            return
        else
            DropItem.DroppedItemList[Item].Debounce = true
        end
    end

    if Char then
        local EntireID = Item:GetAttribute("EntireID")
        print(EntireID)
    
        Char:FindFirstChild("ItemPick"):Fire(Item:GetAttribute("EntireID") )
        DropItem.DroppedItemList[Item] = nil
    end




end

DropItem.CreateInteraction = function(Item, ItemName)
    
    local Proximity = Instance.new("ProximityPrompt")
    Proximity.Parent = Item:FindFirstChild("Handle") or Item:FindFirstChildWhichIsA("BasePart")

    Proximity.RequiresLineOfSight = false
    Proximity.MaxActivationDistance = 10


    Proximity.ObjectText = "Pick " .. ItemName

    local Dist = 0
    Proximity.Triggered:Connect(function( playerWhoTriggered)
        local Plr = playerWhoTriggered
        
        local Char = Plr.Character

        DropItem.EquipItem(Item, ItemName, Char)

        Item:Destroy()
    end)
    DropItem.DroppedItemList[Item] = {
        Debounce = false,
    }



end

DropItem.Drop = function(ItemID, Char )
    

    local SeparatedItemID = string.split(ItemID, "/")
    local ItemName = SeparatedItemID[1]
    local ItemFullID = SeparatedItemID[3]

    local Player = game.Players:GetPlayerFromCharacter(Char)

    local Tool = Char:FindFirstChild(ItemName) or Player.Backpack:FindFirstChild(ItemName)
   
    local function  SearchForTool (OBJ)
        for _, Item in pairs(OBJ:GetChildren()) do 
            if Item.Name == ItemName then
                if Item:GetAttribute("ItemID") and  Item:GetAttribute("ItemID")  == ItemFullID then
                    return Item
                end
            end
        end 

        return nil
    end
    local Tool = SearchForTool(Char) or SearchForTool(Player.Backpack)


    if Tool then
        local NewModel = Instance.new("Model")
        NewModel.Name = "DroppedItem"
        NewModel:SetAttribute("EntireID",  ItemID )

        for _, child in pairs(Tool:GetChildren()) do 
            child.Parent = NewModel
        end 

        -- Set PrimaryPart;
        if NewModel:FindFirstChild("Handle") then
            NewModel.PrimaryPart = NewModel.Handle 
     
        end

        NewModel:PivotTo(Char.HumanoidRootPart.CFrame  * CFrame.new(0,0,-3) )
        NewModel.Parent = game.Workspace
        Tool:Destroy()


        -- Set Collision and stuff
        for _, Part in pairs(NewModel:GetDescendants()) do 
            if (Part:IsA("BasePart") or Part:IsA("MeshPart")) and Part.Transparency ~= 1 then
                Part.CanCollide = true
            elseif  Part:IsA("BasePart") or Part:IsA("MeshPart")  then
                Part.CanCollide = false

                if not NewModel.PrimaryPart then
                     NewModel.PrimaryPart = Part
                end
            end

         

        end 

        DropItem.CreateInteraction(NewModel, ItemName)
    end



end


DropItem.Init = function()
    
    local BD = Instance.new("BindableEvent")
    BD.Name = "DropItem"
    BD.Parent = game:GetService("ServerScriptService").Server
    

    -- 
    BD.Event:Connect(function(ItemID, Char)
        DropItem.Drop(ItemID, Char)
    end)


end




return DropItem