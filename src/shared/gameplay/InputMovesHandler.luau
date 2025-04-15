local InputMoves = {}

InputMoves.CreatedMoves = {}

InputMoves.Create = function(Input, EndedOrBegan)

    local NewMove = {
        Input = Input,
        ActiveOn = EndedOrBegan:Connect(function()
            
        end)
    }

    setmetatable(InputMoves, NewMove)

    return NewMove
end




return InputMoves