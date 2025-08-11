local DescriptionCreate = {}

DescriptionCreate.ExistingDescs = {}


function DescriptionCreate:Create(ItemName, Desc)
    
    
    DescriptionCreate.ExistingDescs[ItemName] = {}
    DescriptionCreate.ExistingDescs[ItemName].MainDesc = Desc
 
    print(DescriptionCreate.ExistingDescs[ItemName])

    return DescriptionCreate.ExistingDescs[ItemName].MainDesc

end

 function DescriptionCreate:GetDesc(ItemName)
    return DescriptionCreate.ExistingDescs[ItemName].MainDesc
 end 




return DescriptionCreate