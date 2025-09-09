local Instances = require("@game/InstanceStorage")


local function collectDrawables(root, drawables)
    table.insert(drawables, root)
    for _, child in ipairs(root:GetChildren()) do
        if child.Draw then
            collectDrawables(child, drawables)
        end
    end
end

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
        if (Ancestor.Parent and Ancestor.Parent.Name == "Workspace") or Ancestor.Name == "Workspace" then
            break
        end

        if Ancestor.Parent == nil then
            return false
        end

        Ancestor = Ancestor.Parent
    end

    return true
end

return function(DT:number)
    local drawables = {}

    for _, item in pairs(Instances.Drawable) do
        if item.Draw and IsFullyVisible(item) then
            collectDrawables(item, drawables)
        end
    end

    table.sort(drawables, function(a, b)
        return (a.ZIndex or 0) < (b.ZIndex or 0)
    end)

    for _, item in ipairs(drawables) do
        item:Draw(DT)
    end
end
