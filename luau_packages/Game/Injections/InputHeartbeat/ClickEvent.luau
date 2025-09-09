local Instances = require("@game/InstanceStorage")
local UserInput = require("@game/Services/UserInputService")

local PressedItems = {}

local function IsFullyVisible(frame:UI2D)
    local target = frame
    while target do
        if target.Visible == false or target.Destroyed == true then
            return false
        end
        target = target.Parent
    end

    local Ancestor = frame

    while true do
        if Ancestor.Parent and Ancestor.Parent.Name == "Workspace" then
            break
        end

        if Ancestor.Parent == nil then
            return false
        end

        Ancestor = Ancestor.Parent
    end

    return true
end


return function(X, Y, Context, Action: "Input" | "Release" | "Move")
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
        if item.SinkInputs == true and IsFullyVisible(item) == true then
            local IsUnder:boolean = item:IsWithin(X, Y)
            local WasPressed:boolean = PressedItems[item] ~= nil
            handler(item, IsUnder, WasPressed)
        end
    end
end
