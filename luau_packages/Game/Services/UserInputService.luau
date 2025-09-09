local module = {}

local Enum = require("@game/KeyWords/Enum")
local SignalStorage = require("@game/SignalStorage")


function module:GetMouseCode(MouseCode:number)
    for I, item in pairs(Enum.MouseInputs) do
        if item == MouseCode then
            return I
        end
    end

    return
end

function module:GetScanCode(KeyCode)
    return love.keyboard.getScancodeFromKey(KeyCode)
end


function module:GetKeyCode(ScanCode)
    return love.keyboard.getKeyFromScancode(ScanCode)
end

function module:GetMouse()
    local RawMouse = {}
    local mouse = setmetatable({}, {
        __index = function(self, Index:string)
            local Indexes = {
                ["X"] = function()
                    return love.mouse.getX()
                end;

                ["Y"] = function()
                    return love.mouse.getY()
                end
            }

            if Indexes[Index] then
                return Indexes[Index]()
            end

            return RawMouse[Index]
        end;

        __newindex = function(self, Index:string, NewValue)
            local Indexes = {
                ["Visible"] = function()
                    love.mouse.setVisible(NewValue)
                    RawMouse.Visible = NewValue
                end;

                ["X"] = function()
                    love.mouse.setPosition(NewValue, love.mouse.getY())
                end;

                ["Y"] = function()
                    love.mouse.setPosition(love.mouse.getX(), NewValue)
                end
            }

            if Indexes[Index] then
                Indexes[Index](NewValue)
            end
        end
    })

    RawMouse.Clicked = SignalStorage.MouseClick
    RawMouse.Release = SignalStorage.MouseRelease
    RawMouse.Moved = SignalStorage.MouseMoved
    RawMouse.Cursor = "arrow"

    RawMouse.Visible = true

    function RawMouse:SetCursor(Cursor)
        love.mouse.setCursor(love.mouse.getSystemCursor(Cursor))
        RawMouse.Cursor = Cursor
    end

    return mouse
end

SignalStorage.MouseClick:AddConstructor(function(X,Y, Button)
    return X, Y, module:GetMouseCode(Button)
end)

SignalStorage.MouseRelease:AddConstructor(function(X,Y, Button)
    return X, Y, module:GetMouseCode(Button)
end)

module.KeyDown = SignalStorage.KeyDown

module.KeyRelease = SignalStorage.KeyRelease


return module