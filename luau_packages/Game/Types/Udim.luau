local module =  {}

local function scaleToPixels(scaleX, scaleY)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local pixelX = scaleX * screenWidth
    local pixelY = scaleY * screenHeight

    return pixelX, pixelY
end

function module.new(ScaleX:number, OffsetX:number, ScaleY:number, OffsetY:number)
    local self = {
        X =  {
            Scale = ScaleX;
            Offset = OffsetX
        };

        Y =  {
            Scale = ScaleY;
            Offset = OffsetY
        };

        Type = "udim"
    }

   function self:ToAbsolute()
    local px, py = scaleToPixels(self.X.Scale, self.Y.Scale)
        px = px + self.X.Offset
        py = py + self.Y.Offset
        return px, py
    end

    local MT = {}

    MT.__add = function(self, Value)
        if typeof(Value) == "table" then
            return module.new(
                self.X.Scale + Value.X.Scale,
                self.X.Offset + Value.X.Offset,
                self.Y.Scale + Value.Y.Scale,
                self.Y.Offset + Value.Y.Offset
            )
        end
        return
    end

    MT.__sub = function(self, Value)
        if typeof(Value) == "table" then
            return module.new(
                self.X.Scale - Value.X.Scale,
                self.X.Offset - Value.X.Offset,
                self.Y.Scale - Value.Y.Scale,
                self.Y.Offset - Value.Y.Offset
            )
        end
        return
    end

    MT.__tostring  = function(self)
        return  `{self.X.Scale} {self.X.Offset} {self.Y.Scale} {self.Y.Offset}`
    end

    self = setmetatable(self, MT)

    return self
end

function module.FromScale(X:number, Y:number)
   return module.new(X, 0, Y, 0)
end

function module.FromOffset(X:number, Y:number)
    return module.new(0, X, 0, Y)
end

function module.Zero()
    return module.new(0, 0, 0, 0)
end

return module
