
local BloodEngine = require(game:GetService("ReplicatedStorage").ExternalPackages.BloodEngine ) 
BloodEngine =  BloodEngine.new({
                MaximumSize = 0.2,
                Trail = true,
                Type = "Decal",
                DefaultTransparency = {1,1},
                Limit = 500
            })

local HitAnimTracks = game:GetService("ReplicatedStorage").Assets.Animtracks.Hit
local EffectsFolder = game:GetService("ReplicatedStorage").Assets.Effects
local EffectsUtility = require(game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

-- Camera Shaker
local CameraShaker = require(game:GetService("ReplicatedStorage").ExternalPackages.CameraShaker )

local camera = game.Workspace.CurrentCamera
local function ShakeCamera(shakeCf)
    -- shakeCf: CFrame value that represents the offset to apply for shake effect.
    -- Apply the effect:
    camera.CFrame = camera.CFrame * shakeCf
end

    -- Create CameraShaker instance:
local renderPriority = Enum.RenderPriority.Camera.Value + 2
local camShakeEffect = CameraShaker.new(renderPriority, ShakeCamera)
camShakeEffect:Start()


local HitTypesEffects = {
    ["Blade"] = function(Target, KillerDir)
        
        local Hroot = Target.HumanoidRootPart 
        BloodEngine:EmitAmount(
            Target.HumanoidRootPart.Position, 
            Vector3.new(math.random(-5,5), math.random(-5,5), math.random(-5,5) ),
            10
        )

        local BloodHit = EffectsFolder.Hit.BloodHit:Clone()
        BloodHit.CFrame = Target.HumanoidRootPart.CFrame 
        BloodHit.CFrame = CFrame.new(BloodHit.Position, KillerDir ) * CFrame.Angles(0,0, math.rad(90) )
        BloodHit.Parent = game.Workspace
        BloodHit.Anchored = true

        EffectsUtility.EmitEffect(BloodHit, 2)

        local RandomVFX = math.random(1,4)
        local HITVFX  = game.ReplicatedStorage.Assets.SFX.Combat:FindFirstChild("Stab" .. tostring(RandomVFX))
        HITVFX =  HITVFX:Clone()
        HITVFX.Parent = BloodHit
        HITVFX:Play()
        

        local BloodHit = EffectsFolder.Hit.BloodHit:Clone()
        BloodHit.CFrame = Target.HumanoidRootPart.CFrame 
        BloodHit.CFrame = CFrame.new(BloodHit.Position, KillerDir ) * CFrame.Angles(0 ,math.rad(180), math.rad(90) )
        BloodHit.Parent = game.Workspace
        BloodHit.Anchored = true

        EffectsUtility.EmitEffect(BloodHit, 2)


    end,
    ["Normal"] = function(Target)
        
    end

}

local LoadedAnimTracks = {
    Hits = {}
}


return function (Plr: nil, tab: {} )

    
    local Target = tab.Target 
    local DamageType = tab.DamageType

    -- Shake Effect
    if Target == game.Players.LocalPlayer.Character then
        camShakeEffect:Shake(CameraShaker.Presets.Slash_Hit)
    elseif  tab.Killer == game.Players.LocalPlayer.Character then
        print("Slash HIt")
        camShakeEffect:Shake(CameraShaker.Presets.Slash_Hit)
    end

    if not LoadedAnimTracks.Hits[Target]  then
        LoadedAnimTracks.Hits[Target] = {} 
        for _, child in pairs(HitAnimTracks:GetChildren()) do 
            if child:IsA("Animation") then 
                LoadedAnimTracks.Hits[Target][child.Name] = Target.Humanoid.Animator:LoadAnimation(child)
            end 
        end 
    end

    local TargetTracks = LoadedAnimTracks.Hits[Target]
    local RandomChance = math.random(1, 3)

 -- Stop Desnecessary AnimTracks.
    for _, child in pairs(tab.Target.Humanoid.Animator:GetPlayingAnimationTracks()) do 
        if not child.Looped then
            child:Stop()            
        end
    end 

    
    TargetTracks["Hit" .. tostring(RandomChance)]:Play()

    HitTypesEffects[DamageType](tab.Target, tab.KillerDir)

   


end