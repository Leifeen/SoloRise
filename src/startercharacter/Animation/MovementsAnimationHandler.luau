

MovAnimHandler = {}
MovAnimHandler.Threads = {}

local CodeAssist = require(game:GetService("ReplicatedStorage").Shared.Utility.CodeAssist)
local FastAnimTrack = require(game:GetService("ReplicatedStorage").Shared.Utility.FastAnimTrack )
local CameraModule = require(game:GetService("ReplicatedStorage").Shared.Utility.CameraModule )

MovAnimHandler.AnimateWeight = function(AnimTrack, CustomIncrease)
   

end

MovAnimHandler._StopAllAnimtracks = function()
    for _, Tracks in pairs(game.Players.LocalPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()) do 
        local Sucess, err =pcall(function()
            Tracks:Stop()
        end)
    end
end

MovAnimHandler.BaseAnims = {}

MovAnimHandler.CurrentlyAnims = {}

MovAnimHandler.Initialize = function(Char)
    
    if #MovAnimHandler.BaseAnims > 0 then
        return #MovAnimHandler.BaseAnims
    end

    MovAnimHandler.BaseAnims = {
        Vault1 = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.Vault1, FastAnimTrack.PrioritesType.Action4 ),
        Vault2 = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.Vault2, FastAnimTrack.PrioritesType.Action4 ),
        Running = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.Run, FastAnimTrack.PrioritesType.Movement ),
        WallClimb =  FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallClimb, FastAnimTrack.PrioritesType.Action3 ),
        WallClimbJump = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallClimbJump, FastAnimTrack.PrioritesType.Action4 ),
        WallHang =  FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallHang, FastAnimTrack.PrioritesType.Action3 ),
        WallHangClimb =  FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallHangClimb, FastAnimTrack.PrioritesType.Action4 ),
        
        DashFoward = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.DashFoward, FastAnimTrack.PrioritesType.Action3),
        DashBack = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.DashBackward, FastAnimTrack.PrioritesType.Action3),
        DashRight = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.DashRight, FastAnimTrack.PrioritesType.Action3),
        DashLeft = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.DashLeft, FastAnimTrack.PrioritesType.Action3),

        Slide = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.Slide, FastAnimTrack.PrioritesType.Action4),
        SlideJump = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.SlideJump, FastAnimTrack.PrioritesType.Action4),

        CrouchWalk = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.CrouchWalk, FastAnimTrack.PrioritesType.Action2),
        CrouchIdle = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.CrouchIdle, FastAnimTrack.PrioritesType.Movement),

        WallRunLeft = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallRunLeft, FastAnimTrack.PrioritesType.Action3),
        WallRunRight = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallRunRight, FastAnimTrack.PrioritesType.Action3),

        WallRunJumpRight =  FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallRunJumpRight, FastAnimTrack.PrioritesType.Action4),
        WallRunJumpLeft =  FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallRunJumpLeft, FastAnimTrack.PrioritesType.Action4),
        
        PoleGrab = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.PoleGrab, FastAnimTrack.PrioritesType.Action4),
        PoleSwingFollow = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.PoleSwingFollow, FastAnimTrack.PrioritesType.Action3),
        PoleSwing = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.PoleSwing, FastAnimTrack.PrioritesType.Action4),
        
        PoleIdle = FastAnimTrack.LoadAnimIntoChar(Char,Char.CharAssets.Animations.PoleIdle, FastAnimTrack.PrioritesType.Action ),
        
        PoleTurnL = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.PoleTurnL, FastAnimTrack.PrioritesType.Action2),
        PoleTurnR = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.PoleTurnR, FastAnimTrack.PrioritesType.Action2),

        FallAnim = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.Fall, FastAnimTrack.PrioritesType.Action2)
    }

    MovAnimHandler.CurrentlyAnims = CodeAssist.DeepCopyTable(MovAnimHandler.BaseAnims)
    
    return MovAnimHandler.BaseAnims
end


