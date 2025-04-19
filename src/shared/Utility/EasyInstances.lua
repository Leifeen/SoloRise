
EasyInstances = {}
EasyInstances.Debris = game:GetService("Debris")

EasyInstances.DestroyWDebris = function(Int, TimerTo)
    EasyInstances.Debris:AddItem(Int, TimerTo)
end

EasyInstances.CreateAlignOrient = function(Char)
        
    local AO = Instance.new("AlignOrientation")
    AO.Parent = Char.HumanoidRootPart
    AO.Name = "ForceOrient"

    local NewAttach = Instance.new("Attachment")
    NewAttach.Parent = Char.HumanoidRootPart
    
    local NewAttach2 = Instance.new("Attachment")
    NewAttach2.Parent = Char.HumanoidRootPart
    

    AO.Attachment0 = NewAttach
    AO.Attachment1 = NewAttach2

    return AO, NewAttach, NewAttach2

end

EasyInstances.CreateAlignPosIntoChar = function(Char)
      
    local AL = Instance.new("AlignPosition")
    AL.Parent = Char.HumanoidRootPart
    AL.Name = "ForceAL"
    
    local NewAttach = Instance.new("Attachment")
    NewAttach.Parent = Char.HumanoidRootPart
    
    local NewAttach2 = Instance.new("Attachment")
    NewAttach2.Parent = Char.HumanoidRootPart
    

    AL.Attachment0 = NewAttach
    AL.Attachment1 = NewAttach2

    return AL, NewAttach, NewAttach2
end

EasyInstances.CreateLinearIntoChar = function(Char)
    
    local LV = Instance.new("LinearVelocity")
    LV.Parent = Char.HumanoidRootPart
    LV.Name = "ForceL"
    
    local NewAttach = Instance.new("Attachment")
    NewAttach.Parent = Char.HumanoidRootPart
    
    local NewAttach2 = Instance.new("Attachment")
    NewAttach2.Parent = Char.HumanoidRootPart
    

    LV.Attachment0 = NewAttach
    LV.Attachment1 = NewAttach2

    return LV, NewAttach, NewAttach2

end



return EasyInstances