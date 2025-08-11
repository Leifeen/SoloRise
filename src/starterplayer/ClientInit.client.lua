


-- load all Item, Desc, Possible Stats and etc;
local GameItemsManager = require(game:GetService("ReplicatedStorage").Shared.GameItemsManager)
GameItemsManager.Init()

local EffectsReceiver = require(script.Parent.EffectsReceiver)
EffectsReceiver.Init()

local WeaponController = require(game:GetService("ReplicatedStorage").Shared.ClientControllers.WeaponController )
WeaponController.Init()

local PhysicalStatus = require(game:GetService("ReplicatedStorage").Shared.ClientControllers.PhysicalStatus )
PhysicalStatus.Init()

local VelocityManager = require(game:GetService("ReplicatedStorage").Shared.ClientUtility.VelocityManager )
VelocityManager.ClientInit()

--[[
local GetControllersInfo = require(game:GetService("ReplicatedStorage").Shared.ClientControllers.GetControllersInfo )
GetControllersInfo.Init(
    {
        WeaponController = WeaponController
    }
)
--]]

-- Init all Gui Handlers --
for _, child in pairs(script.Parent.GuiHandlers:GetChildren()) do 
    if child:IsA("ModuleScript") then else continue end 
    local GuiEvent = require(child)
    GuiEvent.Init()
end 