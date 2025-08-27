local InstanceBase = require("@game/Instances/RealInstances/Instance")
local UDIM2 = require("@game/Types/Udim")
local Color4 = require("@game/Types/Color4")
local Signals = require("@game/Vendors/signal")

local module = {}

function module.new(SuperInject)
    return InstanceBase.new(function()
        local SuperData = {} :: SuperInject

        SuperData.PrivateProperties = {
            TouchBegan_Private = Signals.CreateSignal(),
            TouchEnded_Private = Signals.CreateSignal(),
            MouseClick_Private = Signals.CreateSignal(),
            MouseRelease_Private = Signals.CreateSignal(),
            MouseHoverBegin_Private = Signals.CreateSignal(),
            MouseHoverRelease_Private = Signals.CreateSignal(),
            Children = {}
        }

        local function asSignal(privateSignal)
            return Signals.CreateReadOnlySignal(privateSignal)
        end

        SuperData.Properties = {
            { Name = "Position",     Value = UDIM2.Zero(),  Type = "udim" },
            { Name = "Size",         Value = UDIM2.Zero(),  Type = "udim" },
            { Name = "Rotation",     Value = 0,             Type = "number" },
            { Name = "ZIndex",       Value = 0,             Type = "number" },
            { Name = "Visible",      Value = true,          Type = "boolean" },
            { Name = "AnchorPoint",  Value = UDIM2.Zero(),  Type = "udim" },
            { Name = "Color",        Value = Color4.White(),Type = "color4" },

            {
                Name = "Parent",
                Value = "nil",
                Type = { "instance", "nil" },

                ReadTransform = function(_, value)
                    if value == "nil" then
                        return nil
                    else
                        return value
                    end
                end,

                WriteTransform = function(self, oldValue, newValue)
                    if oldValue ~= "nil" and not oldValue.Destroyed then
                        for i, item in ipairs(oldValue.Children) do
                            if item == self then
                                table.remove(oldValue.Children, i)
                                break
                            end
                        end
                    end

                    if newValue == nil then
                        return "nil"
                    end

                    table.insert(newValue.Children, self)
                    return newValue
                end
            },

            { Name = "Name",      Value = "2D_UI" },
            { Name = "ClassName", Value = "2D_UI" },

            { Name = "TouchBegan",       Type = "frozen", Value = asSignal(SuperData.PrivateProperties.TouchBegan_Private) },
            { Name = "TouchEnded",       Type = "frozen", Value = asSignal(SuperData.PrivateProperties.TouchEnded_Private) },
            { Name = "MouseClick",       Type = "frozen", Value = asSignal(SuperData.PrivateProperties.MouseClick_Private) },
            { Name = "MouseRelease",     Type = "frozen", Value = asSignal(SuperData.PrivateProperties.MouseRelease_Private) },
            { Name = "MouseHoverBegin",  Type = "frozen", Value = asSignal(SuperData.PrivateProperties.MouseHoverBegin_Private) },
            { Name = "MouseHoverRelease",Type = "frozen", Value = asSignal(SuperData.PrivateProperties.MouseHoverRelease_Private) },
        }

        SuperData.Methods = {
            {
                Name = "IsDescendantOf",
                Code = function(self, target)
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
                end
            },

            {
                Name = "GetChildren",
                Code = function(self)
                    return self.Children
                end
            },

            {
                Name = "GetDescendants",
                Code = function(self)
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
                end
            }
        }


        SuperData.Extensions = {
            {
                Name = "Destroy",
                Code = function(self)
                    for _, child in ipairs(self.Children) do
                        child.Parent = nil
                    end
                    self.Parent = nil
                end
            }
        }

        if SuperInject then
            local NewData:SuperInject = SuperInject()
            for key, items in pairs(NewData) do
                for _, value in ipairs(items) do
                    table.insert(SuperData[key], value)
                end
            end
        end

        return SuperData
    end)
end

return module
