

local EffectsFolder = game:GetService("ReplicatedStorage").Assets.Effects
local EffectsUtility = require(game:GetService("ReplicatedStorage").Shared.Utility.effectsUtility )

local WeaponsAnimtracks = game:GetService("ReplicatedStorage").Animations.WeaponsAnimations
local TweenSV = game:GetService("TweenService")

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







local LoadedAnimTracks = {
    Hits = {}
}

local function  BrightEF ()
    local CL = Instance.new("ColorCorrectionEffect")
    CL.Parent = game.Lighting
    CL.Brightness = 0
    CL.Contrast = 0.9
    CL.Saturation  = 1

    local Anim = TweenSV:Create(CL, TweenInfo.new(0.3), {
        Brightness = 0,
        Contrast = 0,
        Saturation = 0
    }

    )
    Anim:Play()

    game:GetService("Debris"):AddItem(CL, 0.4)

end

return function (Plr: nil, tab: {} )

        local Target = tab.Target 
        local KillerDir = tab.KillerDir
    
          -- Shake Effect
        if Target == game.Players.LocalPlayer.Character then
            camShakeEffect:Shake(CameraShaker.Presets.BrokeGuard)
        elseif  tab.NewKiller == game.Players.LocalPlayer.Character then
            camShakeEffect:Shake(CameraShaker.Presets.Slash_Hit)
            BrightEF()
         end


        local BlockHit = EffectsFolder.Hit.Parried:Clone()
        BlockHit.Position = ( tab.NewKiller.HumanoidRootPart.Position + ((Target.HumanoidRootPart.Position - KillerDir ).Unit * 1.5)  ) + Vector3.new(0,-1.5,0)

        BlockHit.Parent = game.Workspace
        
      
        EffectsUtility.EmitEffect(BlockHit, 4)
        

        local ParriedVFX  = game.ReplicatedStorage.Assets.SFX.Combat.parried
        ParriedVFX =  ParriedVFX:Clone()
        ParriedVFX.Parent = BlockHit
        ParriedVFX:Play()
        
        -- Stop Desnecessary AnimTracks.
        for _, child in pairs(tab.Target.Humanoid.Animator:GetPlayingAnimationTracks()) do 
                if not child.Looped then
                child:Stop()            
                end
        end 

    -- later ill make it seek for the weapon specific animation, since the  weapon class 
    -- will add a attribute "Weapon equipped" later; for this type of info.
    if not LoadedAnimTracks.Hits[Target]  then
        LoadedAnimTracks.Hits[Target] = {} 
        LoadedAnimTracks.Hits[Target]["Katana"] =  WeaponsAnimtracks.Katana.ParriedStun
        LoadedAnimTracks.Hits[Target]["Katana"] = Target.Humanoid.Animator:LoadAnimation( LoadedAnimTracks.Hits[Target]["Katana"])
    end

     LoadedAnimTracks.Hits[Target]["Katana"]:Play()
    -- play the track 


end
