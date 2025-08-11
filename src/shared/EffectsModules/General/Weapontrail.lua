
local LastTrailThreads = {}

return function (Plr:  nil, tab: {} )
    
    local weapon = tab.Weapon 

    if LastTrailThreads[tab.Weapon] then
        local sucess, err = pcall(function()
             task.cancel(LastTrailThreads[tab.Weapon])            
        end)
    end

    
    LastTrailThreads[tab.Weapon] = task.spawn(function()
        for _, child in pairs(weapon:GetDescendants()) do 
            if child:IsA("Trail") then
                child.Enabled = true 
            end
        end 
        task.wait(1)
          for _, child in pairs(weapon:GetDescendants()) do 
            if child:IsA("Trail") then
                child.Enabled = false 
            end
        end 
        LastTrailThreads[tab.Weapon] = nil
    end)


end 