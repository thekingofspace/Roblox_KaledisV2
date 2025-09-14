local module =  {}

type Instances = "Frame" | "BindableEvent" | "Sink" | "UI_Group"

local Instances = {
    ["Frame"] = require("@game/Instances/Supers/Frame");
    ["BindableEvent"] = require("@game/Instances/Supers/BindableEvent");
    ["Sink"] = require("@game/Instances/Supers/Sink");
    ["UI_Group"] = require("@game/Instances/Supers/UIGroup")
}

function module.new(Instance:Instances)
    if Instances[Instance] then
        return Instances[Instance].new()
    else
        return
    end
end

return module