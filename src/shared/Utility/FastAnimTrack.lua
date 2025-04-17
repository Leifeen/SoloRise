local FastAnimTrack = {}

FastAnimTrack.LoadedTracks = {}
-- So i can just use it for the scrips that load this module --
FastAnimTrack.PrioritesType = {
    Action = Enum.AnimationPriority.Action,
    Action2 = Enum.AnimationPriority.Action2,
    Action3 = Enum.AnimationPriority.Action3,
    Action4 = Enum.AnimationPriority.Action4,

    Movement = Enum.AnimationPriority.Movement,

    Idle = Enum.AnimationPriority.Idle,
    Core = Enum.AnimationPriority.Core
}

FastAnimTrack.LoadAnimIntoChar = function(Char, Animation, NewPriority )

    local Anim = Char.Humanoid.Animator:LoadAnimation(Animation)
    FastAnimTrack[Anim.Name] = Anim

    if NewPriority then
        Anim.Priority = NewPriority
    end

    return Anim
end




return FastAnimTrack