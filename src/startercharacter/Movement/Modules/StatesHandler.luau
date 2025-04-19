StatesHandler = {}

StatesHandler.CharPhysics = require( script.Parent.CharPhysics )
StatesHandler.StatePerform = require(script.Parent.StatesPerform)

StatesHandler.LastState = "Idle"
StatesHandler.HoldingState = "None"

StatesHandler.SignalMethods = {
    Return = "Return" -- this signal is to cancel states from updating to another.
    -- like, if we go to free fall and is very close to ground, we just dont do it and 
    -- return to the last state. 
}


-- HoldUp States -- 
StatesHandler.HoldupStatesUntil = {
    Running = {"StopRunning"},
    None = {"None"},
} -- these stats will maintain until a specific states get in. 

-- States and what variables can make them able to perform.
StatesHandler.StateMachine = {
    -- Custom Game States -- 
    Vault = {"Running", "Walk", "Idle", "Falling", "Jump", "DoubleJump"},
    Running = {"Idle", "Walk", "StopRunning", "Vault", "Falling", "Landed"},
    StopRunning = {"Running", "Vault"},
    WallHang = {"WallClimb"},
    WallClimb = {"Jump"},
    DoubleJump = {"Jump", "Falling", "JumpAirTime" },

    
    -- Basic States -- 
    Jump = {"Idle", "Running", "Walk" },
    JumpAirTime = {"Jump", "DoubleJump", "WallClimb"},
    Falling = {"Idle",   "StopRunning", "Running", "Landed", "JumpAirTime" },
    Walk = {"Idle", "StopRunning", "Landed"},
    Landed = {"Falling", "Vault", "Jump", "DoubleJump", "JumpAirTime", "WallHang" }
}

-- This will be the primary thing of everything. --
StatesHandler.UpdateState = function(State, Method)

    if Method and Method == StatesHandler.SignalMethods.Return then 
        StatesHandler.LastState = State
        local Char = game.Players.LocalPlayer.Character
        StatesHandler.StatePerform[State](StatesHandler.LastState, Char,  StatesHandler.HoldingState)
        
        -- these stats will Hold and changes some specific state to it. 
        -- for example, you don't go from freefalling to walk if we have running in it.
        if StatesHandler.HoldupStatesUntil[State] and table.find(StatesHandler.HoldupStatesUntil[State], State) then 
            StatesHandler.HoldingState = "None" 
        end 

        return 
    end
  
    -- these stats will Hold and changes some specific state to it. 
    -- for example, you don't go from freefalling to walk if we have running in it.
    if StatesHandler.HoldupStatesUntil[StatesHandler.HoldingState] and table.find(StatesHandler.HoldupStatesUntil[StatesHandler.HoldingState], State) then 
        StatesHandler.HoldingState = "None" 
    end 

    print(State)
    print(StatesHandler.LastState)

    local HasPermission = StatesHandler._CheckIfCanDoState(State)
    if HasPermission then else return end         
    local Char = game.Players.LocalPlayer.Character
    StatesHandler.StatePerform[State](StatesHandler.LastState, Char,  StatesHandler.HoldingState)
    

    -- States that i want to Hold, Like Running.
    if StatesHandler.HoldupStatesUntil[State] then 
        StatesHandler.HoldingState = State
    end 
    -- Now this is our Last State -- 
    StatesHandler.LastState = State

    

end

-- Check if we can do State -- 
StatesHandler._CheckIfCanDoState = function(State)
    if StatesHandler.StateMachine[State] then
        if table.find(StatesHandler.StateMachine[State], StatesHandler.LastState) or StatesHandler.LastState == nil then
            return true 
        else
            return false
        end
    end
end

-- Some State callout -- 
-- Dont do much difference between the UpdateState(StateName),
-- just for read. basically
StatesHandler.StartRunning = function()
    StatesHandler.UpdateState("Running")
end
StatesHandler.StopRunning = function()
    StatesHandler.UpdateState("StopRunning")
end

StatesHandler.DoubleJump = function()
    StatesHandler.UpdateState("DoubleJump")
end

return StatesHandler