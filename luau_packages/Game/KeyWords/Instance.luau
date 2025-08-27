local module =  {}

type Instances = "Frame"

local Instances = {
    ["Frame"] = require("@game/Instances/Supers/Frame")
}

function module.new(Instance:Instances)
    if Instances[Instance] then
        return Instances[Instance].new()
    else
        return
    end
end

return module