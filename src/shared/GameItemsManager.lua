local GameItemManager = {}

local ArmorList = require(script.Parent.Item.ArmorList)
local ConsumableList = require(script.Parent.Item.Consumablelist)

local DescriptionCreator = require(game:GetService("ReplicatedStorage").Shared.Utility.DescriptionCreator  )

GameItemManager.Init = function()

    local function  LoadAll(List)
        for ItemName, ItemContent in pairs(List) do 
            DescriptionCreator:Create(ItemName,  ItemContent.Desc)
        end 
    end
    LoadAll(ConsumableList.Consumables)
    LoadAll(ArmorList.Armors)

  

    
end

return GameItemManager