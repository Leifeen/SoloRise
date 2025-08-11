local InventoryHandler = {}
local InputMovesHandler = require(game:GetService("ReplicatedStorage").Shared.gameplay.InputMovesHandler)
local TextService = game:GetService("TextService")

local DescriptionC = require(game:GetService("ReplicatedStorage").Shared.Utility.DescriptionCreator)

-- on Changed -- 
local UserInpSV = game:GetService("UserInputService")
local BasicMouseInp = nil
local Moved = nil
game:GetService("UserInputService").Changed:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1  then
		BasicMouseInp = input
        Moved = true
	end
end)

-- Health, Mana, Etc these type of stats that will be added
-- with the original Data;
InventoryHandler.TotalStatusInfo = {}
-- ill save it in this table, since its easier to update and change;

-- Requiere all Desc;
local ItemsDesc = {}
for _, Descs in pairs(game.ReplicatedStorage.Shared.Item:GetChildren()) do 
    if Descs:IsA("ModuleScript") then 
        ItemsDesc[Descs.Name] = require(Descs)
    end
end





-- will use it globally so i cancel drop whatever i want.
InventoryHandler.HasDropResponse =  false 
InventoryHandler.IsInfoEnabled = false 
InventoryHandler.SelectedInfoFrame = nil

InventoryHandler.Connections = {}
InventoryHandler.HotbarGuis = {}

-- Modules
local GoodSignal = require(game:GetService("ReplicatedStorage").Shared.Utility.GoodSignal )


local DraggableObj = require(game:GetService("ReplicatedStorage").ExternalPackages.DraggableObject )

InventoryHandler.AnimsTracks = {}
InventoryHandler.DummyAnimTracks =  {}
InventoryHandler.LastArmorEdited = nil

local function GetTracks (Char, IsClone)
    local Helmet = Char.Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Animations.BackpackAnims.Helmet)
    local TorsoArmor = Char.Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Animations.BackpackAnims.Torso)
    local Pants = Char.Humanoid.Animator:LoadAnimation(game.ReplicatedStorage.Animations.BackpackAnims.Pants)

    if IsClone then  
        InventoryHandler.AnimsTracks.Helmet = Helmet
        InventoryHandler.AnimsTracks.Torso = TorsoArmor
        InventoryHandler.AnimsTracks.Pants = Pants
    else 
        InventoryHandler.DummyAnimTracks.Helmet = Helmet
        InventoryHandler.DummyAnimTracks.Torso = TorsoArmor
        InventoryHandler.DummyAnimTracks.Pants = Pants
    end 

    

end

-- Enable Info UI -- 
InventoryHandler.UI_Info = function(FrameFrom, ItemArg)

    local ItemShowUI = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack.ItemShow


    local isStillAble = true 
    local TemporC = nil
    TemporC = FrameFrom.MouseLeave:Once(function()
        isStillAble = false 
        InventoryHandler.IsInfoEnabled = false 
        ItemShowUI.Visible = false 
    end)


    task.wait(0.2)
    if InventoryHandler.IsInDragMode then 
        TemporC:Disconnect()
        
        isStillAble = false 
        InventoryHandler.IsInfoEnabled = false 
        ItemShowUI.Visible = false 
        return
    end 
    if isStillAble then 

    else 
        return
    end 
    -- check if the info is enabled and change for a new one 
    -- if already is;
    if InventoryHandler.IsInfoEnabled then
        if FrameFrom ~= InventoryHandler.SelectedInfoFrame then 
             InventoryHandler.IsInfoEnabled = false 
             return InventoryHandler.UI_Info(FrameFrom)
        end 

        return
    end

  
    -- Item ID 
    local ItemID = string.split(ItemArg, "/")
    local ItemName = ItemID[1]
    local ItemCategory = ItemID[2]

    
    local ItemDesc = DescriptionC.ExistingDescs[ItemName]
    -- Check if we have a ItemDesc;
    if ItemDesc then 
        local ItemDesc = ItemDesc.MainDesc

        ItemShowUI.Category.TextLabel.Text = ItemCategory


        local Damage =  string.split(ItemArg,"DAMAGE:")
        Damage = Damage[2]

        for _, child in pairs(ItemShowUI.DescFrame:GetChildren()) do 
            if child:IsA("TextLabel") and child.Name ~= "Template" then
                child:Destroy()
            elseif child:IsA("TextLabel") then 
                child.Visible = false 
            end
        end 

      
        
        if Damage then
            local Template = ItemShowUI.DescFrame:FindFirstChildWhichIsA("TextLabel")
            Template =  Template:Clone()
            Template.Name = "StatusContent"
    
            Template.Parent = ItemShowUI.DescFrame
            Template.Text = "Damage " .. Damage  
            
            Template.Visible = true 
          
        end

        print(ItemsDesc)
        if ItemsDesc.ArmorList.Armors[ItemName] then 
       -- print(ItemsDesc[ItemName][ItemCategory])
                local BodyP = ItemID[4]

                ItemShowUI.Desc.Text = ItemsDesc.ArmorList.Armors[ItemName][BodyP].Name
                ItemShowUI.DescTop.Text = ItemsDesc.ArmorList.Armors[ItemName][BodyP].Desc    
        else
            ItemShowUI.Desc.Text = ItemDesc
            ItemShowUI.DescTop.Text = ItemName
        end 

    end 

    -- Let it go to FrameFrom Position
    ItemShowUI.Position = UDim2.new(0, FrameFrom.AbsolutePosition.X / FrameFrom.Size.X.Scale,0,FrameFrom.AbsolutePosition.Y / FrameFrom.Size.Y.Scale  )
    
    -- Get the Camera Size so we can multiply the position with it
    local CameraScreenSize = game.Workspace.CurrentCamera.ViewportSize
    
    -- see where it's from;
    local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack
    local CharacterFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character
    local HotbarFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Hotbar

    -- Default
    local ToAddPos = UDim2.new(0, 0.04 * CameraScreenSize.X, 0, 0.1 * CameraScreenSize.Y )
    -- we ill change depending on the frame;
    if FrameFrom:IsDescendantOf(CharacterFrame) then
        ToAddPos = UDim2.new(0, -0.2 * CameraScreenSize.X, 0, 0.1 * CameraScreenSize.Y )
    elseif FrameFrom:IsDescendantOf(HotbarFrame) then
        ToAddPos = UDim2.new(0, 0.04 * CameraScreenSize.X, 0, -0.15 * CameraScreenSize.Y )
    end


    ItemShowUI.Position =   ItemShowUI.Position + ToAddPos

    ItemShowUI.Visible = true 

    InventoryHandler.IsInfoEnabled = true  
    InventoryHandler.SelectedInfoFrame = FrameFrom


