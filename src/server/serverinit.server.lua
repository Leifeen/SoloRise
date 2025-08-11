
local CharacterController = require(game:GetService("ServerScriptService").Server.Data.CharacterController)
CharacterController.Init()


-- init the remotes ye
local ServerRemotesHandler = require(script.Parent.Modules.ServerRemotesHandler)
ServerRemotesHandler.Init()

local DamageController = require(game:GetService("ServerScriptService").Server.Modules.DamageController)
DamageController.Init()

local VelocityManager = require(game:GetService("ReplicatedStorage").Shared.ClientUtility.VelocityManager )
VelocityManager.ServerInit()

local DropItemHandler = require(script.Parent.Modules.DropItem)
DropItemHandler.Init()