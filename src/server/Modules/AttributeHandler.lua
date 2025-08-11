local AttributeHandler = {}
AttributeHandler.AppliedAtbThreads = {}



AttributeHandler.RemoveATB = function(Char: Model, Attribute: string)
    
    local ATB = AttributeHandler.HasATB(Char, Attribute)
    if ATB then
          -- Close Threads.
        if AttributeHandler.AppliedAtbThreads[Char][Attribute] then
            task.cancel(AttributeHandler.AppliedAtbThreads[Char][Attribute])
        end

        Char:SetAttribute(Attribute, nil)

    end

end

AttributeHandler.HasATB = function(Char: Model, Attribute: string)

    if Char:GetAttribute(Attribute) then 
        return Char:GetAttribute(Attribute)
    else
        return nil
    end 

    
end

AttributeHandler.AddAttribute = function(Char: Model, Attribute: string, Val: any, DeterminedTime: number )
    

    if Val then 
        Char:SetAttribute(Attribute, Val)
    else
        Char:SetAttribute(Attribute, true)    
    end 

    -- This will suport the Thread so attributes don't cancel each other.
    if not AttributeHandler.AppliedAtbThreads[Char] then 
        AttributeHandler.AppliedAtbThreads[Char] = {}
    end 

    if AttributeHandler.AppliedAtbThreads[Char][Attribute] then 
        task.cancel(AttributeHandler.AppliedAtbThreads[Char][Attribute])
        AttributeHandler.AppliedAtbThreads[Char][Attribute] = nil
    end 

    -- I  end with this attribute after some time.
    if DeterminedTime then
        -- Close the last task.spawn()
        if AttributeHandler.AppliedAtbThreads[Char][Attribute] then
            task.cancel(AttributeHandler.AppliedAtbThreads[Char][Attribute])
        end
        
        -- Create a New one
          AttributeHandler.AppliedAtbThreads[Char][Attribute] =  task.spawn(function()
            local initialTime = tick()
            repeat 
                game:GetService("RunService").Heartbeat:Wait()
            until  tick() - initialTime  > DeterminedTime
           -- task.wait(DeterminedTime)
            Char:SetAttribute(Attribute, nil)

            AttributeHandler.AppliedAtbThreads[Char][Attribute] =  nil
        end)
    end
    
end



return AttributeHandler