end






-- Extra -- 
InventoryHandler.GetItemInformation = function(ItemFullID)
    
    local FinalInfos = {
        Name = "None",
        Type = "None",
        Desc = "None",
    }

    local OrganizedID = string.split(ItemFullID, "/")

    local ItemName = OrganizedID[1]
    local ItemPart = OrganizedID[4]

    if  ItemsDesc.ArmorList.Armors[ItemName] then
        FinalInfos.Name = ItemsDesc.ArmorList.Armors[ItemName][ItemPart].Name
        FinalInfos.Desc = ItemsDesc.ArmorList.Armors[ItemName][ItemPart].Desc
    else
        FinalInfos.Name = ItemName

        for TableName, child in pairs(ItemsDesc) do 
            if TableName == ItemName then
                FinalInfos.Desc = child.Desc
            end
        end 

    end

    FinalInfos.Type = OrganizedID[3]


    --local DescFull = ItemsDesc.ArmorList.Armors[ItemName][ItemPart]["Name"]


    return FinalInfos

end


InventoryHandler.DirectSelected = function(OriginalFrame, Item, SlotPos)
    
    local sucess, err = pcall(function()
          local MainColor = Color3.fromRGB(102, 102, 102)

        OriginalFrame:SetAttribute("Selected", true)

        OriginalFrame.ImageColor3 = MainColor      
    end)
  

    local InvCL = game.Players.LocalPlayer.Character:FindFirstChild("Inventory_Communication")  
    local FrameHotbar = game.Players.LocalPlayer.PlayerGui.InventoryUI.Hotbar

    if OriginalFrame:IsDescendantOf(FrameHotbar) then
            
        local Hotbar = InvCL:FireServer({
            Event = "EquipFromHotbar",
            Item = Item,
            CalledHotbar =  SlotPos
        })
    else 
        local Hotbar = InvCL:FireServer({
            Event = "EquipFromBackpack",
            Item = Item,
            SelectedHotbar = SlotPos or 10
        })
    end
    
         
    



end


InventoryHandler.DropItem = function(OriginalFrame, Item, ToOccupy)
    
    local DropWarn = game.Players.LocalPlayer.PlayerGui.InventoryUI.DropWarn
    DropWarn.Visible = true 

    InventoryHandler.HasDropResponse = false 
    local Declined = true 

    local sucess, err = pcall(function()
        InventoryHandler.Connections.DeclineDrop:Disconnect()
        InventoryHandler.Connections.ConfirmDrop:Disconnect()
    end)

    InventoryHandler.Connections.DeclineDrop =  DropWarn.MainGUI.Decline.MouseButton1Click:Connect(function()
        InventoryHandler.HasDropResponse = true  
    end)
    InventoryHandler.Connections.ConfirmDrop = DropWarn.MainGUI.Confirm.MouseButton1Click:Connect(function()
        Declined = false 
        InventoryHandler.HasDropResponse = true 

        print(OriginalFrame)
        OriginalFrame:FindFirstChildWhichIsA("TextLabel").Visible = true

    end)

    repeat task.wait() 
    until InventoryHandler.HasDropResponse

    DropWarn.Visible = false 

    local InvCL = game.Players.LocalPlayer.Character:FindFirstChild("Inventory_Communication")  

        if Declined then 
        
        else 
            local Hotbar = InvCL:FireServer({
                Event = "DropItem",
                Item = Item,
            })
        end  

  
    
        local Hotbar = InvCL:FireServer({
            Event = "GetHotbar",
            Item = Item
        })
            
        InvCL:FireServer({
            Event = "GetArmory",
        })  
            
        -- Get inventory 
        local InvBackpack = InvCL:FireServer({
            Event = "GetInventory",
        })


end

-- Load Status Info -- 
InventoryHandler.LoadCurrentAvatar = function()
    

    if game.Players.LocalPlayer.Character then 
    
        if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 

        else 
            game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        end 
    else 
        repeat
            task.wait()
        until game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end 

    local Mainhud = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character
    local PlayerIcon = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character.PlayerIcon


    local CharClone = game.Players.LocalPlayer.Character
    CharClone.Archivable = true 
    CharClone = CharClone:Clone()
    for _, child in pairs(CharClone:GetDescendants()) do 
        if child:IsA("LocalScript") or child:IsA("ModuleScript") then
            child:Destroy()
        end
    end 

    CharClone.Parent = PlayerIcon.ViewportFrame.WorldModel
    CharClone:PivotTo(CFrame.new(0,0,0))

    if PlayerIcon.ViewportFrame.WorldModel:FindFirstChild("RefChar") then
        PlayerIcon.ViewportFrame.WorldModel:FindFirstChild("RefChar"):Destroy()
    end
    CharClone.Name = "RefChar"

    game.Players.LocalPlayer.Character.Archivable = false
    
    local ViewCamera = nil
    
     if not PlayerIcon.ViewportFrame:FindFirstChild("Camera") then
        local NewCamera = Instance.new("Camera")
        NewCamera.Parent = PlayerIcon.ViewportFrame
        PlayerIcon.ViewportFrame.CurrentCamera = NewCamera
        ViewCamera = PlayerIcon.ViewportFrame.CurrentCamera
    else
        PlayerIcon.ViewportFrame.CurrentCamera = PlayerIcon.ViewportFrame:FindFirstChild("Camera")
        ViewCamera = PlayerIcon.ViewportFrame.CurrentCamera
    end

     ViewCamera.CFrame = CFrame.new(0,0,0) + CharClone.Head.CFrame.LookVector * 5
     ViewCamera.CFrame =  ViewCamera.CFrame * CFrame.Angles(0, math.rad(180),0)

    GetTracks(CharClone, true)


     local TracksAndActions = {
        ["Chest"] = function()
           
            InventoryHandler.AnimsTracks.Torso:Play()
            
            
            local PlayerIcon = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character.PlayerIcon
            local UICHAR = PlayerIcon.ViewportFrame.WorldModel:WaitForChild("RefChar")
            GetTracks(UICHAR, true)
            InventoryHandler.DummyAnimTracks.Torso:Play()
        end,
        ["Pants"] = function()
            InventoryHandler.AnimsTracks.Pants:Play()
            
            
            local PlayerIcon = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character.PlayerIcon
            local UICHAR = PlayerIcon.ViewportFrame.WorldModel:WaitForChild("RefChar")
            GetTracks(UICHAR, true)
            InventoryHandler.DummyAnimTracks.Pants:Play()
        end,

        ["Top"] = function()
            
        end,
    }   

    local sucess, err = pcall(function()
        if InventoryHandler.LastArmorEdited then 
            TracksAndActions[InventoryHandler.LastArmorEdited]()
            InventoryHandler.LastArmorEdited = nil
        end 
    end)

