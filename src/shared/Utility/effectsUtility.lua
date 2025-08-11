local effectsUtility = {}
local Debris = game:GetService("Debris")
local Assets = game:GetService("ReplicatedStorage").Assets
local TweenSV = game:GetService("TweenService")

effectsUtility.Threads = {} -- some Effects and Utility actions will use this. 
-- very usefull! 

effectsUtility.DBSV = game:GetService("Debris") -- so i can use this in other scripts, 
-- less variables for me 

effectsUtility.WeldInto = function(Part, ToWeld, Params)
    
    Part.Anchored = false

    local Configs = {
        C0 = Params.C0 or CFrame.new(),
        C1 = Params.C1 or CFrame.new()
    }
    local W = Instance.new("Weld")
    W.Part0 = ToWeld
    W.Part1 = Part
    W.Parent = Part

    W.C0 = Configs.C0
    W.C1 = Configs.C1

end

effectsUtility.SetupEffectPart = function(Part)
    Part.CanCollide = false
    Part.CanQuery = false
    Part.CanTouch = false
    Part.Massless = true
end

effectsUtility.EmitEffect = function(Part, DbTime)
    
    -- Get configs Function, very cool!
    local function GetConfigs (Particle)
        local Configuration = {
            EmitCount = Particle:GetAttribute("EmitCount") or 1,
            EmitDelay = Particle:GetAttribute("EmitDelay") or 0,
            DbTime = DbTime or 5
        }     

        return Configuration
    end

    -- we emit the particles.
    for _, Particle in pairs(Part:GetDescendants()) do 
        
        if Particle:IsA("PointLight") then
            local Anim = TweenSV:Create(Particle, TweenInfo.new(0.3), {Brightness = 0.2 }  )
            Anim:Play()
        end

        -- Check if it is a particle emitter
        if Particle:IsA("ParticleEmitter") then
            -- Create a Table, for thread and configs.
            effectsUtility.Threads[Particle] = {}
            effectsUtility.TBConfigs = {}
            -- Emit !
            effectsUtility.Threads[Particle].Emit = task.spawn(function()
                local Configs = GetConfigs(Particle)
                
                effectsUtility.TBConfigs.LastTime = os.time()
                if Configs.EmitDelay > 0 then
                    repeat task.wait()   
                    until effectsUtility.TBConfigs.LastTime - os.time() > Configs.EmitDelay
                end
   
                -- Lets Just Emit now 
                Particle:Emit(Configs.EmitCount)
                    
            end)
        end   
    end 

    local Configs = GetConfigs(Part)
    game:GetService("Debris"):AddItem(Part, Configs.DbTime)
   
end

effectsUtility.GetEffect = function(Folder, Name)
    return Assets.Effects:FindFirstChild(Folder):FindFirstChild(Name)
end


return effectsUtility