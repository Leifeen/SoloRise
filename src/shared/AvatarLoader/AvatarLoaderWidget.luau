
AvatarLoaderWidget = {}
local CodeAssist = require(game:GetService("ReplicatedStorage").Shared.Utility.CodeAssist)
local GMPlayers = game.Players
local AvatarEditor = game:GetService("ReplicatedStorage").AvatarEditor
local AvatarPresets = require(script.Parent.AvatarPresets)

AvatarLoaderWidget._CreateTag = function(FolderFrom, NewItem)
    local NewTag = Instance.new("StringValue")
    NewTag.Name = "TAG"
    NewTag.Value = FolderFrom.Name

    NewTag.Parent = NewItem
end


AvatarLoaderWidget.LoadSkinTone = function(BaseRig, PlayerSlotData, Plr, HDescript)
    	-- BodyColor 
	local BodyColor = PlayerSlotData.Colors.SkinColor or 1
	BodyColor = AvatarPresets.SkinColor[BodyColor]
    HDescript.RightArmColor = BodyColor
	HDescript.LeftArmColor = BodyColor
	HDescript.HeadColor = BodyColor
	HDescript.TorsoColor = BodyColor
	HDescript.RightLegColor = BodyColor
	HDescript.LeftLegColor = BodyColor

end

AvatarLoaderWidget.LoadBodyType = function(BaseRig, PlayerSlotData)
    
    -- Set the size first 
    local Gender = PlayerSlotData.Identity.Gender
	local RigSize = AvatarPresets.GenderBodyTypes[Gender]
	
    -- Get all Motor6D so we can change
	local TranslatedMotor6D = {
		["Right Leg"] = "Left Hip",
		["Left Leg"] = "Right Hip",
		["Left Arm"] = "Left Shoulder",
		["Right Arm"] = "Right Shoulder",
	}

    -- Change the Shirt/Pants 
	BaseRig:FindFirstChildWhichIsA("Pants").PantsTemplate = AvatarPresets.GenderBodyTypes[Gender].Pants
	BaseRig:FindFirstChildWhichIsA("Shirt").ShirtTemplate = AvatarPresets.GenderBodyTypes[Gender].Shirt

    -- Do the Motor6d Modifications
	for _, child in pairs(BaseRig:GetChildren()) do
		
		if child:IsA("BasePart") then else continue end 
		
		if RigSize[child.Name] then
			local OldSize = child.Size
			child.Size = RigSize[child.Name]
			
			local Difference = (OldSize - child.Size)
			
			--print(Difference.X)
			
			if TranslatedMotor6D[child.Name] then
		    	local Motor6D = BaseRig.Torso:FindFirstChild(TranslatedMotor6D[child.Name])
				
				if Motor6D.C0.Position.X < 0.1 then
					Motor6D.C0 = Motor6D.C0 + Vector3.new(Difference.X ,0,0)
				else
					Motor6D.C0 = Motor6D.C0 + Vector3.new(-Difference.X ,0,0)
				end
				
				
			end
			
			
		end
	end
	
    -- Finally do the Player Waist prefference.
    local HasWaist = PlayerSlotData.Identity.Waist
    if HasWaist then
        local GTorso = game:GetService("ReplicatedStorage").AvatarEditor.Girltorso:Clone()
        GTorso.Parent = BaseRig
    end




end


AvatarLoaderWidget.AddClothingInto = function(BaseRig, ChoosedCloth)
    
end

AvatarLoaderWidget.LoadHair = function(BaseRig, PlayerSlotData, Plr, CurrentDesc)
    
    local HD = GMPlayers:GetHumanoidDescriptionFromUserId(Plr.UserId)
    CurrentDesc.HairAccessory = HD.HairAccessory
    

end

AvatarLoaderWidget.LoadFace = function(BaseRig, PlayerSlotData, Plr)
    
    local NoseF = AvatarEditor.Face.Nose
    local EyeF = AvatarEditor.Face.Eye
    local MouthF = AvatarEditor.Face.Mouth
    local Mark = AvatarEditor.Face.Mark

    local OrdenedDecals = {NoseF, EyeF, MouthF, Mark}
    for _, FaceFolder in pairs(OrdenedDecals) do 
        if FaceFolder:FindFirstChild( tostring ( PlayerSlotData.Appareance[FaceFolder.Name] ) ) then
            local NewDecalFolder = FaceFolder:FindFirstChild( tostring( PlayerSlotData.Appareance[FaceFolder.Name] ) )
            
            for _, Decal in pairs(NewDecalFolder:GetDescendants()) do
                if Decal:IsA("Decal") then
                    local NewDEC = Decal:Clone()
                    NewDEC.Parent = BaseRig.FakeHead     

                    AvatarLoaderWidget._CreateTag(FaceFolder, NewDEC)
                    
                end 
            end 
        end
    end 

    


end

AvatarLoaderWidget.SetColor = function(BaseRig, PlayerSlotData, Plr)
    for _, AcessorItem in pairs(BaseRig:GetDescendants()) do 

        if AcessorItem:FindFirstChild("TAG") then
            else
            continue
        end

        -- check if it exist --
        if PlayerSlotData.Colors[AcessorItem.TAG.Value .. "Color" ] then
            local ColorToSet = CodeAssist.GetRGBFromString(PlayerSlotData.Colors[AcessorItem.TAG.Value .. "Color" ])
            
            if AcessorItem:IsA("Decal") then
                if AcessorItem:FindFirstChild("CantChange") then
                     continue
                end
                AcessorItem.Color3 = ColorToSet                
            end

        end

    end 

-- Remove All Hairs Texture
for _, child in pairs(BaseRig:GetDescendants()) do
    if child:IsA("Accessory") then
        for _, child in pairs(child:GetDescendants()) do
            if child:IsA("SpecialMesh") then
                child.TextureId = ""
                
                -- SET THE HAIR COLOR --
                child.Parent.Color = CodeAssist.GetRGBFromString( PlayerSlotData.Colors.HairColor )
                
            end
        end
    end
end




end


return AvatarLoaderWidget