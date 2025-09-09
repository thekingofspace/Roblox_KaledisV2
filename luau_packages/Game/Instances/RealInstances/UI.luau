local InstanceBase = require("@game/Instances/RealInstances/Instance")
local UDIM2 = require("@game/Types/Udim")
local Color4 = require("@game/Types/Color4")
local Signals = require("@game/Vendors/signal")
local Builder = require("@game/Vendors/SuperConstructor")

local module = {}

function module.new(SuperInject)
    return InstanceBase.new(function()
        local builder = Builder.new()
        
        builder:InjectPrivate("TouchBegan_Private", Signals.CreateSignal())
        builder:InjectPrivate("TouchEnded_Private", Signals.CreateSignal())
        builder:InjectPrivate("MouseClick_Private", Signals.CreateSignal())
        builder:InjectPrivate("MouseRelease_Private", Signals.CreateSignal())
        builder:InjectPrivate("MouseHoverBegin_Private", Signals.CreateSignal())
        builder:InjectPrivate("MouseHoverRelease_Private", Signals.CreateSignal())
        builder:InjectPrivate("Children", {})
        
        local function asSignal(privateSignal)
            return Signals.CreateReadOnlySignal(privateSignal)
        end
        
        builder:InjectProperty("Position", UDIM2.Zero(), "udim")
        builder:InjectProperty("Size", UDIM2.Zero(), "udim")
        builder:InjectProperty("Rotation", 0, "number")
        builder:InjectProperty("ZIndex", 0, "number")
        builder:InjectProperty("Visible", true, "boolean")
        builder:InjectProperty("AnchorPoint", UDIM2.Zero(), "udim")
        builder:InjectProperty("Color", Color4.White(), "color4")
        builder:InjectProperty("CanQuery", true, "boolean")
        builder:InjectProperty("SinkInputs", true, "boolean")
        builder:InjectProperty("Name", "2D_UI")
        builder:InjectProperty("ClassName", "2D_UI")
        
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
        )
        
        local privateProps = builder.PrivateProperties
        builder:InjectProperty("TouchBegan", asSignal(privateProps.TouchBegan_Private), "frozen")
        builder:InjectProperty("TouchEnded", asSignal(privateProps.TouchEnded_Private), "frozen")
        builder:InjectProperty("MouseClick", asSignal(privateProps.MouseClick_Private), "frozen")
        builder:InjectProperty("MouseRelease", asSignal(privateProps.MouseRelease_Private), "frozen")
        builder:InjectProperty("MouseHoverBegin", asSignal(privateProps.MouseHoverBegin_Private), "frozen")
        builder:InjectProperty("MouseHoverRelease", asSignal(privateProps.MouseHoverRelease_Private), "frozen")
        

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

            privateProps.TouchBegan_Private:Destroy()
            privateProps.TouchEnded_Private:Destroy()
            privateProps.MouseClick_Private:Destroy()
            privateProps.MouseRelease_Private:Destroy()
            privateProps.MouseHoverBegin_Private:Destroy()
            privateProps.MouseHoverRelease_Private:Destroy()
        end)

        builder:InjectMethod("GetAbsolute", function(self:UI2D)
            local truePosX = self.Position.X.Scale - self.Size.X.Scale * self.AnchorPoint.X.Scale
            local truePosY = self.Position.Y.Scale - self.Size.Y.Scale * self.AnchorPoint.Y.Scale

            local Width, Height = self.Size:ToAbsolute()
            local TrueRotation = self.Rotation

            local Parent = self.Parent

            while Parent ~= nil do
                TrueRotation += Parent.Rotation

                truePosX = truePosX * Parent.Size.X.Scale + Parent.Position.X.Scale - Parent.Size.X.Scale * Parent.AnchorPoint.X.Scale
                truePosY = truePosY * Parent.Size.Y.Scale + Parent.Position.Y.Scale - Parent.Size.Y.Scale * Parent.AnchorPoint.Y.Scale

                Width = Width * Parent.Size.X.Scale
                Height = Height * Parent.Size.Y.Scale

                Parent = Parent.Parent
            end

            local truePosition:UDim = UDIM2.FromScale(truePosX, truePosY)
            local X, Y = truePosition:ToAbsolute()

            return X, Y, Width, Height, math.rad(TrueRotation) 
        end)

        builder:InjectMethod("IsWithin", function(self, X:number, Y:number, Z):boolean
            local absX, absY, width, height, rotation = self:GetAbsolute()

            local centerX = absX + width / 2
            local centerY = absY + height / 2
            local dx = X - centerX
            local dy = Y - centerY

            local cosR = math.cos(-rotation)
            local sinR = math.sin(-rotation)
            local localX = dx * cosR - dy * sinR
            local localY = dx * sinR + dy * cosR

            return math.abs(localX) <= width / 2 and math.abs(localY) <= height / 2
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

                for _, value in ipairs(items) do
                    table.insert(SuperData[key], value)
                end
            end
        end
        
        return SuperData
    end)
end

return module