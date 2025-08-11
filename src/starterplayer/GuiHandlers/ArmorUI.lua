ArmorUI = {}

ArmorUI.Connections = {}




ArmorUI.UpdateUI = function(CurrentHealth, MaxHealth, ArmorCategory, Animate)
    local StatusUI = game.Players.LocalPlayer.PlayerGui:WaitForChild("PlayerCombatStatusUI")

    ArmorUI.TextsBG = {


        ["Top"] = StatusUI.Chest.ArmorBar,

    }

    local CategoryFrame = ArmorUI.TextsBG[ArmorCategory]
    local MaxUISize = 0.737

    local CalcSize =  MaxUISize /  MaxHealth 
    CalcSize = CurrentHealth * CalcSize
    CalcSize = tonumber(CalcSize)

    if Animate then
        print("Updated")
             local NewSize = UDim2.new(0.2230,0,CalcSize,0)

        local Anim = game:GetService("TweenService"):Create(CategoryFrame, TweenInfo.new(0.1), {
            Size = NewSize
        } )
        Anim:Play()
        return
    end

    local NewSize = UDim2.new(0.2230,0,CalcSize,0)
    print(NewSize)
    CategoryFrame.Size = NewSize


end


ArmorUI.OnNewArmorAdded = function(ArmorModel)
    
    local ArmorFullName = "UpdateArmor" .. ArmorModel:GetAttribute("ArmorFixIn")

    local sucess ,err = pcall(function()
         ArmorUI.Connections[ArmorFullName].OnAttributeChange:Disconnect()
    end)
    ArmorUI.Connections[ArmorFullName] = {}

     ArmorUI.Connections[ArmorFullName].OnAttributeChange = ArmorModel.AttributeChanged:Connect(function(Arg)
        local NewHealth = ArmorModel:GetAttribute("ArmorHealth")
        local MaxHealth = ArmorModel:GetAttribute("MaxHealth")

        ArmorUI.UpdateUI(NewHealth, MaxHealth, ArmorModel:GetAttribute("ArmorFixIn"), true )

    end)

    -- First Update;
    local NewHealth = ArmorModel:GetAttribute("ArmorHealth")
    local MaxHealth = ArmorModel:GetAttribute("MaxHealth")
    ArmorUI.UpdateUI(NewHealth, MaxHealth, ArmorModel:GetAttribute("ArmorFixIn"), false )

end

ArmorUI.Init = function()

    local function ArmorAddConnection (character)

          local sucess, err = pcall(function()
            ArmorUI.Connections.OnArmorAdded:Disconnect()
        end)

        -- Now Update ui
        ArmorUI.Connections.OnArmorAdded = character.ChildAdded:Connect(function(Model)
            print(Model)
            if Model:GetAttribute("ArmorFixIn") then
                ArmorUI.OnNewArmorAdded(Model)
            end
        end)
    end

    game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
        ArmorAddConnection(character)
    end)

    -- Direct load;
    if not ArmorUI.Connections.OnArmorAdded then
        ArmorAddConnection(game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait())
    end

end

return ArmorUI
