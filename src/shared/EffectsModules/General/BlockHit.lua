
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




return function (Player: nil, tab: {})
        
        local Target = tab.Target 
        local KillerDir = tab.KillerDir

         -- Shake Effect
        if Target == game.Players.LocalPlayer.Character then
            camShakeEffect:Shake(CameraShaker.Presets.Slash)
         end

        local BlockHit = EffectsFolder.Hit.BlockHit:Clone()
        BlockHit.Position = ( Target.HumanoidRootPart.Position + ((Target.HumanoidRootPart.Position - KillerDir ).Unit * -2)  ) + Vector3.new(0,-1.5,0)

        BlockHit.Parent = game.Workspace
        BlockHit.Anchored = true

        local RandomSFX = math.random(1,3)
        local HITVFX  = game.ReplicatedStorage.Assets.SFX.Combat:FindFirstChild("block" .. tostring(RandomSFX))
        HITVFX =  HITVFX:Clone()
        HITVFX.Parent = BlockHit
        HITVFX:Play()


        EffectsUtility.EmitEffect(BlockHit, 4)


        

end