local UI = require("@game/Instances/RealInstances/UI")
local Udim2 = require("@game/Types/Udim")

local module = {}

local function CheckVisible(Instance:Frame)
    local target = Instance
    while target ~= nil do
        if target.Visible == false then
            return  false
        end

        target = target.Parent
    end

    return true
end

function module.new()
    return UI.new(function()
        local Super = {}::SuperInject

        Super.Methods = {}

        Super.Properties = {
            { Name = "Name",      Value = "Frame" },
            { Name = "ClassName", Value = "Frame" }
        }

        table.insert(Super.Methods, {
            Name = "Draw";

            Code = function(self:Frame, DT)
                if CheckVisible(self) ~= true then
                    return
                end

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

                local truePosition:UDim = Udim2.FromScale(truePosX, truePosY)
                local X, Y = truePosition:ToAbsolute()

                love.graphics.push()
                love.graphics.setColor(self.Color:GetColor())

                local centerX = X + Width * self.AnchorPoint.X.Scale
                local centerY = Y + Height * self.AnchorPoint.Y.Scale

                love.graphics.translate(centerX, centerY)
                love.graphics.rotate(math.rad(TrueRotation))
                love.graphics.translate(-centerX, -centerY)

                love.graphics.rectangle("fill", X, Y, Width, Height)
                love.graphics.pop()
            end
        })

        table.insert(Super.Methods,  {
            Name = "GetAbsolute";

            Code = function(self)
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

                local truePosition:UDim = Udim2.FromScale(truePosX, truePosY)
                local X, Y = truePosition:ToAbsolute()

                return X, Y, Width, Height, math.rad(TrueRotation) 
            end
        })

        return Super
    end)
end

return module
