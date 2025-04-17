local Player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInp = game:GetService("UserInputService")

local InputMovesHandler = require(game:GetService("ReplicatedStorage").Shared.gameplay.InputMovesHandler)
local StatesHandler = require(script.Parent.StatesHandler)
local StatesPerform = require(script.Parent.StatesPerform)
local MovementAnims = require(script.Parent.Parent.Parent.Animation.MovementsAnimationHandler )

local CharPhysics = require(script.Parent.CharPhysics)

-- Load Anims bc they cool -- 
MovementAnims.Initialize(Player.Character)

-- Controls -- 
local Run = InputMovesHandler.Create("Run", Enum.KeyCode.W, {"Began", "TwoEnded","TwoBegan"},  100, "Skill"  )

-- Input Actions -- 
Run:OnKeyActionReceive():Connect(function(Action)
    if Action == InputMovesHandler.States.TwoBegan then
       StatesHandler.StartRunning()
    elseif  Action == InputMovesHandler.States.TwoEnded then
       StatesHandler.StopRunning()
    end
end)


-- Reaction Actions -- 
-- Just to Initialize --
local ReactionBD = StatesPerform.SendSignal("Idle")

ReactionBD.Event:Connect(function(NewAction)
   StatesHandler.UpdateState(NewAction)
end)


-- Physics Stuff that will be Calculating nonstop. -- 
CharPhysics.Initialize()