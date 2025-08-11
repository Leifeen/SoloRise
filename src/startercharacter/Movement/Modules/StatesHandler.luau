StatesHandler = {}

StatesHandler.CharPhysics = require( script.Parent.CharPhysics )
StatesHandler.StatePerform = require(script.Parent.StatesPerform)

StatesHandler.GetControllersInfo = require(game:GetService("ReplicatedStorage").Shared.ClientControllers.GetControllersInfo ) 
StatesHandler.ActionsConfig = require(game:GetService("ReplicatedStorage").Shared.MovAndActionConfigs.ActionsConfig  )

StatesHandler.LastState = "Idle"
StatesHandler.HoldingState = "None"
StatesHandler.LastUpdatedToServer = "None"


StatesHandler.SignalMethods = {
    ForceState = "ForceState", -- Sometimes i need to Force some states in 
    -- specific circustances. 

    ReturnState = "ReturnState" -- Sometimes i change States inside others state,
    -- so this script dont catch this type of change. so i make it to other scripts
    -- to send signal of the changes.
}
-- these states its better to verify first and not execute until 
-- we have sure we can do it.
StatesHandler.VerifyFirst = {
  "WallRun",
  "PoleMechanic",
  "DoubleJump",
  "Dash"
}
-- ^^  mostly reason is to prevent cancelling others states on going

-- HoldUp States -- 
StatesHandler.HoldupStatesUntil = {
    Running = {"StopRunning"},
    None = {"None"},
} -- these stats will maintain until a specific states get in. 


StatesHandler.CanForceState = {
    "Running",
    "Falling",
    "Landed",
    "PoleMechanic",
    "PoleJump",
    "WallClimb",
}
-- States and what variables can make them able to perform.
StatesHandler.StateMachine = {
    -- Custom Game States -- 
    Vault = {"Running", "Walk", "Idle", "Falling", "Jump", "DoubleJump", "WallClimb" },
    Running = {"Idle", "Walk", "StopRunning", "Vault",  "Landed", "Dash"},
    WallHang = {"WallClimb"},
    Dash = {"Idle", "Walk","StopRunning", "Landed", "Running", "JumpAirTime", "Falling", "Jump"  },

    JumpFromWallrun = {"OnWallRunAction"},
    WallRun = {"Running", "Walk", "Falling", "JumpAirTime" },
    OnWallRunAction = {"Falling", "WallRun", "Jump", "DoubleJump"},

    WallClimb = {"Jump", "Falling", "WallRun", "JumpAirTime" },
    DoubleJump = {"Jump", "Falling", "JumpAirTime" },
    WallClimbJump = {"WallClimb"},

    Crouch = {"Running", "Walk", "Idle",  "StopRunning"},
    Slide = {"Crouch"}, -- Crouch will receive the action but it will choose if want to 
    -- be a slide instead. Depend if the player is Running or not
    SlideJump = {"Slide"},

    StopRunning = {"Running", "Vault", "Dash" },
    StopCrouch = {"Crouch"},

    PoleMechanic = {"JumpFromWallrun", "Jump", "Falling", "JumpAirTime",  "DoubleJump", "Running","Walk" },
    PoleJump = {},

    -- Basic States -- 
    Jump = {"Idle", "Running", "Walk", "Dash" },
    JumpAirTime = {"Jump", "DoubleJump", "Dash", "WallClimb", "WallClimbJump", "PoleJump", "JumpFromWallrun", "SlideJump" },
    Falling = {"Idle", "Landed", "Running", "Walk", "Vault", "Dash"  },
    Walk = {"Idle", "StopRunning", "Landed","StopCrouch", "Dash" },
    Landed = {"Vault", "Jump", "DoubleJump", "WallHang", "Dash", "Slide", "SlideJump", "StopCrouch", "OnWallRunAction", "WallRun" },
    Idle = {"StopCrouch", "Running", "Walk", "Dash" }
}

-- this will cancel the State if the Player get stunned or something --
StatesHandler._InitCancelOut = function(Char)

    Char.AttributeChanged:Connect(function()
         local CanDoMovement = StatesHandler.CheckIfCanDoMovement(StatesHandler.LastState)
        if not CanDoMovement then
            StatesHandler.StatePerform._CancelAllMoves(Char)
            StatesHandler.LastState = "Idle"
            StatesHandler.SendToServer("Idle")
        end
    end)

    Char.Humanoid.Animator.AnimationPlayed:Connect(function()
         local CanDoMovement = StatesHandler.CheckIfCanDoMovement(StatesHandler.LastState)
        if not CanDoMovement then
            StatesHandler.StatePerform._CancelAllMoves(Char)
            StatesHandler.LastState = "Idle"
            StatesHandler.SendToServer("Idle")
        end
    end)

