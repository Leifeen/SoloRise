local KnockbackService = {}
local DbSV = game:GetService("Debris")
local VelocityManager = require(game:GetService("ReplicatedStorage").Shared.ClientUtility.VelocityManager )


function KnockbackService:_MakeTargetLook (Killer, Target)
    
    local AL = Instance.new("AlignOrientation")
    AL.Parent = Target.HumanoidRootPart
    local Attach1 = Instance.new("Attachment")
    local Attach2 = Instance.new("Attachment")

    Attach1.Parent = Killer.HumanoidRootPart
    Attach2.Parent = Target.HumanoidRootPart

    AL.Attachment0 = Attach2
    AL.Attachment1 = Attach1

    Attach2.CFrame = CFrame.Angles(0,math.rad(180),0)

    AL.MaxAngularVelocity = math.huge
    AL.Responsiveness = 200
    AL.Mode = Enum.OrientationAlignmentMode.TwoAttachment
    AL.PrimaryAxisOnly = true

    game:GetService("Debris"):AddItem(AL, .2)
    game:GetService("Debris"):AddItem(Attach2, .2)
    game:GetService("Debris"):AddItem(Attach1, .2)

end

function   KnockbackService:GetConfigs (Tab)
    local Configs = {
        DistanceKiller = Tab.DistanceKiller or 0;
        DistanceTarget = Tab.DistanceTarget or 0;

        Target = Tab.Target or nil;
        Killer = Tab.Killer or nil;
        GoTo = Tab.GoTo or Tab.Killer.HumanoidRootPart.CFrame.LookVector;

        TargetAnimTrack = Tab.TargetAnimTrack or "KnockbackHit";

        KnockbackType = Tab.KnockbackType or "Normal";
        SlamOnSurface = Tab.SlamOnSurface or false;
    }   

    return Configs
end

KnockbackService.Types = {

    ["ClashKnockback"] = function(Tab)
        local Configs =  Tab:GetConfigs(Tab)
    
        local TargetHroot = Configs.Target.HumanoidRootPart
        
        local LV = Instance.new("LinearVelocity")
        LV.Parent = TargetHroot
        LV.VectorVelocity = Configs.GoTo * Configs.DistanceTarget
        LV.MaxAxesForce = Vector3.new(50000,50000,50000)
        LV.ForceLimitMode = Enum.ForceLimitMode.PerAxis
        LV.ReactionForceEnabled = false
        LV.ForceLimitsEnabled = true

        local NewAttach = Instance.new("Attachment")
        NewAttach.Parent = TargetHroot
        
        LV.Attachment0 = NewAttach
        LV.RelativeTo = Enum.ActuatorRelativeTo.World
        
        TargetHroot.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

        VelocityManager.CallClients(LV)
        
    
        task.wait(.5)
        LV:Destroy()
        NewAttach:Destroy()
      
        TargetHroot.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)


    end,

    ["Normal"] = function(Tab)

        local Configs =  Tab:GetConfigs(Tab)
    
        local KillerHroot = Configs.Killer.HumanoidRootPart
        local TargetHroot = Configs.Target.HumanoidRootPart
        
        local LV = Instance.new("LinearVelocity")
        LV.Parent = TargetHroot
        LV.VectorVelocity = Configs.GoTo * Configs.DistanceTarget
        LV.MaxAxesForce = Vector3.new(math.huge,0,math.huge)
        LV.ForceLimitMode = Enum.ForceLimitMode.PerAxis
        LV.ReactionForceEnabled = true
        LV.ForceLimitsEnabled = true

        local NewAttach = Instance.new("Attachment")
        NewAttach.Parent = TargetHroot
        
        LV.Attachment0 = NewAttach
        LV.RelativeTo = Enum.ActuatorRelativeTo.World
        
        TargetHroot.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

        VelocityManager.CallClients(LV)
        
        KnockbackService:_MakeTargetLook(Configs.Killer, Configs.Target)

        task.wait(.2)
        LV:Destroy()
        NewAttach:Destroy()
      
        TargetHroot.Parent.Humanoid:ChangeState(Enum.HumanoidStateType.Landed)


        --KillerHroot.AssemblyLinearVelocity = Configs.GoTo * Configs.DistanceKiller
        --TargetHroot.AssemblyLinearVelocity = Configs.GoTo * Configs.DistanceTarget
      

    end,
    ["HardKnockback"] = function(Tab)
        
    end
}

