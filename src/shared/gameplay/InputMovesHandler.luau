local InputMoves = {}

InputMoves.States = {
    -- classic ones  -- 
    Began = "Began",
    Ended = "Ended",

    -- Custom -- 
    TwoBegan = "TwoBegan", -- after 2 clicks we send this as a signal. 
    TwoEnded = "TwoEnded" -- same, but for ended

}

InputMoves.CreatedMoves = {}
InputMoves.SkillSignals = {}

local Signal = require(game.ReplicatedStorage.Shared.Utility.GoodSignal)  
-- get bindable for signals --
InputMoves.GetBindable = function()
    if not game:GetService("ReplicatedStorage"):FindFirstChild("InputSignal") then
       local BD = Instance.new("BindableEvent")
       BD.Parent = game:GetService("ReplicatedStorage")
       BD.Name = "InputSignal"
       return BD
    else
        return game.ReplicatedStorage.InputSignal
    end
end

-- create the Input that the Player will use, whatever it is. --
InputMoves.Create = function(SkillName, Input,  ReceiveSignalWhen, LastTick, MoveTag)

    local InpSignal = InputMoves.GetBindable()
    
    if Input then
    else
        error("You need a Input to make a input move.")
    end

    local NewMove = {
        Input = Input,
        SkillName =  SkillName or "TestSkill",
        BindableEvent = InpSignal,
        LastTick = LastTick or os.time(),
        Enabled = true,
        MoveTag = MoveTag or "Skill",
        Connections = {}, 
        
        ActionWhen = ReceiveSignalWhen or {"Began", "Ended"}
    }
    table.insert(InputMoves.CreatedMoves, NewMove)

    setmetatable(NewMove, {__index =  InputMoves} ) 
   
    NewMove:InitializeKey ()
   
    return NewMove
end

-- simple function for whatever action we Need. --
InputMoves.IsHoldingKey = function(Input)
    if game:GetService("UserInputService"):IsKeyDown(Input) then
            return true
        else
            return false
    end
end

-- initialize the Events --
function  InputMoves:InitializeKey ()
    if table.find(self.ActionWhen,  InputMoves.States.Began) then
        self:OnInputBegan()
    end
    if table.find(self.ActionWhen, InputMoves.States.Ended) then
        self:OnInputEnded()
    end
    if table.find(self.ActionWhen,  InputMoves.States.TwoBegan) then
        self:OnTwoBegan()
    end
    if table.find(self.ActionWhen,  InputMoves.States.TwoEnded) then
        self:OnTwoEnded()
    end
end



    
function InputMoves:DestroyMove ()
    for _, child in pairs(self.Connections) do 
        local sucess, err = pcall(function()
            child:Disconnect()
        end)
        
        local sucess, err = pcall(function()
            table.clear(self)
            self = nil    
        end)
    end 
end

-- wait --
function  InputMoves:WaitForPressEnded ()
    repeat
    until not game:GetService("UserInputService"):IsKeyDown(self.Input)
end

function InputMoves:OnKeyActionReceive ()
    local OnActionSignal = Signal.new()
    self.Connections.BDEvent = self.BindableEvent.Event:Connect(function(SkillName, Event )
         if SkillName == self.SkillName then
            OnActionSignal:Fire(Event)
         end
    end)

    InputMoves.SkillSignals[self.SkillName] = OnActionSignal
    self.Connections.SignalReceive = OnActionSignal

    return OnActionSignal
end

-- Custom Ones -- 
function InputMoves:OnTwoBegan ()
    self.Connections.TwoBegan =  game:GetService("UserInputService").InputBegan:Connect(function(EventInput, InChat)
        if EventInput.KeyCode == self.Input and self.Enabled then
           
            if not self.LastBegan then 
                self.LastBegan = os.time()
                self.BeganCount = 1
            end
            
            if os.time()  - self.LastBegan  < 0.5 then
                self.BeganCount += 1

                if self.BeganCount >= 2 then 
                    self.BindableEvent:Fire(self.SkillName,  InputMoves.States.TwoBegan)            
                end
            
                self.LastBegan = os.time()
            else 
                self.BeganCount = 1 
                self.LastBegan = os.time()
            end
        end
    end)
end 

function InputMoves:OnTwoEnded ()
    self.Connections.TwoEnded = game:GetService("UserInputService").InputEnded:Connect(function(EventInput, InChat)
        if EventInput.KeyCode == self.Input and self.Enabled then

           if self.BeganCount and self.BeganCount >= 2  then 
                self.BindableEvent:Fire(self.SkillName,  InputMoves.States.TwoEnded)     
           end 

        end
    end)
end

    -- began and ended -- 
function InputMoves:OnInputBegan ()
    self.Connections.Began =  game:GetService("UserInputService").InputBegan:Connect(function(EventInput, InChat)
        if EventInput.KeyCode == self.Input and self.Enabled then
            self.BindableEvent:Fire(self.SkillName,  InputMoves.States.Began)
        end
    end)
end

function InputMoves:OnInputEnded ()
    self.Connections.Ended =  game:GetService("UserInputService").InputEnded:Connect(function(EventInput, InChat)
        if EventInput.KeyCode == self.Input and self.Enabled then
            self.BindableEvent:Fire(self.SkillName,  InputMoves.States.Ended)            
        end
    end)
end






return InputMoves