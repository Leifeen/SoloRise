local GetControllersInfo = {}
GetControllersInfo.CharTable = {}

GetControllersInfo.Controllers = {}

GetControllersInfo.GetCurrentPlrWeaponAction = function()
    
    if true then
    return true
    
    end
    
    -- Get Current Move Hierarchy
    local CurrentWeapon =  GetControllersInfo.Controllers.WeaponController.CurrentWeapon
    if CurrentWeapon ~= nil then
        return CurrentWeapon.StarterMoves.CurrentyMoveHierarchy
    end

end

GetControllersInfo.Init = function(tab)
    GetControllersInfo.Controllers = tab
end

return GetControllersInfo