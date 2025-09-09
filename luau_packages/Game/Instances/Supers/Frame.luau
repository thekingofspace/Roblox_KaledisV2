local UI = require("@game/Instances/RealInstances/UI")
local Udim2 = require("@game/Types/Udim")
local SuperBuilder = require("@game/Vendors/SuperConstructor")

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

local module = {}

function module.new()
    return UI.new(function()
        local FrameSuper = SuperBuilder.new()

        FrameSuper:InjectMethod("Draw", function(self:Frame, DT:number)
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
        end)

        FrameSuper:InjectProperty("Name", "Frame")

        FrameSuper:InjectProperty("ClassName", "Frame")

        return FrameSuper:BuildArray()
    end)
end

return module
