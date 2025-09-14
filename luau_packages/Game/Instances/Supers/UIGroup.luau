local InstanceBase = require("@game/Instances/RealInstances/Parentable")
local Builder = require("@game/Vendors/SuperConstructor")

local module = {}

function module.new(SuperInject)
    return InstanceBase.new(function()
        local builder = Builder.new()
        
        builder:InjectProperty("Name", "UI_Group")

        builder:InjectProperty("ClassName", "UI_Group")

        builder:SetRenderType("Drawable")

        builder:InjectProperty("Visible", true)
        
        return builder:BuildArray()
    end)
end

return module