local InstanceBase = require("@game/Instances/RealInstances/Instance")
local Builder = require("@game/Vendors/SuperConstructor")
local Signal = require("@game/Vendors/signal")

local module = {}

function module.new(SuperInject)
    return InstanceBase.new(function()
        local builder = Builder.new()
        
        builder:InjectProperty("Name", "BindableEvent")

        builder:InjectProperty("ClassName", "BindableEvent")

        builder:InjectPrivate("Event_Private", Signal.CreateSignal())

        builder:InjectProperty("Event", Signal.CreateReadOnlySignal(builder:GetPrivate("Event_Private")), "frozen")

        builder:InjectExtension("Destroy", function(self)
            self.Event_Private:Destroy()
        end)

        builder:InjectMethod("Fire", function(self, ...)
            builder:GetPrivate("Event_Private"):Fire(...)
        end)
        
        return builder:BuildArray()
    end)
end

return module