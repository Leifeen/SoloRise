
AvatarLoader = {}
local LoaderWidget = require(script.Parent.AvatarLoaderWidget)

-- will add some avatars here so we don't need to read data everytime. --
AvatarLoader.AlreadyLoaded = {}


AvatarLoader.LoadFromData = function(AppareanceSlot, Plr)
    
    local BaseRig = Plr.Character or Plr.CharacterAdded:Wait()

    local HDescript = Instance.new("HumanoidDescription")

    LoaderWidget.LoadHair(BaseRig,AppareanceSlot, Plr, HDescript)
    LoaderWidget.LoadFace(BaseRig,AppareanceSlot, Plr)
    LoaderWidget.LoadBodyType(BaseRig, AppareanceSlot, Plr)

    LoaderWidget.LoadSkinTone(BaseRig, AppareanceSlot, Plr, HDescript)

    BaseRig.Humanoid:ApplyDescription(HDescript)

    LoaderWidget.SetColor(BaseRig, AppareanceSlot, Plr)


end


return AvatarLoader