MovAnimHandler.Dash = function(Side)
    
    local Tracks = {
        ["Forward"] = function()
           MovAnimHandler.CurrentlyAnims.DashFoward:Play()
           return MovAnimHandler.CurrentlyAnims.DashFoward
        end,
        ["Backward"] = function()
            MovAnimHandler.CurrentlyAnims.DashBack:Play()
           return MovAnimHandler.CurrentlyAnims.DashFoward
        end,
        ["Right"] = function()
            MovAnimHandler.CurrentlyAnims.DashRight:Play()
           return MovAnimHandler.CurrentlyAnims.DashFoward
        end,
        ["Left"] = function()
            MovAnimHandler.CurrentlyAnims.DashLeft:Play()
           return MovAnimHandler.CurrentlyAnims.DashFoward
        end,
    }

    local PlrAnimator = game.Players.LocalPlayer.Character.Humanoid.Animator
    for _, Tracks in pairs(PlrAnimator:GetPlayingAnimationTracks()) do 
        if Tracks.Looped == false then
            Tracks:Stop(.2)
        end
    end 

    local Track = Tracks[Side]()
    CameraModule.FollowCameraTorso(Track)

end

MovAnimHandler.WallJump = function()
    MovAnimHandler.BaseAnims.WallClimbJump:Play()
end

MovAnimHandler.StopRunAction = function()
    MovAnimHandler.CurrentlyAnims.Running:Stop(.3)
end

-- Basic Anims 
MovAnimHandler.FallAnim = function(Enable)
    if Enable then
        if MovAnimHandler.CurrentlyAnims.FallAnim.IsPlaying then
            return
        end

         MovAnimHandler.CurrentlyAnims.FallAnim:Play(.5)
     else
        if MovAnimHandler.CurrentlyAnims.FallAnim.IsPlaying then
        else
            return
        end

         MovAnimHandler.CurrentlyAnims.FallAnim:Stop(.5)
    end
end

MovAnimHandler.RunAction = function()
    -- Dont play if is already playing.
    if MovAnimHandler.CurrentlyAnims.Running.IsPlaying then 
        return 
    end 
    MovAnimHandler.CurrentlyAnims.Running:Play(.5)
end


MovAnimHandler.WallClimbAction = function()
    MovAnimHandler.CurrentlyAnims.WallClimb:Play(.1)

    return  MovAnimHandler.CurrentlyAnims.WallClimb
end

-- Wall Run -- 
MovAnimHandler.WallRunAction = function(Dir)
    local PlayingAnim = nil
    if Dir >= 1 then
        MovAnimHandler.CurrentlyAnims.WallRunRight:Play()
        PlayingAnim = MovAnimHandler.CurrentlyAnims.WallRunRight
    else
        MovAnimHandler.CurrentlyAnims.WallRunLeft:Play()
        PlayingAnim = MovAnimHandler.CurrentlyAnims.WallRunLeft
    end
    return PlayingAnim
end
MovAnimHandler.JumpFromWallRun = function(Dir)

    
    MovAnimHandler._StopAllAnimtracks()

    if Dir >= 1 then
        MovAnimHandler.CurrentlyAnims.WallRunJumpRight:Play()
        MovAnimHandler.CurrentlyAnims.WallRunJumpRight:AdjustWeight(1)
        --MovAnimHandler.CurrentlyAnims.WallRunJumpRight:AdjustWeight(0.3,1)

    else
        MovAnimHandler.CurrentlyAnims.WallRunJumpLeft:Play()
        MovAnimHandler.CurrentlyAnims.WallRunJumpLeft:AdjustWeight(1)
        --MovAnimHandler.CurrentlyAnims.WallRunJumpLeft:AdjustWeight(0.3,1)


    end
end

MovAnimHandler.HangIdle = function()
    MovAnimHandler.CurrentlyAnims.WallHang:Play(.2)
end

MovAnimHandler.HangClimb = function()
    MovAnimHandler.CurrentlyAnims.WallHang:Stop(.2)
    MovAnimHandler.CurrentlyAnims.WallHangClimb:Play(.1)
    return MovAnimHandler.CurrentlyAnims.WallHangClimb
end

-- Slide -- 
MovAnimHandler.SlideAction = function()
    MovAnimHandler.CurrentlyAnims.Slide:Play()
   
    return MovAnimHandler.CurrentlyAnims.Slide
end
MovAnimHandler.SlideJump = function()
    MovAnimHandler.CurrentlyAnims.SlideJump:Play()
    MovAnimHandler.CurrentlyAnims.SlideJump:AdjustWeight(2, 0)
    task.spawn(function()
        task.wait(.3)
        if MovAnimHandler.CurrentlyAnims.SlideJump.IsPlaying then else return end 
        MovAnimHandler.CurrentlyAnims.SlideJump:AdjustWeight(1, .2)
    end)

    return MovAnimHandler.CurrentlyAnims.SlideJump
end