end


InventoryHandler.InitPointsHandler = function()
    
    local Mainhud = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character
    local PlayerIcon = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character.PlayerIcon
    local StatsFrame = Mainhud.StatsFrame
    local DataRemote =  game.Players.LocalPlayer.Character:WaitForChild("Data_CL")


     local Huds = {
        PlayerRank = PlayerIcon.PlayerRank,

        Agility = StatsFrame.Agility,
        Strength = StatsFrame.Strength,
        Mana = StatsFrame.Mana,
        Endurance = StatsFrame.Endurance,
        StatusSpentCount = StatsFrame.StatSpentCountText

    }

    -- Create a list of buttons
    local HudButtons = {}
    for TB_Name, UiFromCategory in pairs(Huds) do 
        if UiFromCategory:FindFirstChildWhichIsA("ImageButton") then
             HudButtons[TB_Name] = UiFromCategory:FindFirstChildWhichIsA("ImageButton")            
        end
    end 

    -- Set Buttons so they are actually clickable 
    for  TB_Name, Button in pairs(HudButtons) do
        
        Button.MouseButton1Click:Connect(function(Button)
            DataRemote:FireServer({
                Event = "SpentPoints",
                Atb = TB_Name
            })
        end)

        
        Button.MouseLeave:Connect(function()
            Button.ImageColor3 = Color3.fromRGB(255,255,255)
        end)
        Button.MouseEnter:Connect(function()
             Button.ImageColor3 = Color3.fromRGB(212, 67, 67)
        end)

    end

end


InventoryHandler.LoadStatus = function(PlrData)
    
    local PlrStatus = PlrData.Status
    local Endurance = PlrStatus.Endurance
    local Mana = PlrStatus.Mana
    local Strength = PlrStatus.Strength
    local Agility = PlrStatus.Agility

    local Mainhud = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character
    
    local PlayerIcon = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character.PlayerIcon
    local StatsFrame = Mainhud.StatsFrame


    local Huds = {
        PlayerRank = PlayerIcon.PlayerRank,

        Agility = StatsFrame.Agility,
        Strength = StatsFrame.Strength,
        Mana = StatsFrame.Mana,
        Endurance = StatsFrame.Endurance,
        StatusSpentCount = StatsFrame.StatSpentCountText,
        AvaibleStatsPoints = StatsFrame.StatsPoints

    }

    Huds.PlayerRank.Text = PlrStatus.Rank

    Huds.Strength.Text = "Strength: " ..  Strength
    Huds.Endurance.Text = "Endurance: " ..  Endurance
    Huds.Agility.Text = "Agility: " ..  Agility
    Huds.Mana.Text = "Mana: " ..  Mana
    --Huds.StatusSpentCount.Text = PlrData.Status.StatPoints .. "/" ..  "100"
     Huds.AvaibleStatsPoints.Text = "Stat Points: " ..  PlrData.Status.StatPoints




end




-- Create a Backpack Update Signal
local BackpackUpdateSignal = GoodSignal.new("BackpackUpdate" )

-- Everything Related to Armor -- 
InventoryHandler.LoadArmory = function(Armorys, InvCL)
    

    local InventoryUI = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character
  -- Convert None String to actual Nill values;
    for i, child in pairs(Armorys) do 
        if child == "None" then
            Armorys[i] = nil
        end
    end 

    local Uis = {
        Helmet = InventoryUI.Helmet,
        Chest = InventoryUI.Chest,
        Pants = InventoryUI.Pants,
        Boots = InventoryUI.Boots,

        Necklace = InventoryHandler.Necklace,
        Ring1 = InventoryUI.Ring1,
        Ring2 = InventoryUI.Ring2,
        Artifact = InventoryUI.Artifact,
    }
    -- Get all Ui's text and create a base for it, so we use.
    if not InventoryHandler.BackpackBaseNames then
        InventoryHandler.BackpackBaseNames = {}
        for TableName, child in pairs(Uis) do 
            local NameFromType = child:FindFirstChildWhichIsA("TextLabel")
            InventoryHandler.BackpackBaseNames[TableName] = NameFromType.Text            
        end 
    end

   
    local LoadedFrames = {}
    -- Get all the armos and add a UI if it exist.
    for TableName, NewFrame in pairs(Uis) do 
        if Armorys[TableName] ~= nil then 
           
            NewFrame:SetAttribute("Item", Armorys[TableName])

            local SplitTXT = string.split(Armorys[TableName], "/")
            local ItemName = SplitTXT[1]

            
            local TextLB = NewFrame:FindFirstChildWhichIsA("TextLabel")
            TextLB.Text = ItemName
            TextLB.Visible = true

            local SpecialCategory = string.split(Armorys[TableName], "/")
            SpecialCategory = SpecialCategory[4] or nil
            
            if SpecialCategory then
                NewFrame:SetAttribute("SpecialCategory", SpecialCategory)                
            end

            local TButton = Instance.new("TextButton")
            TButton.Name = "DragButton"
            TButton.Parent = NewFrame
            TButton.Size = UDim2.new(1,0,1,0)
            TButton.Transparency = 1
            TButton.Text = ""

            TButton.MouseButton1Down:Connect(function(Inp)
                InventoryHandler.DragMode(NewFrame, Armorys[TableName], "FromArmory")
            end)

               -- // Mouse Enter 
            TButton.MouseEnter:Connect(function(x, y)
                InventoryHandler.UI_Info(TButton, TableName)
            end)

            continue

        else

            NewFrame:FindFirstChildWhichIsA("TextLabel").Text = InventoryHandler.BackpackBaseNames[TableName]
            NewFrame.Visible = true

            NewFrame:SetAttribute("SpecialCategory", nil)
            NewFrame:SetAttribute("Item", nil)

            if NewFrame:FindFirstChild("DragButton") then
                NewFrame:FindFirstChild("DragButton"):Destroy()
            end

        end 

        if InventoryHandler.BackpackBaseNames[TableName] then
            
            NewFrame:FindFirstChildWhichIsA("TextLabel").Text = InventoryHandler.BackpackBaseNames[TableName]
            NewFrame.Visible = true

            NewFrame:SetAttribute("SpecialCategory", nil)
            NewFrame:SetAttribute("Item", nil)

            if NewFrame:FindFirstChild("DragButton") then
                NewFrame:FindFirstChild("DragButton"):Destroy()
            end
        end

    end 



end



