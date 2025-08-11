
local CooldownsUI = {}
CooldownsUI.Thread = {}

local TweenSV = game:GetService("TweenService")

CooldownsUI.AddToCooldownList = function(tab)
    
    local LastTime = tab.CurrentlyTime
    local MaxTime = tab.MaxTime 
    local SkillName = tab.SkillName

    local GUI = game.Players.LocalPlayer.PlayerGui
    local CooldownInfo = GUI.TemporalyCooldownInfo

    CooldownsUI.Thread[SkillName .. "CD"] = task.spawn(function()

        local FrameTEMP = CooldownInfo.CooldownBase:Clone()
        FrameTEMP.Name = "CD"
        FrameTEMP.Parent = CooldownInfo.BaseFrame
        FrameTEMP.CooldownName.Text = SkillName
        FrameTEMP.Visible = true

        local Bar = FrameTEMP.Bar 
        local FillBar = Bar.FillBar

        repeat
            local FillCompare =  1 / MaxTime 
            local ToReach = game.Workspace:GetServerTimeNow() - LastTime  
            ToReach = ToReach * FillCompare

            local Anim = TweenSV:Create(FillBar, TweenInfo.new(0.1),{
                Size = UDim2.new(ToReach,0,1,0 )
            } )
            Anim:Play()

            task.wait()
        until game.Workspace:GetServerTimeNow() - LastTime > MaxTime 

        FrameTEMP:Destroy()
    end)

end

CooldownsUI.Init = function()
   local EffectsRPL = game.ReplicatedStorage:WaitForChild("UI_Update")
   EffectsRPL.OnClientEvent:Connect(function(Event, tab)
        if Event == "WarnCD" then
             CooldownsUI.AddToCooldownList(tab)
        end
    end)

end

return CooldownsUI