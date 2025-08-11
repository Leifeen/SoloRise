
CameraModule = {}

local function ShakeCamera(shakeCf)
        -- shakeCf: CFrame value that represents the offset to apply for shake effect.
        -- Apply the effect:
        game.Workspace.CurrentCamera.CFrame = game.Workspace.CurrentCamera.CFrame * shakeCf
end

                              -- Create CameraShaker instance:
local renderPriority = Enum.RenderPriority.Camera.Value + 2
local CameraShaker = require(game:GetService("ReplicatedStorage").ExternalPackages.CameraShaker )

local camShakeEffect = CameraShaker.new(renderPriority, ShakeCamera)
camShakeEffect:Start()

CameraModule.Connections = {}

function CameraModule.FollowCameraTorso (AnimTrack, Offset  )

        if not Offset then
            Offset = 1
        end

        local sucess, err = pcall(function()
            task.cancel( CameraModule.Connections.RenderThread)
        end)
                 -- Disable the rendering.
        local sucess, err = pcall(function()
            game:GetService("RunService"):UnbindFromRenderStep("RenderToTorso")     
        end)
         
       

        CameraModule.Connections.RenderThread =  task.spawn(function()
                local Char = game.Players.LocalPlayer.Character
            
                game:GetService("RunService"):BindToRenderStep("RenderToTorso", Enum.RenderPriority.Camera.Value + 1, function()
                    local offset = Char:FindFirstChild("Torso").CFrame:ToObjectSpace(Char.HumanoidRootPart.CFrame).Position
                
                    local camOffset = Vector3.new(-offset.X , -offset.Y , -offset.Z )
                
                    local Anim =  game:GetService("TweenService"):Create(Char.Humanoid, TweenInfo.new(.055, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CameraOffset = camOffset * Offset })
                    Anim:Play()
                end)
                
                -------------------------------------
                --------- SHAKE CAMERA --------------
                -------------------------------------


                AnimTrack.Stopped:Wait()
                game:GetService("RunService"):UnbindFromRenderStep("RenderToTorso")
                local Anim =  game:GetService("TweenService"):Create(Char.Humanoid, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {CameraOffset =  Vector3.zero })
                Anim:Play()
        end)
end


return CameraModule