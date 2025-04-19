

MovAnimHandler = {}
local CodeAssist = require(game:GetService("ReplicatedStorage").Shared.Utility.CodeAssist)
local FastAnimTrack = require(game:GetService("ReplicatedStorage").Shared.Utility.FastAnimTrack )

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
        WallClimbJump = FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallJump, FastAnimTrack.PrioritesType.Action4 ),
        WallHang =  FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallHang, FastAnimTrack.PrioritesType.Action3 ),
        WallHangClimb =  FastAnimTrack.LoadAnimIntoChar(Char, Char.CharAssets.Animations.WallHangClimb, FastAnimTrack.PrioritesType.Action4 )
   
    }

    MovAnimHandler.CurrentlyAnims = CodeAssist.DeepCopyTable(MovAnimHandler.BaseAnims)
    
    return MovAnimHandler.BaseAnims
end


MovAnimHandler.WallJump = function()
    MovAnimHandler.BaseAnims.WallClimbJump:Play()
end

MovAnimHandler.StopRunAction = function()
    MovAnimHandler.CurrentlyAnims.Running:Stop()
end

MovAnimHandler.RunAction = function()
    -- Dont play if is already playing.
    if MovAnimHandler.CurrentlyAnims.Running.IsPlaying then 
        return 
    end 
    MovAnimHandler.CurrentlyAnims.Running:Play()
end


MovAnimHandler.WallClimbAction = function()
    MovAnimHandler.CurrentlyAnims.WallClimb:Play()

    return  MovAnimHandler.CurrentlyAnims.WallClimb
end

MovAnimHandler.HangIdle = function()
    MovAnimHandler.CurrentlyAnims.WallHang:Play()
end

MovAnimHandler.HangClimb = function()
    MovAnimHandler.CurrentlyAnims.WallHang:Stop()
    MovAnimHandler.CurrentlyAnims.WallHangClimb:Play()
    return MovAnimHandler.CurrentlyAnims.WallHangClimb
end

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



return MovAnimHandler