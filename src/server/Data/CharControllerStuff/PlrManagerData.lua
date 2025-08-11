
PlrManagerData = {}


function  PlrManagerData:SpentPoints(Char, tab)
    
    local ServerDataCl = game.ServerScriptService.Server:WaitForChild("ServerDataCommunication")   

    local StatusList = ServerDataCl:Invoke("GetData")
    local PlrData =  ServerDataCl:Invoke({Event = "GetData"}, self.Player )
    
     local CanChange = {
        "Agility",
        "Strength",
        "Mana", 
        "Endurance", 
    }   

    if table.find(CanChange,tab.Atb ) then
        if PlrData.Status.StatPoints then
            local NB = tonumber(PlrData.Status.StatPoints)

            if NB > 0 then
                print("SPENT POINTS !")
                local NewData =  ServerDataCl:Invoke({
                    Event = "SpentPoints",
                    StatusAtb = tab.Atb
                }, self.Player )

                -- Return this data to Player
             Char:WaitForChild("Data_CL", 10):FireClient(self.Player,{
                Event = "GetData",
                List = NewData
            })       
            end

        end
    end


   return true
end

function PlrManagerData:GetData  (Char)
    

    local ServerDataCl = game.ServerScriptService.Server:WaitForChild("ServerDataCommunication")   

    local StatusList = ServerDataCl:Invoke("GetData")
    local PlrData =  ServerDataCl:Invoke({Event = "GetData"}, self.Player )
    
    -- Return this data to Player
    Char:WaitForChild("Data_CL", 10):FireClient(self.Player,{
        Event = "GetData",
        List = PlrData
    })

    return PlrData
end



function PlrManagerData:Init() 
    
    local function StartInto (Char)
           
        local sucess, err = pcall(function()
            self.Connections.OnDataPend:Disconnect()
        end)

        local Data_CL = Instance.new("RemoteEvent")
        Data_CL.Name = "Data_CL"
        Data_CL.Parent = Char

        local Methods = {
            ["GetData"] = function()
                return self:GetData(Char)
            end,

            ["SpentPoints"] = function(tab)
                return self:SpentPoints(Char, tab)
            end
        }
    
        self.Connections.OnDataPend =  Data_CL.OnServerEvent:Connect(function(Plr, tab)
            if Plr == self.Player then
            else
                return
            end

            if Methods[tab.Event] then
                Methods[tab.Event](tab)
            end
        end)

    end
 

    self.Player.CharacterAdded:Connect(function(Char)
        StartInto(Char)
    end)

    -- Just to make sure
    if self.CharModel and not self.CharModel:FindFirstChild("Data_CL") then
        StartInto(self.CharModel)
    end 



end

return PlrManagerData