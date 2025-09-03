local module =  {}

type Instances = "Frame" | "BindableEvent"

local Instances = {
    ["Frame"] = require("@game/Instances/Supers/Frame");
    ["BindableEvent"] = require("@game/Instances/Supers/BindableEvent")
}

function module.new(Instance:Instances)
    if Instances[Instance] then
        return Instances[Instance].new()
    else
        return
    end
end

return module