local Instances = require("@game/InstanceStorage")

local function collectDrawables(root, drawables)
    table.insert(drawables, root)
    for _, child in ipairs(root:GetChildren()) do
        collectDrawables(child, drawables)
    end
end

local function IsFullyVisible(frame)
    local target = frame
    while target do
        if (target.Visible == false or target.Enabled == false) or target.Destroyed == true then
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

local function getHierarchyPath(obj)
    local path = {}
    local current = obj
    while current do
        table.insert(path, 1, current)
        current = current.Parent
    end
    return path
end

local function isAncestor(objA, objB)
    local current = objB.Parent
    while current do
        if current == objA then
            return true
        end
        current = current.Parent
    end
    return false
end

local function findCommonAncestor(objA, objB)
    local pathA = getHierarchyPath(objA)
    local pathB = getHierarchyPath(objB)
    
    local commonAncestor = nil
    local minLength = math.min(#pathA, #pathB)
    
    for i = 1, minLength do
        if pathA[i] == pathB[i] then
            commonAncestor = pathA[i]
        else
            break
        end
    end
    
    return commonAncestor
end

return function(DT:number)
    local drawables = {}

    for _, item in pairs(Instances.Drawable) do
        if IsFullyVisible(item) then
            collectDrawables(item, drawables)
        end
    end

    table.sort(drawables, function(a, b)
        if isAncestor(a, b) then
            return true 
        elseif isAncestor(b, a) then
            return false
        end
        
        local commonAncestor = findCommonAncestor(a, b)
        
        if commonAncestor then
            local pathA = getHierarchyPath(a)
            local pathB = getHierarchyPath(b)
            
            local commonIndex = 1
            for i = 1, math.min(#pathA, #pathB) do
                if pathA[i] == pathB[i] then
                    commonIndex = i
                else
                    break
                end
            end
            
            if commonIndex < math.min(#pathA, #pathB) then
                local childA = pathA[commonIndex + 1]
                local childB = pathB[commonIndex + 1]
                return (childA.ZIndex or 0) < (childB.ZIndex or 0)
            end
        end
        
        return (a.ZIndex or 0) < (b.ZIndex or 0)
    end)

    for _, item in ipairs(drawables) do
        if item.Draw then
            item:Draw(DT)
        end
    end
end