end

-- Cooldown Ones -- 
StatesHandler.CheckCDOne = function(State)
    
end



-- ill also have a server version of that of course.
StatesHandler.CheckIfCanDoMovement = function(State)

    if State then else return true end 

    -- Landed dont need.
    if State == "Landed" then
        return true
    end

    local WeaponMovement = StatesHandler.GetControllersInfo.GetCurrentPlrWeaponAction()
    if WeaponMovement then
       
        if true then
            return true
        end

        if WeaponMovement and WeaponMovement.Hierarchy >= 3 then
                -- prob some move called a specific state, just cancel it then.
            StatesHandler.StatePerform._CancelAllMoves() 
            return false  
        end   
    end

    -- Negative Status that the Movement will respect,
    -- EndLag, Stun, etc.
    local NegativeSTList = StatesHandler.ActionsConfig.GetNegativeStatus(game.Players.LocalPlayer.Character)
   
    if NegativeSTList then
        for _, TB in pairs(NegativeSTList) do 
            if not table.find(TB.Whitelist, State) then
                return false
            end
        end 
    end
    

    return true
end

StatesHandler.SendToServer = function(NewState)

    if StatesHandler.LastUpdatedToServer == NewState then
        return
    end
   --[[ The server will only via modules for fast process,
        while we can set attribute in local script too since only the player will see.
        i want to have good response in local script but also segurity, so everything,
        pretty much, is replicated equal. 

        if i get any differences, i verify on server and cancel.
    --]]

    game.Players.LocalPlayer.Character.CharActions:FireServer(
        {
            Event = "UpdateState",
            NewState = NewState
        }
    )
end

-- This will be the primary thing of everything. --
StatesHandler.UpdateState = function(State, Method)

    local CanDoMovement = StatesHandler.CheckIfCanDoMovement(State)
    if CanDoMovement then
    else
        return
    end


    -- Pick Char
    local Char = game.Players.LocalPlayer.Character


    -- Some Specific stuff --
    if Method and Method == StatesHandler.SignalMethods.ReturnState then 
        StatesHandler.SendToServer(State)
        StatesHandler.LastState = State
     
        return 
    end

    if Method and Method == StatesHandler.SignalMethods.ForceState then 
        if table.find(StatesHandler.CanForceState, State) then
            if StatesHandler.HoldupStatesUntil[StatesHandler.HoldingState] and table.find(StatesHandler.HoldupStatesUntil[StatesHandler.HoldingState], State) then 
                StatesHandler.HoldingState = "None" 
                return
            end 
            
            StatesHandler.StatePerform[State](StatesHandler.LastState, Char,  StatesHandler.HoldingState)
            StatesHandler.LastState = State
            StatesHandler.SendToServer(State)

        end
        return 
    end
    


    -- Main...
    -- these stats will Hold and changes some specific state to it. 
    -- for example, you don't go from freefalling to walk if we have running in it.
    if StatesHandler.HoldupStatesUntil[StatesHandler.HoldingState] and table.find(StatesHandler.HoldupStatesUntil[StatesHandler.HoldingState], State) then 
        StatesHandler.HoldingState = "None" 
    end 

    if table.find(StatesHandler.VerifyFirst, State) then
        -- i just sent "true" to mean i want to verify it.
        local Result = StatesHandler.StatePerform[State](true, Char)
        if Result then
     
        else
            return
        end
    end

    local HasPermission = StatesHandler._CheckIfCanDoState(State)
    if HasPermission then else return end         
    --print(State)
    --print(StatesHandler.LastState .. "Last State" )

    StatesHandler.StatePerform[State](StatesHandler.LastState, Char,  StatesHandler.HoldingState, StatesHandler.CheckIfCanDoMovement)
    --StatesHandler.SendToServer(State)

    -- States that i want to Hold, Like Running.
    if StatesHandler.HoldupStatesUntil[State] then 
        StatesHandler.HoldingState = State
    end 
    -- Now this is our Last State -- 
    StatesHandler.LastState = State
    game.Players.LocalPlayer.Character:SetAttribute("LocalState", State)
    StatesHandler.SendToServer(State)



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