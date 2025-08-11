
local EffectsFolder = game:GetService("ReplicatedStorage").Assets.Effects
local EffectsUtility = require(game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

local LoadedAnimTracks = {}

-- Camera Shaker
local CameraShaker = require(game:GetService("ReplicatedStorage").ExternalPackages.CameraShaker )

local camera = game.Workspace.CurrentCamera
local function ShakeCamera(shakeCf)
    -- shakeCf: CFrame value that represents the offset to apply for shake effect.
    -- Apply the effect:
    camera.CFrame = camera.CFrame * shakeCf
end
local renderPriority = Enum.RenderPriority.Camera.Value + 2
local camShakeEffect = CameraShaker.new(renderPriority, ShakeCamera)
camShakeEffect:Start()

local function LoadTrack (Char)
    if not LoadedAnimTracks[Char] then
        local Animator = Char.Humanoid.Animator
        LoadedAnimTracks[Char] = {}
        LoadedAnimTracks[Char].ClashLoop =  Animator:LoadAnimation(game.ReplicatedStorage.Animations.WeaponsAnimations.Katana.Clashing )
        LoadedAnimTracks[Char].ClashEnd =  Animator:LoadAnimation(game.ReplicatedStorage.Animations.WeaponsAnimations.Katana.ParriedStun )

        return LoadedAnimTracks[Char]
    end
    return LoadedAnimTracks[Char]
end

local Events = {
    ["ClashLoop"] = function(tab)

        local ShakeThread = task.spawn(function()
            while true do
                camShakeEffect:Shake(CameraShaker.Presets.Hitted)
                task.wait(.1)
            end
        end)


        local Killer = tab.Killer
        local Target = tab.Target

        local KillerTracks = LoadTrack(Killer)
        local TargetTracks = LoadTrack(Target)

        KillerTracks.ClashLoop:Play()
        TargetTracks.ClashLoop:Play()

        local ClashEF = game:GetService("ReplicatedStorage").Assets.Effects 
        ClashEF = ClashEF.Hit.ClashEffect
        ClashEF =  ClashEF:Clone()
        
        ClashEF.CFrame = Killer.HumanoidRootPart.CFrame +  (Killer.HumanoidRootPart.CFrame.LookVector * .3)
        ClashEF.Parent = game.Workspace
        ClashEF.Anchored = false
        ClashEF.CanQuery = false

        local NewWeld = Instance.new("Weld")
        NewWeld.Parent = ClashEF
        NewWeld.C0 = CFrame.new(0,0,5)
        
        NewWeld.Part0 = ClashEF
        NewWeld.Part1 = Killer.HumanoidRootPart

        EffectsUtility.EmitEffect(ClashEF.ClashHIT)
        EffectsUtility.EmitEffect(ClashEF.ClashLoop)

        ClashEF.Transparency = 1
        ClashEF.CanCollide = false

        task.wait(1.6)
        task.cancel(ShakeThread)

        for _, child in pairs(ClashEF:GetDescendants()) do 
            if child:IsA("ParticleEmitter") then 
                child.Enabled = false
            end 
        end 
        NewWeld:Destroy()

        ClashEF.Anchored = true

        EffectsUtility.EmitEffect(ClashEF.ClashFINISH)
        

    end,
    ["ClashEnd"] = function(tab)
           local Killer = tab.Killer
        local Target = tab.Target

        local KillerTracks = LoadTrack(Killer)
        local TargetTracks = LoadTrack(Target)

        --KillerTracks.ClashEnd:Play()
        --TargetTracks.ClashEnd:Play()
    end
}


return function (Player: nil, tab: {})

    if Events[tab.Event] then
        Events[tab.Event](tab)
    end

end 
