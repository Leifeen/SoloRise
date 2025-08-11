
local WeaponController = {}
WeaponController.WeaponsModule = {}

WeaponController.CurrentWeapon = nil

WeaponController.OnWeaponAdded = function()
    
    local Char = game.Players.LocalPlayer.Character

    Char.ChildAdded:Connect(function(child)
        if child:IsA("Tool")  then 
           local ItemID = child:GetAttribute("ItemID") 
           if ItemID then 


              if WeaponController.WeaponsModule[ItemID] then 
                 WeaponController.WeaponsModule[ItemID]:Equip()
                 WeaponController.CurrentWeapon = WeaponController.WeaponsModule[ItemID]

                local LastTool = child
                Char.ChildRemoved:Connect(function(NewP)
                    if NewP == LastTool then 
                        WeaponController.WeaponsModule[ItemID]:Unequip()
                        WeaponController.CurrentWeapon = nil
                    end 
                end)

              end
           end 
        end 
    end)

end



WeaponController.GetWeapon = function(WeaponName, ItemID)

    local WeaponsFolder = game.ReplicatedStorage.Shared.Weapons

     local function FindWeapon (WeaponName: string)
        local ChoosedWeapon = nil
        for _, Child in pairs(WeaponsFolder:GetDescendants()) do 
            if Child:IsA("ModuleScript") and Child.Name == WeaponName then 
                ChoosedWeapon = Child
                break
            end 
        end 

        return ChoosedWeapon
    end

    local NewWeapon = FindWeapon(WeaponName)

    if NewWeapon then 
        WeaponController.WeaponsModule[ItemID] = require(NewWeapon)
        WeaponController.WeaponsModule[ItemID].ItemID = ItemID
    end 

end

WeaponController.Init = function()
        
    local OnAdded = nil
    OnAdded =  game.Players.LocalPlayer.CharacterAdded:Connect(function()

        local  WeaponCommunication =  game.Players.LocalPlayer.Character:WaitForChild("WeaponCommunication", 500)

        local LoadedWeapon = nil
        LoadedWeapon = WeaponCommunication.OnClientEvent:Connect(function(Event: string, WeaponName: string , ItemID: string )
            if Event == "LoadWeaponMoveset" then 
                WeaponController.GetWeapon(WeaponName, ItemID)
            end  
        end)
        
        WeaponController.OnWeaponAdded()

    end)


end



return WeaponController
