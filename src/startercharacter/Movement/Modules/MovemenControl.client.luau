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
local Run = InputMovesHandler.Create("Run", Enum.KeyCode.W, {"TwoEnded","TwoBegan"},  100, "Movement"  )
local DoubleJump = InputMovesHandler.Create("DoubleJump", Enum.KeyCode.Space, {"TwoEnded","TwoBegan"},  100, "Movement"  )
local Crouch = InputMovesHandler.Create("Crouch", Enum.KeyCode.Q, {"Began", "Ended"},  100, "Movement")

-- Input Actions -- 
Run:OnKeyActionReceive():Connect(function(Action)
    if Action == InputMovesHandler.States.TwoBegan then
       StatesHandler.StartRunning()
    elseif  Action == InputMovesHandler.States.TwoEnded then
       StatesHandler.StopRunning()
    end
end)

DoubleJump:OnKeyActionReceive():Connect(function(Action)
   if Action == InputMovesHandler.States.TwoBegan then
      StatesHandler.DoubleJump()
   end
end)
-- The Crouch can also be a Slide, it will depends if the Player 
-- Is Running During the action. -- 
Crouch:OnKeyActionReceive():Connect(function(Action)
   if Action == InputMovesHandler.States.Began then
      StatesHandler.UpdateState("Crouch")
   elseif Action == InputMovesHandler.States.Ended then
      StatesHandler.UpdateState("StopCrouch")
   end
end)

-- Reaction Actions -- 
-- Just to Initialize --
local ReactionBD = StatesPerform.SendSignal("Idle")

ReactionBD.Event:Connect(function(NewAction, Method)
   StatesHandler.UpdateState(NewAction, Method)
end)


-- Roblox Movement -- 
local OnHumanoidStateUpdate = Player.Character.Humanoid.StateChanged:Connect(function(old, new)
   -- the running for Roblox is Walk for us. lol
   if new == Enum.HumanoidStateType.Running then
      StatesHandler.UpdateState("Walk")
      return
   end
   -- we're falling.
   if new == Enum.HumanoidStateType.Freefall then
      StatesHandler.UpdateState("Falling")
      return
   end

   if new == Enum.HumanoidStateType.Jumping then 
      StatesHandler.UpdateState("Jump")
   end 

end)



-- Physics Stuff that will be Calculating nonstop. -- 
CharPhysics.Initialize()