-- Load Hotbar;
InventoryHandler.LoadHotbar = function(Hotbar, InvCL)
    
    -- Convert None String to actual Nill values;
    for i, child in pairs(Hotbar) do 
        if child == "None" then
            Hotbar[i] = nil
        end
    end 

    local InvInputs = {
      [1] = Enum.KeyCode.One, 
      [2] = Enum.KeyCode.Two, 
      [3] = Enum.KeyCode.Three, 
      [4] = Enum.KeyCode.Four, 
      [5] = Enum.KeyCode.Five, 
      [6] = Enum.KeyCode.Six, 
      [7] = Enum.KeyCode.Seven, 
      [8] = Enum.KeyCode.Eight, 
      [9] = Enum.KeyCode.Nine, 
    }
    local Translated = {}

    -- Translate it to normal numbers;
    local Current = 1
    for  i, CurrentInp in pairs(InvInputs) do 
        Translated[CurrentInp] = Current
        Current += 1
    end 

    local WeaponsInInputs = {}

    local InventoryUI = game.Players.LocalPlayer.PlayerGui.InventoryUI.Hotbar
    local Template = InventoryUI.ContentTemplate

    local AlreadyIn = {}
    -- Give info of the Slos that we already have;
    for _, child in pairs(InventoryUI:GetChildren()) do 

            if child:IsA("Frame") then else continue end 

            local PosInSlot = child:GetAttribute("HotbarSlotPos")
            local ItemInfo =  child:GetAttribute("ItemInformation")
            if PosInSlot and ItemInfo then 
                AlreadyIn[PosInSlot] = {}
                AlreadyIn[PosInSlot].Info = child:GetAttribute("ItemInformation") or nil
                AlreadyIn[PosInSlot].UI = child
                AlreadyIn[PosInSlot].UI:FindFirstChildWhichIsA("TextLabel").Visible = true 
            end 
    end 

   -- Clear every PlaceHolder Frame
    for _, Item in pairs(InventoryUI:GetChildren()) do 
        if Item:IsA("Frame") then
        else
            continue
        end
        if Item.Name == "PlaceHolder" then
            Item:Destroy()
        end
    end 

    for i, Item in pairs(Hotbar) do 
       
        -- Same item, and already exist. Ignore it.
        if AlreadyIn[i] and AlreadyIn[i].Info == Item then
            WeaponsInInputs[ InvInputs[i] ] = Item

            AlreadyIn[i].UI.Name = "NormalHT"

            continue 
        elseif  AlreadyIn[i] then

        
            InventoryHandler.HotbarGuis[AlreadyIn[i].UI] = nil
            
            -- Already exist, but, not the same item.
            AlreadyIn[i].UI:Destroy()
            -- Just Destroy it since ill make stuff on server, 
            -- and the backback will already be loaded from outside;
        end


        -- New Template;
        local NewTemplate = Template:Clone()
        NewTemplate.Parent = Template.Parent
        NewTemplate.Visible = true
        
        local FinalName = Item
        FinalName = string.split(FinalName, "/")
        FinalName = FinalName[1]

        local SpecialCategory = string.split(Item)
        SpecialCategory = SpecialCategory[4] or nil

        NewTemplate.Name = FinalName
        NewTemplate.TextLabel.Text = FinalName
        
        local TButton = Instance.new("TextButton")
        TButton.Parent = NewTemplate
        TButton.Size = UDim2.new(1,0,1,0)
        TButton.Transparency = 1

        TButton.Name = "DragButton"
        
        -- Start Drag Mode!
         TButton.MouseButton1Down:Connect(function(input)

            local Selected = nil
            local HasSelected = false
            Selected = TButton.MouseButton1Up:Connect(function()
                
                InventoryHandler.DirectSelected(NewTemplate, Item, NewTemplate:GetAttribute("HotbarSlotPos"))

                HasSelected = true 
                Selected:Disconnect()
            end)

            task.wait(.2)
            if HasSelected then
                return
            end
            Selected:Disconnect()

            InventoryHandler.DragMode(NewTemplate, Item, "FromHotbar")
        end)



        --[[
        TButton.MouseButton1Down:Connect(function()
            InventoryHandler.DragMode(NewTemplate, Item, "FromHotbar")
        end)
        --]]
          -- // Mouse Enter 
        TButton.MouseEnter:Connect(function(x, y)
            InventoryHandler.UI_Info(TButton, Item)
        end)



        table.insert(InventoryHandler.HotbarGuis, NewTemplate)

        -- Equip  the Weapon
       
        WeaponsInInputs[ InvInputs[i] ] = Item

        NewTemplate.LayoutOrder = i
        NewTemplate:SetAttribute("ItemInformation", Item)
        NewTemplate:SetAttribute("HotbarSlotPos", i)
        -- Add attribute so we can know, where in hotbar it is;

        -- so we know if is a Armor or anything like that
        if SpecialCategory then
            NewTemplate:SetAttribute("SpecialCategory", SpecialCategory )
        else
            NewTemplate:SetAttribute("SpecialCategory", nil )
        end

    end 
   
 
    -- Destroy all Item that don't exist;
    for TBName, child in pairs(AlreadyIn) do
        if not WeaponsInInputs[   InvInputs[TBName] ] then
            child.UI:Destroy()
        end
        -- some items that has "info" but  isn't there anymore.
        -- delete that.
    end

    local OnOrderList = {}
    -- Make Hotba depending on size
    if #Hotbar <= 9 then
        for _, Frame in pairs(InventoryUI:GetChildren()) do 
            if Frame:IsA("Frame") then
            else
                continue
            end

            if Frame:GetAttribute("HotbarSlotPos") then
                OnOrderList[Frame:GetAttribute("HotbarSlotPos")] = true
            end

        end 

        for i = 1,  9   do 

            if OnOrderList[i] then
                
            else
                local NewTemplate = Template:Clone()
                NewTemplate.Parent = Template.Parent
                NewTemplate.Visible = true
                NewTemplate.Name = "PlaceHolder"
                
                local TL = NewTemplate:FindFirstChildWhichIsA("TextLabel")
                TL.Text = ""

                NewTemplate.LayoutOrder = i
                NewTemplate:SetAttribute("HotbarSlotPos", i)

            end

        end        
    end
 

    -- Don't make new Connections if not needed;
    if not InventoryHandler.Connections.Equip then
        
    else
        InventoryHandler.Connections.Equip:Disconnect()
    end

    InventoryHandler.Connections.Equip =   game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end 

        if WeaponsInInputs[input.KeyCode] then
            local Hotbar = InvCL:FireServer({
                 Event = "EquipFromHotbar",
                 Item = WeaponsInInputs[input.KeyCode],
                 CalledHotbar =  Translated[input.KeyCode]
            })
        end

    end)
   
end

-- Backpack --
InventoryHandler.IsInDragMode = false
InventoryHandler.DragConnections = {}
InventoryHandler.DragGarbage = {}


