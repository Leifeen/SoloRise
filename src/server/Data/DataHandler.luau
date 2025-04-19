
local AvatarLoader = require( game:GetService("ReplicatedStorage").Shared.AvatarLoader.AvatarLoader )
local TeleportService = game:GetService("TeleportService")

DataHandler = {}

local DataStoreSV = game:GetService("DataStoreService")
local SlotStore = DataStoreSV:GetDataStore("SlotStore")
local UniqueData = DataStoreSV:GetDataStore("PlayerData")

DataHandler.Profiles = {}

DataHandler.GetData = function(Plr,  ChoosedData)
    print(ChoosedData)
    local PlrSlot = SlotStore:GetAsync(Plr.UserId .. "_Slot_" .. tostring( ChoosedData ) )
    AvatarLoader.LoadFromData(PlrSlot, Plr)
end


DataHandler.Initialize = function()
    
    
	-- Data Communication
	local DataCommunication = Instance.new("RemoteFunction")
	DataCommunication.Parent = game.ReplicatedStorage
	DataCommunication.Name = "Data_Communication"
	
	local ServerDataCL = Instance.new("BindableFunction")
	ServerDataCL.Name = "ServerDataCommunication"
	ServerDataCL.Parent = script.Parent.Parent


    local OnPlayerAdded = game.Players.PlayerAdded:Connect(function(player)
        local OnCharAdd = nil
        OnCharAdd = player.CharacterAdded:Connect(function()
            local teleportData = TeleportService:GetLocalPlayerTeleportData(player) or 1
            
            if teleportData then
                DataHandler.GetData(player, teleportData)                
            end

            OnCharAdd:Disconnect()
        end)
    end)

    


end


return DataHandler