-- CROUCH --
MovAnimHandler.StopCrouchAction = function()
    MovAnimHandler.CurrentlyAnims.CrouchWalk:Stop()
    MovAnimHandler.CurrentlyAnims.CrouchIdle:Stop()
end

MovAnimHandler.UpdateCrouchTrackPos = function()
    MovAnimHandler.CurrentlyAnims.LastCrouchTrackPos =  MovAnimHandler.CurrentlyAnims.CrouchWalk.TimePosition 
end

MovAnimHandler.CrouchWalk = function()
    if not MovAnimHandler.CurrentlyAnims.CrouchWalk.IsPlaying  then
        if MovAnimHandler.LastCrouchTrackPos then
            MovAnimHandler.CurrentlyAnims.CrouchWalk.TimePosition = MovAnimHandler.LastCrouchTrackPos
        end

        MovAnimHandler.CurrentlyAnims.CrouchWalk:Play(.2)

    end 
end

MovAnimHandler.CrouchIdle = function()
    if not MovAnimHandler.CurrentlyAnims.CrouchIdle.IsPlaying  then
        MovAnimHandler.CurrentlyAnims.CrouchIdle:Play(.2)
    end

    if MovAnimHandler.CurrentlyAnims.CrouchWalk.IsPlaying then
        MovAnimHandler.CurrentlyAnims.CrouchWalk:Stop(.5)
    end

end
---------------

MovAnimHandler.VaultAction = function()
    
    if MovAnimHandler.CurrentlyAnims.Vault1.IsPlaying or MovAnimHandler.CurrentlyAnims.Vault2.IsPlaying  then 
        return 
    end 

    if not MovAnimHandler.LastVault then 
        MovAnimHandler.LastVault = 1 
    end

    local ToST = "Vault" .. tostring(MovAnimHandler.LastVault)
    MovAnimHandler.CurrentlyAnims[ToST]:Play()

    if MovAnimHandler.LastVault <= 1 then 
        MovAnimHandler.LastVault += 1 
    else 
        MovAnimHandler.LastVault = 1
    end 

end

-- Pole Actions -- 
MovAnimHandler.EnablePoleIdle = function(Val)
    if Val == true then
        MovAnimHandler.CurrentlyAnims.PoleIdle:Play()
    else
        MovAnimHandler.CurrentlyAnims.PoleIdle:Stop()
    end
end


MovAnimHandler.PoleLastJump = function()
    MovAnimHandler.CurrentlyAnims.PoleIdle:Stop()
    MovAnimHandler.CurrentlyAnims.PoleSwingFollow:Stop()
    MovAnimHandler.CurrentlyAnims.PoleGrab:Stop()

    MovAnimHandler.CurrentlyAnims.PoleSwing:Play()
    MovAnimHandler.CurrentlyAnims.PoleSwing:AdjustSpeed(1)
    MovAnimHandler.CurrentlyAnims.PoleSwing.TimePosition = 1.5

    return   MovAnimHandler.CurrentlyAnims.PoleSwing
end

MovAnimHandler.PoleGrab = function(TimePos, TransitionTime)


    MovAnimHandler.CurrentlyAnims.PoleGrab:Play(TransitionTime)
    MovAnimHandler.CurrentlyAnims.PoleGrab:AdjustWeight(1.5,1)
    --MovAnimHandler.AnimateWeight(MovAnimHandler.CurrentlyAnims.PoleGrab, 0.5)


    if TimePos ~= nil then
        --MovAnimHandler.CurrentlyAnims.PoleGrab.TimePosition = TimePos
    end

end

MovAnimHandler.PoleFollow = function()
    MovAnimHandler.CurrentlyAnims.PoleGrab:Stop()
   -- MovAnimHandler.CurrentlyAnims.PoleGrab:AdjustWeight(0.3)


    MovAnimHandler.CurrentlyAnims.PoleSwingFollow:Play()
    MovAnimHandler.CurrentlyAnims.PoleSwingFollow:AdjustSpeed(1.3)
 
    --MovAnimHandler.CurrentlyAnims.PoleSwingFollow:AdjustWeight(0.3, 0.2)

    return MovAnimHandler.CurrentlyAnims.PoleSwingFollow
end


MovAnimHandler.PoleTurn = function(Dir)
    if Dir >= 1 then
        MovAnimHandler.CurrentlyAnims.PoleTurnR:Play(.2)

    else
        MovAnimHandler.CurrentlyAnims.PoleTurnL:Play(.2)

    end
end

return MovAnimHandler