-- add to armory
InventoryHandler.AddToArmory = function(OriginalFrame, Item, ToOccupy, FromArg)
        
    local InvCL = game.Players.LocalPlayer.Character:FindFirstChild("Inventory_Communication")  
    
    local Armory = InvCL:FireServer({
            Event = "AddToArmory",
            Item = Item,      
    })

    InvCL:FireServer({
        Event = "GetInventory",
    })

    
    InvCL:FireServer({
        Event = "GetArmory",
    })

    local ArmorType  = string.split(Item, "/")
    ArmorType = ArmorType[4]
   
    InventoryHandler.LastArmorEdited = ArmorType

   


end

-- Add to Hotbar;
InventoryHandler.AddToHotbar  = function(OriginalFrame, Item, ToOccupy, FromArg)

        local InvCL = game.Players.LocalPlayer.Character:FindFirstChild("Inventory_Communication")  

        local Pos = ToOccupy
        if Pos then
            Pos = ToOccupy:GetAttribute("HotbarSlotPos") or nil
        else
            return
        end


        local Hotbar = InvCL:FireServer({
            Event = "AddToHotbar",
            Item = Item,
            Pos = Pos or nil
         })
         
         --OriginalFrame:Destroy()
          
        local sucess, err = pcall(function()
            InventoryHandler.Connections.Equip:Disconnect()
        end)

        local Hotbar = InvCL:FireServer({
            Event = "GetHotbar",
            Item = Item
        })
            
        InvCL:FireServer({
            Event = "GetArmory",
        })  
            
        -- Get inventory 
        local InvBackpack = InvCL:FireServer({
            Event = "GetInventory",
        })
       -- InventoryHandler.CurrentlyBackpack = InvBackpack

end

-- Add to Backpack;
InventoryHandler.AddToBackpack = function(OriginalFrame, Item, ToOccupy)
    
    if ToOccupy then
        
    else
        
    end

    local InvCL = game.Players.LocalPlayer.Character:FindFirstChild("Inventory_Communication")  
            local Hotbar = InvCL:FireServer({
                Event = "AddToBackpack",
                Item = Item,
            })

            local sucess, err = pcall(function()
                InventoryHandler.Connections.Equip:Disconnect()
            end)
            local Hotbar = InvCL:FireServer({
                Event = "GetHotbar",
                Item = Item
             })
            
             --OriginalFrame:Destroy()

           
            
        -- Get inventory 
        local InvBackpack = InvCL:FireServer({
            Event = "GetInventory",
        })
        --InventoryHandler.CurrentlyBackpack = InvBackpack
        InvCL:FireServer({
            Event = "GetArmory",
        })

        BackpackUpdateSignal:Fire()

end


-- Drag End
InventoryHandler.DragEnd = function(OriginalFrame, Item, FromArg, MouseLastPos, FakeUI )

    local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack
    local HotbarFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Hotbar
    local ArmoryFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character

    local ItemST = string.split(Item, "/")
    local ItemCategory = ItemST[2]
    local ItemName = ItemST[1]

    local FramesList = {}
    -- add frames from Backpack and Hotbar, we will check who is closest.
    for _, Frame in pairs(HotbarFrame:GetChildren()) do 
        if Frame:IsA("Frame")  then else continue end 
    
        if Frame.Name ~= "ContentTemplate" then
            table.insert(FramesList, Frame)
        end
    end 

    local FrameFromCategory = BackpackFrame.MainBackpack.Contents:FindFirstChild(ItemCategory .. "Hold")
    for _, Frame in pairs(FrameFromCategory:GetChildren())  do 
        if Frame:IsA("Frame") or Frame:IsA("ImageLabel") then
            table.insert(FramesList, Frame)
        end
    end 

    for _, Frame in pairs(ArmoryFrame:GetChildren())  do 
        if Frame:IsA("Frame") or Frame:IsA("ImageLabel") then
            if InventoryHandler.BackpackBaseNames[Frame.Name] then
               table.insert(FramesList, Frame)                
            end
        end
    end 

    -- added the "hold frame" into the category

    ----- CHECK THE CLOSEST SLOT ---
    local Highest = nil

    -- Check if frame is inside the other frame.
    local function collidesWith(gui1, gui2)  
        local gui1_topLeft = gui1.AbsolutePosition
        local gui1_bottomRight = gui1_topLeft + gui1.AbsoluteSize

        local gui2_topLeft = gui2.AbsolutePosition
        local gui2_bottomRight = gui2_topLeft + gui2.AbsoluteSize

        return ((gui1_topLeft.x < gui2_bottomRight.x and gui1_bottomRight.x > gui2_topLeft.x) and (gui1_topLeft.y < gui2_bottomRight.y and gui1_bottomRight.y > gui2_topLeft.y))   --- return their values
    end

    local mouseLocation = game:GetService("UserInputService"):GetMouseLocation()
    for _, CurrentSlot in pairs(FramesList) do 

        if collidesWith(CurrentSlot, FakeUI) then
            
        else
            continue
        end 

        if not Highest then
            Highest = CurrentSlot
        end

        --CurrentSlot.AbsoluteSize/2
        local Magn1 = ( (CurrentSlot.AbsolutePosition + Vector2.new(0,50)  + CurrentSlot.AbsoluteSize/2 )   - MouseLastPos).Magnitude
        local Magn2 = ( (Highest.AbsolutePosition + Vector2.new(0,50) + Highest.AbsoluteSize/2   )   - MouseLastPos ).Magnitude

        if Magn1 < Magn2 then
            Highest = CurrentSlot
        end
    end 

   
    --[[
    local function MouseInFrame(uiobject)
        local mouse = MouseLastPos
        local Dir = (mouse - uiobject.AbsolutePosition).Unit 
        Dir = Dir * ( (uiobject.AbsoluteSize.X/2 + uiobject.AbsoluteSize.Y/2 )  )
        Dir = Dir 
        Dir = uiobject.AbsolutePosition + Dir
        
        local magn = (Dir - mouse).Magnitude
     
        if magn <= 53 and magn > 26 then
            return true
        else
            return false
        end

        return false
    end
   local IsHovering = MouseInFrame(Highest)
   --]]

   -- see Highest or if is Hovering
   if Highest  then

    -- Hotbar Frames;
      if Highest:IsDescendantOf(HotbarFrame)  then
        InventoryHandler.AddToHotbar(OriginalFrame, Item, Highest, FromArg)
        InventoryHandler.IsInDragMode = false
        InventoryHandler._EnableButtons()

        return
      end
    -- Backpack;
     if Highest:IsDescendantOf(BackpackFrame)  then
        InventoryHandler.AddToBackpack(OriginalFrame, Item, Highest)
        InventoryHandler.IsInDragMode = false
        InventoryHandler._EnableButtons()

        return
     end
     -- Armory 
     if Highest:IsDescendantOf(ArmoryFrame) then
        local SpecialCategory = string.split(Item, "/")
        if SpecialCategory[4] ~= nil then 

            if SpecialCategory[4] == Highest.Name then 
                 InventoryHandler.AddToArmory(OriginalFrame, Item, Highest)
                 InventoryHandler.IsInDragMode = false
                 return
            end 

           
            --InventoryHandler._EnableButtons()

            
        end
     end

   end

   local function Hovering(Frame)
        local MousePos = game:GetService("UserInputService"):GetMouseLocation() 
        local Guis = game.Players.LocalPlayer:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X, MousePos.Y)
        
        for _, Gui in Guis do
           
            if Gui:IsDescendantOf(Frame.Parent.Parent) then
                return true
            end
        end

        return false
    end

    if collidesWith(FakeUI,  FrameFromCategory)  then
        
        print(OriginalFrame.Parent)

        if OriginalFrame:IsDescendantOf(HotbarFrame) then 
            InventoryHandler.AddToBackpack(OriginalFrame, Item, Highest)

             InventoryHandler.IsInDragMode = false
            InventoryHandler._EnableButtons()
        elseif OriginalFrame:IsDescendantOf(ArmoryFrame) then
            
            InventoryHandler.AddToBackpack(OriginalFrame, Item, Highest)

            InventoryHandler.IsInDragMode = false
            InventoryHandler._EnableButtons()
        else 
            InventoryHandler.IsInDragMode = false
            InventoryHandler._EnableButtons()

        end 

        
        OriginalFrame.Visible = true
        OriginalFrame:FindFirstChildWhichIsA("TextLabel").Visible = true

    else
        InventoryHandler.IsInDragMode = false
        InventoryHandler._EnableButtons()

        InventoryHandler.DropItem(OriginalFrame, Item, Highest)

    end


