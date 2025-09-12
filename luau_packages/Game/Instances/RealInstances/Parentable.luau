local InstanceBase = require("@game/Instances/RealInstances/Instance")
local Builder = require("@game/Vendors/SuperConstructor")
local Signals = require("@game/Vendors/signal")

local module = {}

function module.new(SuperInject)
    return InstanceBase.new(function()
        local builder = Builder.new()
        builder:InjectClassType("Parentable")
        
        builder:InjectPrivate("Children", {})
        builder:InjectProperty("Name", "Parentable")
        builder:InjectProperty("ClassName", "Parentable")

        builder:InjectPrivate("childadded_private", Signals.CreateSignal())
        builder:InjectPrivate("childremoved_private", Signals.CreateSignal())
        builder:InjectProperty("ChildAdded", builder:GetPrivate("childadded_private"))
        builder:InjectProperty("ChildRemoved", builder:GetPrivate("childremoved_private"))

        builder:InjectPrivate("descendantadded_private", Signals.CreateSignal())
        builder:InjectPrivate("descendantremoved_private", Signals.CreateSignal())
        builder:InjectProperty("DescendantAdded", builder:GetPrivate("childadded_private"))
        builder:InjectProperty("DescendantRemoved", builder:GetPrivate("childremoved_private"))
        
        builder:InjectProperty("Parent", "nil", {"instance", "nil"}, 
            function(_, value)
                if value == "nil" then
                    return nil
                else
                    return value
                end
            end,
            
            function(self, oldValue, newValue)
                if oldValue ~= "nil" and not oldValue.Destroyed then
                    for i, item in ipairs(oldValue.Children) do
                        if item == self then
                            table.remove(oldValue.Children, i)
                            item.childremoved_private:Fire(self)

                            local ancestor = self.Parent
                            
                            while true do
                                if ancestor ~= nil then
                                    ancestor.DescendantRemoved:Fire(self)

                                    ancestor = ancestor.Parent
                                else
                                    break
                                end
                            end
                            break
                        end
                    end
                end

                if newValue == nil or not newValue:IsA("Parentable") then
                    return "nil"
                end

                newValue.childadded_private:Fire(self)
                local ancestor = self.Parent
                
                while true do
                    if ancestor ~= nil then
                        ancestor.descendantadded_private:Fire(self)

                        ancestor = ancestor.Parent
                    else
                        break
                    end
                end

                table.insert(newValue.Children, self)
                return newValue
            end
        )

        builder:InjectMethod("IsDescendantOf", function(self, target)
            if typeof(target) ~= "table" or target.Type ~= "instance" then
                return false
            end
            local ancestor = self
            while ancestor do
                if ancestor == target then
                    return true
                end
                ancestor = ancestor.Parent
            end
            return false
        end)
        
        builder:InjectMethod("GetChildren", function(self)
            return self.Children
        end)

        builder:InjectMethod("FindFirstChild", function(self, Child:string)
            for I, item in ipairs(self.Children) do
                if item.Name == Child then
                    return item
                end
            end

            return
        end)

        builder:InjectMethod("WaitForChild", function(self, Child: string, Timeout: number?)
            local startTime = os.clock()
            Timeout = Timeout or 5

            while true do
                local remaining = Timeout and (Timeout - (os.clock() - startTime)) or nil
                if remaining and remaining <= 0 then
                    error("Endless yield on" .. Child)
                    return nil
                end

                local NewChild = self.childadded_private:Wait(remaining)

                if NewChild.Name == Child then
                    return NewChild
                end
            end
        end)
        
        builder:InjectMethod("GetDescendants", function(self)
            local descendants = {}
            local function recurse(children)
                for _, child in ipairs(children) do
                    table.insert(descendants, child)
                    if #child.Children > 0 then
                        recurse(child.Children)
                    end
                end
            end
            recurse(self.Children)
            return descendants
        end)
        
        builder:InjectExtension("Destroy", function(self)
            for _, child in ipairs(self.Children) do
                child.Parent = nil
            end
            self.Parent = nil
        end)

        local SuperData = builder:BuildArray()
        
        if SuperInject then
            local NewData = SuperInject()
            for key, items in pairs(NewData) do
                if  key == "PrivateProperties" then
                    for E, value in pairs(items) do
                        SuperData[key][E] = value
                    end

                    continue
                end

                if key == "Extensions" then
                    for I, value in pairs(items) do
                        SuperData[key][I] = SuperData[key][I] or {}

                        for i, item in ipairs(value) do
                            table.insert(SuperData[key][I], item)
                        end
                    end

                    continue
                end

                for _, value in ipairs(items) do
                    table.insert(SuperData[key], value)
                end
            end
        end
        
        return SuperData
    end)
end

return module