function KnockbackService:ApplyKnockback ()
    
    self.Types[self.KnockbackType](self)

end 

KnockbackService.newKnockback = function(Tab: {} )

    local NewKnockback = {
        DistanceKiller = Tab.DistanceKiller or 0;
        DistanceTarget = Tab.DistanceTarget or 0;

        Target = Tab.Target or nil;
        Killer = Tab.Killer or nil;
        GoTo = Tab.GoTo or Tab.Killer.HumanoidRootPart.CFrame.LookVector;

        TargetAnimTrack = Tab.TargetAnimTrack or "KnockbackHit";

        KnockbackType = Tab.KnockbackType or "Normal";
        SlamOnSurface = Tab.SlamOnSurface or false;
    }
    setmetatable(NewKnockback, {__index = KnockbackService})

    return NewKnockback
    
end

KnockbackService.Clash = function(Killer, Target)
    
    local Garbages = {}

    local LV = Instance.new("AlignPosition")
    LV.Parent = Target.HumanoidRootPart
    local Attach1 = Instance.new("Attachment")
    local Attach2 = Instance.new("Attachment")

    Attach1.Parent = Killer.HumanoidRootPart
    Attach2.Parent = Target.HumanoidRootPart

    LV.MaxVelocity = math.huge
    LV.Responsiveness = 200
    LV.ForceLimitMode = Enum.ForceLimitMode.Magnitude
    LV.RigidityEnabled = false

    LV.ForceRelativeTo = Enum.ActuatorRelativeTo.Attachment1 
    
    Attach1.CFrame  = CFrame.new(0,0,-5)


    LV.Attachment0 = Attach2
    LV.Attachment1 = Attach1

    table.insert(Garbages, LV)
    table.insert(Garbages, Attach1)
    table.insert(Garbages, Attach2)

    local AL = Instance.new("AlignOrientation")
    AL.Parent = Target.HumanoidRootPart
    local Attach1 = Instance.new("Attachment")
    local Attach2 = Instance.new("Attachment")

    Attach1.Parent = Killer.HumanoidRootPart
    Attach2.Parent = Target.HumanoidRootPart

    AL.Attachment0 = Attach2
    AL.Attachment1 = Attach1

    Attach2.CFrame = CFrame.Angles(0,math.rad(180),0)

    AL.MaxAngularVelocity = math.huge
    AL.Responsiveness = 200
    AL.Mode = Enum.OrientationAlignmentMode.TwoAttachment
    AL.PrimaryAxisOnly = true


    table.insert(Garbages, AL)
    table.insert(Garbages, Attach1)
    table.insert(Garbages, Attach2)

    task.wait(1.63)
    

    for _, child in pairs(Garbages) do 
        child:Destroy()
    end 

    Target:SetAttribute("InClash", nil)
    Killer:SetAttribute("InClash", nil)


    local EF_Remote = game:GetService("ReplicatedStorage").EffectsRPL:FireAllClients(nil, "Clash",{
            Target = Killer,
            Killer = Target,
            Event = "ClashEnd",
    })


    local function Knockback (Killer, Target)
        local NewKnockback = KnockbackService.newKnockback({
            Target = Target,
            Killer = Killer,
            DistanceTarget = 50,
            KnockbackType = "ClashKnockback"

        })
        task.spawn(function()
            NewKnockback:ApplyKnockback()
        end)
    end
    -- Do Knockback for both.
    Knockback(Killer, Target)
    Knockback(Target, Killer)
    
end


return KnockbackService