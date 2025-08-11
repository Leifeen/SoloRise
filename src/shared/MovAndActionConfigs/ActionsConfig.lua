ActionsConfig = {

    GeneralMovement = {
        Whitelist = {},
        BasePriority = 3,
    } -- any hierarchy that has a Priority of 3, will stop the movement from performing;


}

ActionsConfig.NegativeStatus = {
    ["EndLag"] = {
        Whitelist = {"Dash"},
        BlockAll = true,
    },
    ["Stunned"] = {
        Whitelist = {},
        BlockAll = true,
    },
    ["InCombat"] = {
        Whitelist = {"Running","StopRunning", "Crouch", "StopCrouch", "Slide", "SlideJump", "Dash", "WallRun", "WallRunJump","Jump","DoubleJump","WallClimb","Vault","JumpAirTime", "Idle", "Landed", "Falling"}, 
        BlockAll = true
    },
    ["InM1"] = {
         Whitelist = {},
        BlockAll = true,
    }
}
ActionsConfig.SimpleNegativeOnList = {}

for TableName, child in pairs(ActionsConfig.NegativeStatus) do 
    table.insert(ActionsConfig.SimpleNegativeOnList, TableName)
end 


ActionsConfig.GetNegativeStatus = function(Char)
    local CharAttributes =  Char:GetAttributes()
  
    local AllNegativeStList = {}
    for AtbName, child in pairs(CharAttributes) do 
        
        if typeof(child) == "boolean" and child ~= true then
            continue
        end

        if table.find (ActionsConfig.SimpleNegativeOnList, AtbName) then
            AllNegativeStList[AtbName] = ActionsConfig.NegativeStatus[AtbName]
        end
    end 

    return AllNegativeStList

end


return ActionsConfig