local InstanceBase = require("@game/Instances/RealInstances/Instance")
local Builder = require("@game/Vendors/SuperConstructor")
local module = {}

function module.new(SuperInject)
    return InstanceBase.new(function()
        local builder = Builder.new()

        builder:InjectProperty("Name", "Sink")

        builder:InjectProperty("ClassName", "Sink")


        builder:InjectPrivate("Sink", {})

        builder:InjectProperty("StackSize", 0, "number")

        builder:InjectExtension("Destroy", function(self)
            table.clear(self.Sink)
        end)

        builder:InjectMethod("Push", function(self, Value:any)
            if (#self.Sink < self.StackSize ) or self.StackSize == 0 then
                table.insert(self.Sink, Value)
            end
        end)

        builder:InjectMethod("Pop", function(self, Index:number?)
            if Index ~= nil then
                table.remove(self.Sink, Index)
            else
                table.clear(self.Sink)
            end
        end)

        builder:InjectMethod("Peek", function(self)
            return self.Sink[#self.Sink]
        end)

        builder:InjectMethod("Process", function(self, Callback:(any) -> nil)
            for I, item in ipairs(self.Sink) do
                Callback(item)
            end
        end)
        
        builder:InjectMethod("Find", function(self, Predicate:(any) -> boolean)
            for i, v in ipairs(self.Sink) do
                if Predicate(v) then
                    return v, i
                end
            end
            return nil
        end)

        return builder:BuildArray()
    end)
end

return module
