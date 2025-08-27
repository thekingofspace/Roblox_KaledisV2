local Instances = require("@game/InstanceStorage")


local function collectDrawables(root, drawables)
    table.insert(drawables, root)
    for _, child in ipairs(root:GetChildren()) do
        if child.Draw then
            collectDrawables(child, drawables)
        end
    end
end

return function(DT:number)
    local drawables = {}

    for _, item in pairs(Instances.Drawable) do
        if item.Draw and (not item.Parent or not Instances.Drawable[item.Parent]) then
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
