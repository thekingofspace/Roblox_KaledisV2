--!nocheck
local module = {}

function module.new(R:number, G:number, B:number, A:number)
    local self = {
        R = R;
        G = G;
        B = B;
        A = A or 1;
        Type = "color4"
    }

    function self:GetSerial()
        return {
            R = self.R;
            G = self.G;
            B = self.B;
            A = self.A;
        }
    end

    function self:GetColor()
        return self.R, self.G, self.B, self.A
    end

    local MT = {}

    MT.__add = function(self, Value)
        if typeof(Value) == "table" then
            return module.new(
                self.R + Value.R,
                self.G + Value.G,
                self.B + Value.B,
                self.A + (Value.A or 0)
            )
        end
        return
    end

    MT.__sub = function(self, Value)
        if typeof(Value) == "table" then
            return module.new(
                self.R - Value.R,
                self.G - Value.G,
                self.B - Value.B,
                self.A - (Value.A or 0)
            )
        end
        return
    end

    MT.__tostring = function(self)
        return `{self.R} {self.G} {self.B} {self.A}`
    end

    self = setmetatable(self, MT)
    return self
end

function module.FromSerial(serial)
    return module.new(serial.R, serial.G, serial.B, serial.A)
end

function module.White()
    return module.new(1, 1, 1, 1)
end

function module.Black()
    return module.new(0, 0, 0, 1)
end

function module.Zero()
    return module.new(0, 0, 0, 0)
end

function module.FromRGB(r:number, g:number, b:number)
    return module.new(r, g, b, 1)
end

function module.FromHex(hex)
    hex = hex:gsub("#","")
    local r, g, b, a = 0, 0, 0, 1

    if #hex == 6 then
        r = tonumber(hex:sub(1,2), 16) / 255
        g = tonumber(hex:sub(3,4), 16) / 255
        b = tonumber(hex:sub(5,6), 16) / 255
    elseif #hex == 8 then
        r = tonumber(hex:sub(1,2), 16) / 255
        g = tonumber(hex:sub(3,4), 16) / 255
        b = tonumber(hex:sub(5,6), 16) / 255
        a = tonumber(hex:sub(7,8), 16) / 255
    else
        error("Invalid hex format. Use #RRGGBB or #RRGGBBAA")
    end

    return module.new(r, g, b, a)
end

return module