end

-- Extra Action
InventoryHandler._EnableButtons = function(NewFrame, Item)
    
     
    local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack
    local HotbarFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Hotbar

    local CurrentsHotbar = {}
    for _, child in pairs(HotbarFrame:GetDescendants()) do 
        if child:IsA("TextLabel") then

              if child.Name == "DragButton" then
                child.Visible = true
            end

        end
    end 

    for _, child in pairs(BackpackFrame:GetDescendants()) do 
        if child:IsA("TextLabel") then
            if child.Name == "DragButton" then
                child.Visible = true
            end
         end
    end 

end

InventoryHandler._DisableButtons = function(NewFrame, Item)
    
    local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack
    local HotbarFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Hotbar

    local CurrentsHotbar = {}
    for _, child in pairs(HotbarFrame:GetDescendants()) do 
        if child:IsA("TextLabel") then
            if child.Name == "ContentTemplate" then continue end 

              if child.Name == "DragButton" then
                child.Visible = false
            end

        end
    end 

    for _, child in pairs(BackpackFrame:GetDescendants()) do 
        if child:IsA("TextLabel") then
            if child.Name == "DragButton" then
                child.Visible = false
            end
         end
    end 


end


-- Drag Mode
InventoryHandler.DragMode = function(OriginalFrame, item, FromArg, input)
   

    -- No Need to repeat. just wait the Drag to end;
    if InventoryHandler.IsInDragMode then
        return 
    end
   

    InventoryHandler._DisableButtons()

    local sucess, err = pcall(function()
        InventoryHandler.Connections.MouseUp:Disconnect()
    end)

    InventoryHandler.IsInDragMode = true

    local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack

    local UIHolding = BackpackFrame.DragTemplate

    InventoryHandler.DragGarbage.FakeUI = UIHolding:Clone()
    InventoryHandler.DragGarbage.FakeUI.Parent = BackpackFrame

    local FakeUI = InventoryHandler.DragGarbage.FakeUI
    FakeUI.Parent = BackpackFrame
    FakeUI.ZIndex = 400

    -- From Hotbar/ From Armory
    if FromArg == "FromHotbar" then
        OriginalFrame:FindFirstChildWhichIsA("TextLabel").Visible = false
    elseif FromArg == "FromArmory" then
        OriginalFrame:FindFirstChildWhichIsA("TextLabel").Visible = false
    else 
        OriginalFrame.Visible = false
    end

           
    local DragEvent = DraggableObj.new(FakeUI)

    local ItemText = OriginalFrame:FindFirstChildWhichIsA("TextLabel").Text

    local Info = string.split(OriginalFrame:GetAttribute("Item"), "/")
    local ItemName = Info[1]
    local ItemExtra = Info[4]


    if ItemsDesc.ArmorList.Armors[ItemName] then
       --print(ItemsDesc.ArmorList.Armors[ItemName][ItemExtra]["Name"])
       FakeUI.TextLabel.Text =   ItemsDesc.ArmorList.Armors[ItemName][ItemExtra]["Name"]
    end


    --FakeUI.TextLabel.Text = ItemText
    FakeUI.Visible = true
    FakeUI.ZIndex = 50

    FakeUI.AnchorPoint = Vector2.new(0,0)

    DragEvent:Enable(OriginalFrame, BasicMouseInp)

    local MagnFrom = (game:GetService("UserInputService"):GetMouseLocation() - FakeUI.AbsolutePosition).Magnitude
    local DistPos = (game:GetService("UserInputService"):GetMouseLocation() - FakeUI.AbsolutePosition).Unit
    
    local offsetX = OriginalFrame.AbsolutePosition.X
    local offsetY =  OriginalFrame.AbsolutePosition.Y

    local Mouse = game.Players.LocalPlayer:GetMouse()
    local RunService = game:GetService("RunService")

    
    InventoryHandler.Connections.MouseUp  = task.spawn(function()

        local HasPressed = false  
        repeat
            HasPressed = true
             local buttonsPressed = game:GetService("UserInputService"):GetMouseButtonsPressed()
             for _, button in buttonsPressed do
                 if button.UserInputType == Enum.UserInputType.MouseButton1 then
		    	    HasPressed = false 
		        end
            end 
            task.wait()
        until  HasPressed

        DragEvent:Disable()

        RunService:UnbindFromRenderStep("moveGuiToMouse")
        InventoryHandler.DragEnd(OriginalFrame, item, FromArg, FakeUI.AbsolutePosition, FakeUI)
        FakeUI:Destroy()

    end)

 
    local RunService = game:GetService("RunService")
    --RunService:BindToRenderStep("moveGuiToMouse", 1, function(DeltaTimer)
        ---UpdateUIPos(DeltaTimer)
    --end)



end

