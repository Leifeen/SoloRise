
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

local ExtraEvents = {
    ["Slash"] = function(Target)
        
        task.wait(.2)

        local SprintStrikeVFX = game:GetService("ReplicatedStorage").Assets.WeaponsAsset.Katana
        SprintStrikeVFX = SprintStrikeVFX.Effects.SprintStrikeVFX

        SprintStrikeVFX =  SprintStrikeVFX:Clone()

        SprintStrikeVFX.CFrame = Target.HumanoidRootPart.CFrame
        SprintStrikeVFX.Parent = game.Workspace
        SprintStrikeVFX.Transparency = 1

        EffectsUtility.WeldInto(SprintStrikeVFX, Target.HumanoidRootPart, {
            C0 = CFrame.new(0,-1.5,1),
            C1 = CFrame.new(0,0,0)

        } )
        EffectsUtility.EmitEffect(SprintStrikeVFX, 1)

    end
}

return function (Plr: nil, tab: {} )
    
    if tab.Event then
        ExtraEvents[tab.Event](tab.Target)
    end

    task.wait(.2)
    local weapon = tab.Weapon 

    local GlowEF = weapon:FindFirstChildWhichIsA("MeshPart").AttachmentTOP.GLOW
    GlowEF:Emit(1)


end