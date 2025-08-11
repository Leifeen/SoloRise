
local EffectsFolder = game:GetService("ReplicatedStorage").Assets.Effects
local EffectsUtility = require(game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

local WeaponsAnimtracks = game:GetService("ReplicatedStorage").Assets.Animtracks.Extra

local LoadedAnimTracks = {
    Hits = {}
}

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



return function (Player: nil, tab)
    

        local Target = tab.Target 
        local KillerDir = tab.KillerDir
    
        -- Shake Effect
        if Target == game.Players.LocalPlayer.Character then
            camShakeEffect:Shake(CameraShaker.Presets.BrokeGuard)
         end


        local Blockbroken = EffectsFolder.Hit.BlockBroken:Clone()
        Blockbroken.Position = ( Target.HumanoidRootPart.Position + ((Target.HumanoidRootPart.Position - KillerDir ).Unit * -2)  ) + Vector3.new(0,-1.5,0)

        Blockbroken.Parent = game.Workspace
        Blockbroken.Anchored = true

        EffectsUtility.EmitEffect(Blockbroken, 2)

        
        local HITVFX  = game.ReplicatedStorage.Assets.SFX.Combat:FindFirstChild("BlockBroken")
        HITVFX =  HITVFX:Clone()
        HITVFX.Parent = Blockbroken
        HITVFX:Play()

   -- later ill make it seek for the weapon specific animation, since the  weapon class 
    -- will add a attribute "Weapon equipped" later; for this type of info.
    if not LoadedAnimTracks.Hits[Target]  then
        LoadedAnimTracks.Hits[Target] = {} 
        LoadedAnimTracks.Hits[Target]["BlockBroken"] =  WeaponsAnimtracks.PostureBroken
        LoadedAnimTracks.Hits[Target]["BlockBroken"] = Target.Humanoid.Animator:LoadAnimation( LoadedAnimTracks.Hits[Target]["BlockBroken"])
    end

     LoadedAnimTracks.Hits[Target]["BlockBroken"]:Play()
    -- play the track 


end