-- Load/ Open Backpack
InventoryHandler.LoadBackpack = function(PlrInventory)
    
   
     local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack

     local FrameContent = BackpackFrame.MainBackpack.Contents
     local ContentTemplate = FrameContent.ContentTemplate
    
     local AlreadyInBP = {}
     local UisByID = {}
     -- Get Frames that already has been loaded;
     for _, child in pairs(FrameContent:GetDescendants()) do 
        if child:IsA("Frame") or child:IsA("ImageLabel") then
            if child:GetAttribute("Item") then
                table.insert(AlreadyInBP,  child:GetAttribute("Item"))
                UisByID[child:GetAttribute("Item")] = child

                -- return the visibility of it.
                child.Visible = true 
            end
        end
     end 

     -- Read Plr Inventory
     for i, Item in pairs(PlrInventory) do
         
        -- no need to create a new one;
        if table.find(AlreadyInBP, Item) then
            local PosInTB = table.find(AlreadyInBP, Item)
            table.remove(AlreadyInBP, PosInTB)
            continue
        end

         local SeparatedInfo = string.split(Item, "/")

         local ItemName = SeparatedInfo[1]
         local ItemCategory  = SeparatedInfo[2]
         local SpecialCategory = SeparatedInfo[4] or nil
        
        if FrameContent:FindFirstChild(ItemCategory .. "Hold") then
            local CurrentContent = FrameContent:FindFirstChild(ItemCategory .. "Hold" )
            if CurrentContent:FindFirstChild(ItemName .. tostring(i)) then
                continue
            end
        end

         local NewFrame = ContentTemplate:Clone()
         NewFrame.Name =  ItemName .. tostring(i)
         NewFrame.Parent = FrameContent:FindFirstChild(ItemCategory .. "Hold" )
         NewFrame.Visible = true

         if SpecialCategory then 
            NewFrame:SetAttribute("SpecialCategory", SpecialCategory)
        else
            NewFrame:SetAttribute("SpecialCategory", nil)        
         end 
        
         -- Set ATB;
        NewFrame:SetAttribute("Item", Item)

        NewFrame.TextLabel.Text = ItemName 


        local Info = string.split(Item, "/")
        local ItemName = Info[1]
        local ItemExtra = Info[4]
        
        local sucess, err = pcall(function()
            NewFrame.TextLabel.Text = InventoryHandler.GetItemInformation(Item).Name
        end)


        local TButton = Instance.new("TextButton")
        TButton.Name = "DragButton"
        TButton.Parent = NewFrame
        TButton.Size = UDim2.new(1,0,1,0)
        TButton.Transparency = 1
        TButton.Text = ""

        -- Drag System;
        TButton.MouseButton1Down:Connect(function()

            local Selected = nil
            local HasSelected = false
            Selected = TButton.MouseButton1Up:Connect(function()
                
                InventoryHandler.DirectSelected(NewFrame, Item)

                HasSelected = true 
                Selected:Disconnect()
            end)
            
            local temporalyconnection = false 
         
            task.wait(.2)
            if HasSelected then
                return
            end
            Selected:Disconnect()

           
            InventoryHandler.DragMode(NewFrame, Item, BasicMouseInp)
        end)
       
        
        -- // Mouse Enter 
        TButton.MouseEnter:Connect(function(x, y)
            InventoryHandler.UI_Info(TButton, Item)
        end)


     end

     -- if still exist, it shouldn't be here;
     for _, Item in pairs(AlreadyInBP) do 
    
        UisByID[Item]:Destroy()
        -- delete since this shouldn't be in invetory,
        -- plr don't have this item in there anymore;
     end 


     -- Update UI 
     BackpackFrame.NumberInfo.Text = tostring(#PlrInventory) .. "/" .. "100"

end


InventoryHandler.Openbackpack = function(enable, InvCL, InvBackpack)


    local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack
    local ArmoryFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Character

    if enable then
        game.Players.LocalPlayer.Character:SetAttribute("InventoryMode", true)

    else

        game.Players.LocalPlayer.Character:SetAttribute("InventoryMode", nil)

        BackpackFrame.Visible = false
        ArmoryFrame.Visible = false
        -- Just so it cancels totally, in case of Drop gui.
        InventoryHandler.HasDropResponse = true 

        return
    end

    BackpackFrame.Visible = true
    ArmoryFrame.Visible = true

    InventoryHandler.LoadBackpack(InvBackpack)

    
end

-- Backpack Acess
InventoryHandler.InitbackpackAcess = function(InvCL, InvBackpack)
    
    local BackpackMenu = InputMovesHandler.Create("OpenInventory", Enum.KeyCode.Backquote, {"Began"}, 100, "Menu" )
    local IsEnabled  = false
    BackpackMenu:OnKeyActionReceive():Connect(function(Action)
        if IsEnabled then
            InventoryHandler.Openbackpack(false, InvCL,  InventoryHandler.CurrentlyBackpack)
            IsEnabled = false
        else
            InventoryHandler.Openbackpack(true, InvCL,  InventoryHandler.CurrentlyBackpack)
            IsEnabled = true
        end
    end)


end


-- Category;
InventoryHandler.InitOpenableCategory = function(InvCL, InvBackpack )
    
     local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack

     local FrameContent = BackpackFrame.MainBackpack.Contents
     local ContentTemplate = FrameContent.ContentTemplate

    local Categorys = {
        "Consumable",
        "Gear",
        "Item",
        "Skill"
    }

    for i, HoldTB in pairs(FrameContent:GetChildren()) do 

        if  table.find(Categorys, HoldTB.Name) then
            
            local TB = Instance.new("TextButton")
            TB.TextTransparency = 1
            TB.BackgroundTransparency = 1
            TB.Size = UDim2.new(1,0,1,0)
            TB.Parent = HoldTB
            TB.ZIndex = FrameContent.ZIndex + 1

            TB.MouseButton1Click:Connect(function()
                if HoldTB:GetAttribute("Open") == true then
                    local HoldFrame  = FrameContent:FindFirstChild(HoldTB.Name .. "Hold") 
                    HoldFrame.Visible = false
                    HoldTB:SetAttribute("Open", false)
                else
                    local HoldFrame  = FrameContent:FindFirstChild(HoldTB.Name .. "Hold") 
                    HoldFrame.Visible = true
                    HoldTB:SetAttribute("Open", true)
                end
            end)

            HoldTB:SetAttribute("Open", true)
            local HoldFrame  = FrameContent:FindFirstChild(HoldTB.Name .. "Hold") 
            HoldFrame.Visible = true
        end
      
    end 


    BackpackUpdateSignal:Connect(function()
        
    end)

end

-- Search Bar;
InventoryHandler.InitSearchBar = function(InvCL, InvBackpack)

    local BackpackFrame = game.Players.LocalPlayer.PlayerGui.InventoryUI.Backpack
    
    local SearchBar = BackpackFrame.SearchBar 

    local function Reset()
           for _, child in pairs(BackpackFrame.MainBackpack.Contents:GetDescendants()) do 
            if child:GetAttribute("Item") then
               child.Visible = true
            end
        end
    end

    local function Filter (Text)
        -- Check if we can actually search something in this.
        if typeof(Text) == "string" then    
        else
            Reset()
            return    
        end 
        if #Text > 1 then
            
        else
            Reset()
            return
        end

        -- Filter;
        for _, child in pairs(BackpackFrame.MainBackpack.Contents:GetDescendants()) do 
            if child:GetAttribute("Item") then
                local ItemName = string.split(child:GetAttribute("Item"), "/" )
                ItemName = ItemName[1]
                ItemName = string.lower(ItemName)
                local NB = string.find(ItemName, string.lower(Text) )
                if NB and NB == 1 then 
                    child.Visible = true
                else
                    child.Visible = false
                end 

            end
        end


    end

    SearchBar.FocusLost:Connect(function()
        Filter(SearchBar.Text)
    end )

    SearchBar.Focused:Connect(function()
        Filter(SearchBar.Text)
    end)

    SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
        Filter(SearchBar.Text)
    end)



