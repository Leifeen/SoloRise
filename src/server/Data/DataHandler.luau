
local AvatarLoader = require( game:GetService("ReplicatedStorage").Shared.AvatarLoader.AvatarLoader )
local TeleportService = game:GetService("TeleportService")

DataHandler = {}

local DataStoreSV = game:GetService("DataStoreService")
local SlotStore = DataStoreSV:GetDataStore("SlotStore")
local UniqueData = DataStoreSV:GetDataStore("PlayerData")

DataHandler.Profiles = {}

DataHandler.GetData = function(Plr,  ChoosedData)
    
    local PlrSlot = SlotStore:GetAsync(Plr.UserId .. "_Slot_" .. tostring( ChoosedData ) )
    AvatarLoader.LoadFromData(PlrSlot, Plr)

    print(PlrSlot)
    DataHandler.Profiles[Plr.UserId] = PlrSlot 
end

DataHandler.SpentPoints = function(Plr, tab)

    local PlrData = DataHandler.Profiles[Plr.UserId]

    if tab.StatusAtb then
        
        PlrData.Status[tab.StatusAtb] = tonumber( PlrData.Status[tab.StatusAtb]) + 1
        PlrData.Status.StatPoints = tonumber(PlrData.Status.StatPoints) - 1

    end

    return PlrData


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

    ServerDataCL.OnInvoke = function(tab, Plr)
         if tab.Event == "GetData" then
            return DataHandler.Profiles[Plr.UserId]
        end 
        if tab.Event == "SpentPoints" then
            return DataHandler.SpentPoints(Plr, tab )
        end
    end


end


return DataHandler