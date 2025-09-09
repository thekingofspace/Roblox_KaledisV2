local Instances = require("@game/InstanceStorage")
local UserInput = require("@game/Services/UserInputService")

local PressedItems = {}

return function(X, Y, Context:number, Action: "Input" | "Release" | "Move")
    local actions = {
        Input = function(item, IsUnder, WasPressed)
            if IsUnder and not PressedItems[item] then
                PressedItems[item] = true
                if item.MouseClick_Private then
                    item.MouseClick_Private:Fire(UserInput:GetMouseCode(Context))
                end
            end
        end,

        Release = function(item, IsUnder, WasPressed)
            if WasPressed then
                PressedItems[item] = nil
                if item.MouseRelease_Private then
                    item.MouseRelease_Private:Fire(UserInput:GetMouseCode(Context))
                end
            end
        end,

        Move = function(item, IsUnder, WasPressed)
            if WasPressed and not IsUnder then
                PressedItems[item] = nil
                if item.MouseRelease_Private then
                    item.MouseRelease_Private:Fire()
                end
            end
        end,
    }

    local handler = actions[Action]
    if not handler then
        return
    end

    for _, item:UI2D in pairs(Instances.Drawable) do
        local IsUnder:boolean = item:IsWithin(X, Y)
        local WasPressed:boolean = PressedItems[item] ~= nil
        handler(item, IsUnder, WasPressed)
    end
end