end


InventoryHandler.LoadData = function()
    
end

-- Useful so we stay the Plr "Overall" Status update.
-- Overral status, its not the one that player spend points.
-- its the posture from armor + Stats, Mana from Helmet +  Stats, 
-- and the list goes on;
InventoryHandler.LoadTotalStatus = function(PlrData)
    
    local Status = PlrData.Status
    local Identity = PlrData.Identity


end


-- Total Status--
-- This will be the addiction of all Plr Status,
-- so for example if he equip a armor that give him "Posture", or anything like that,
-- this will be responsible to Init the HUD. But of course, who Load it is above;
InventoryHandler.InitTotalStatus = function()
    


    local Pages = {
        [1] = {
            Health = 100,
            Mana = 100,
            Posture = 100,
        },
        [2] = {
            Slash = 0,
            Blunt = 0,
            Elemental = 0,
            Poison = 0,
            Climate = 0,
        },
        [3] = {
            WeaponType = "None",
            
        }
    }
    InventoryHandler.TotalStatusInfo = Pages

    local PlayerGUI = game.Players.LocalPlayer.PlayerGui
    local PlrIcon = PlayerGUI:WaitForChild("InventoryUI").Character.PlayerIcon
    local ExtraStats = PlrIcon.ExtraStats

    local OptionsST = ExtraStats.OptionsStats
    local Stats = ExtraStats.Stats

    local DataManager = game.Players.LocalPlayer.Character:WaitForChild("Data_CL")
    
    DataManager.OnClientEvent:Connect(function(tab)
        if tab.Event == "GetData" then 
            InventoryHandler.LoadTotalStatus(tab.List)
        end 
    end)

    -- Pages;
    local Template_Option = OptionsST.TemplateOption
    local Template_Stat = Stats.StatsTemplate

    Template_Option.Visible = false
    Template_Stat.Visible = false 

    -- the list we need; --
    local function  UpdateTotalStatusList(List: {})
        
        -- Remove old Text Label;
        for _, OldT in pairs(Template_Stat.Parent:GetChildren()) do 
            if OldT:IsA("TextLabel") and OldT ~=  Template_Stat then
                OldT:Destroy()
            end 
        end 

        -- Load Everything from the List;
        for StatName, StatInfo in pairs(List) do 
            local NewSt = Template_Stat:Clone()
            NewSt.Text = StatName .. " : " .. StatInfo
            NewSt.Parent = Template_Stat.Parent
            NewSt.Visible = true
        end 

    end


    for TableName, Elements in pairs(Pages) do 
        local NewOpt = Template_Option:Clone()
        NewOpt.Name = TableName
        NewOpt.Text = TableName
        NewOpt.Parent = Template_Option.Parent
        NewOpt.Visible = true


        -- Choose Option --
        NewOpt.MouseButton1Click:Connect(function()
            UpdateTotalStatusList(Elements)    
        end)

    end 

    UpdateTotalStatusList(Pages[1])    


end


InventoryHandler.Init = function()
    
    local StarterGui = game:GetService("StarterGui")
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

    InventoryHandler.InitTotalStatus()

    local function LoadAll()
         local InvCL = game.Players.LocalPlayer.Character:WaitForChild("Inventory_Communication", 10)  

         local DataManager = game.Players.LocalPlayer.Character:WaitForChild("Data_CL")

        DataManager:FireServer({
            Event = "GetData"
         })

        local Hotbar = InvCL:FireServer({
            Event = "GetHotbar",
        })

        
        local InvBackpack = InvCL:FireServer({
                Event = "GetInventory",
        })

         local InvArmory = InvCL:FireServer({
                Event = "GetArmory",
        })
       
       
        local FirstLoad = true
        local FirstStatusLoad = true


        -- Receive Update from server;
        local InvCL = game.Players.LocalPlayer.Character:FindFirstChild("Inventory_Communication")  
        InvCL.OnClientEvent:Connect(function(tab)

            print(tab)

            if tab.Event == "GetInventory" then

                if FirstLoad then
                     FirstLoad = false
                     InventoryHandler.CurrentlyBackpack = tab.List
                     InventoryHandler.InitbackpackAcess( InventoryHandler.CurrentlyBackpack , tab.List)
                     InventoryHandler.LoadCurrentAvatar()
                end
               
                InventoryHandler.CurrentlyBackpack = tab.List
                InventoryHandler.LoadBackpack(tab.List, InvCL)

            elseif tab.Event == "GetHotbar"  then
                
                InventoryHandler.LoadHotbar(tab.List, InvCL)
            elseif  tab.Event == "GetArmory" then
                InventoryHandler.LoadArmory(tab.List, InvCL)
                InventoryHandler.LoadCurrentAvatar()
            end
        end)

        DataManager.OnClientEvent:Connect(function(tab)
            if tab.Event == "GetData" then 
                InventoryHandler.LoadStatus(tab.List)
            end 

            if FirstStatusLoad then
                FirstStatusLoad = false
                InventoryHandler.InitPointsHandler()
            end

        end)

        -- This will load the Inventory ^^^^^^
        InventoryHandler.InitSearchBar()
        InventoryHandler.InitOpenableCategory()


        game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
        GetTracks(game.Players.LocalPlayer.Character)

    end

    local HasLoaded = false 
    game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
       HasLoaded = true 
        LoadAll()
    end)
    task.wait()
    if not HasLoaded then 
        LoadAll()
    end 

end


return InventoryHandler