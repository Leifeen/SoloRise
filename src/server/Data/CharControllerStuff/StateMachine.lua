
StateMachine  = {}
local AttributeHandler = require(game:GetService("ServerScriptService").Server.Modules.AttributeHandler)

StateMachine.CharStates = {}

-- Will use this state so i can verify more easier, 
-- what type of states ill avoid in some actions;

StateMachine.Lists = {

    MovementStates = {
        "Vault",
        "Running",
        "Walk",
        "Idle",
        "Falling",
        "Jump",
        "DoubleJump",
        "WallClimb",
        "WallHang",
        "JumpFromWallrun",
        "OnWallRunAction",
        "WallRun",
        "WallClimbJump",
        "Crouch",
        "StopRunning",
        "Slide",
        "SlideJump",
        "StopCrouch",
        "PoleMechanic",
        "PoleJump",
        "JumpAirTime",
        "Landed",
    },

    ParkourStates = {
        "Vault",
        "WallClimb",
        "WallHang",
        "JumpFromWallrun",
        "OnWallRunAction",
        "WallRun",
        "WallClimbJump",
        "Crouch",
        "Slide",
        "SlideJump",
        "PoleMechanic",
        "PoleJump",
    
    }

}

local Cooldowns = {}

local SpecialMovementsInteraction = {
    ["Dash"] = function(Player, Char)
        AttributeHandler.AddAttribute(Char, "DodgeWindow", true, 0.2 )
        
        if Cooldowns["Dash"] then
            -- if somehow we get in there, we cancel the Dash.
            -- since locally also take the time.
            if game.Workspace:GetServerTimeNow() - Cooldowns["Dash"] < 2 then
                    Char.CharActions:FireClient(Player, {
                    Event = "DashResponse",
                    Enable = false
                     } )
                     return
            end 

            
        end

        local TimeNow = game.Workspace:GetServerTimeNow()
        Cooldowns["Dash"] = TimeNow

         local EF_Remote = game:GetService("ReplicatedStorage").UI_Update:FireClient(Player,  "WarnCD",{
            CurrentlyTime =  game.Workspace:GetServerTimeNow(),
            MaxTime = 2,
            SkillName = "Dash",
        })


        Char.CharActions:FireClient(Player, {
            Event = "DashResponse",
            Enable = true,
            CurrentTime = TimeNow,
            FinalTime = 2
        } )

    end
}

function StateMachine:SpecialState (Event, Plr,  Char )
   
    if SpecialMovementsInteraction[Event] then
        SpecialMovementsInteraction[Event](Plr, Char)
    end
   

end


function StateMachine:HasStateInList (ListMentioned)
    local PlrState = self:GetState()

    if table.find(self.Lists[ListMentioned], PlrState ) then 
        return true 
    end 

end

function StateMachine:GetState() 
    return self.CharStates[self.Player.UserId].CurrentState
end

function StateMachine:UpdateNewState (tab)
    
     self.CharStates[self.Player.UserId].CurrentState = tab.NewState



end

function StateMachine:Init ()

    self.CharStates[self.Player.UserId] = {}

    self.OnSignalReceive:Connect(function(tab)
        if tab.Event ~= "UpdateState" then
            return
        end

        self:UpdateNewState(tab)

    end)

    --self:SpecialState()

    local OnCharAdded = self.Player.CharacterAdded:Connect(function(Char)
        self.CharStates[self.Player.UserId].Character = Char
         self.CharStates[self.Player.UserId].CurrentState = "Idle"
    end)
    table.insert(self.Connections, OnCharAdded)

    

end

return StateMachine
