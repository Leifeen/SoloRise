StatesHandler = {}
StatesHandler.MovementCheck = require( script.Parent.MovementCheck )
StatesHandler.CharPhysics = require( script.Parent.CharPhysics )
StatesHandler.StatePerform = require(script.Parent.StatesPerform)

StatesHandler.LastState = "Idle"

-- States and what variables can make them able to perform.
StatesHandler.StateMachine = {
    -- Custom Game States -- 
    Vault = {"Running", "Walk", "Idle"},
    Running = {"Idle", "Walk", "StopRunning", "Vault"},
    StopRunning = {"Running"},

    -- Basic States -- 
    Jump = {"Idle", "Running"},
    DoubleJump = {"Jump"},
    Falling = {"Idle", "Running", "Jump", "StopRunning"},
    Walk = {"Idle", "Running"}
}

-- This will be the primary thing of everything. --
StatesHandler.UpdateState = function(State)
    local HasPermission = StatesHandler._CheckIfCanDoState(State)
    if HasPermission then else return end         
    
    -- Now this is our Last State -- 
    StatesHandler.LastState = State

    local Char = game.Players.LocalPlayer.Character
    StatesHandler.StatePerform[State](StatesHandler.LastState, Char)

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

-- Some State callout
StatesHandler.StartRunning = function()
    StatesHandler.UpdateState("Running")
end
StatesHandler.StopRunning = function()
    StatesHandler.UpdateState("StopRunning")
end

return StatesHandler