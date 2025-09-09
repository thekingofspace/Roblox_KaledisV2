local Instances = require("@game/InstanceStorage").Drawable

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

local function GetRotatedCorners(X, Y, Width, Height, Rotation, AnchorX, AnchorY)
    local cx, cy = X + Width * AnchorX, Y + Height * AnchorY
    local corners = {
        {X, Y}, {X + Width, Y}, {X + Width, Y + Height}, {X, Y + Height}
    }
    for _, corner in ipairs(corners) do
        local dx, dy = corner[1] - cx, corner[2] - cy
        local cosR, sinR = math.cos(Rotation), math.sin(Rotation)
        corner[1] = cx + dx * cosR - dy * sinR
        corner[2] = cy + dx * sinR + dy * cosR
    end
    return corners
end

local function PointInRotatedRect(px, py, frame)
    local X, Y, Width, Height, Rotation = frame:GetAbsolute()
    if Width < 0 then X = X + Width; Width = -Width end
    if Height < 0 then Y = Y + Height; Height = -Height end
    local corners = GetRotatedCorners(X, Y, Width, Height, Rotation, frame.AnchorPoint.X.Scale, frame.AnchorPoint.Y.Scale)

    local function Project(axis, points)
        local min, max
        for _, p in ipairs(points) do
            local proj = p[1] * axis[1] + p[2] * axis[2]
            if not min or proj < min then min = proj end
            if not max or proj > max then max = proj end
        end
        return min, max
    end

    local axes = {}
    for i = 1, 4 do
        local p1, p2 = corners[i], corners[i % 4 + 1]
        local edge = {p2[1] - p1[1], p2[2] - p1[2]}
        local length = math.sqrt(edge[1]^2 + edge[2]^2)
        if length > 1e-10 then
            axes[#axes+1] = {-edge[2]/length, edge[1]/length}
        end
    end

    for _, axis in ipairs(axes) do
        local minR, maxR = Project(axis, corners)
        local proj = px * axis[1] + py * axis[2]
        if proj < minR or proj > maxR then
            return false
        end
    end
    return true
end

local function ProjectPolygon(axis, points)
    local min, max
    for _, p in ipairs(points) do
        local proj = p[1] * axis[1] + p[2] * axis[2]
        if not min or proj < min then min = proj end
        if not max or proj > max then max = proj end
    end
    return min, max
end

local function AreFramesTouching(frame1, frame2)
    if frame1.Destroyed or frame2.Destroyed then return false end

    local ok1, X1, Y1, W1, H1, R1 = pcall(function() return frame1:GetAbsolute() end)
    local ok2, X2, Y2, W2, H2, R2 = pcall(function() return frame2:GetAbsolute() end)
    if not ok1 or not ok2 then return false end

    if W1 < 0 then X1, W1 = X1 + W1, -W1 end
    if H1 < 0 then Y1, H1 = Y1 + H1, -H1 end
    if W2 < 0 then X2, W2 = X2 + W2, -W2 end
    if H2 < 0 then Y2, H2 = Y2 + H2, -H2 end

    local ok3, corners1 = pcall(function()
        return GetRotatedCorners(X1, Y1, W1, H1, R1, frame1.AnchorPoint.X.Scale, frame1.AnchorPoint.Y.Scale)
    end)
    local ok4, corners2 = pcall(function()
        return GetRotatedCorners(X2, Y2, W2, H2, R2, frame2.AnchorPoint.X.Scale, frame2.AnchorPoint.Y.Scale)
    end)
    if not ok3 or not ok4 then return false end

    local axes = {}
    for i = 1, 4 do
        local p1, p2 = corners1[i], corners1[i % 4 + 1]
        local edge = {p2[1]-p1[1], p2[2]-p1[2]}
        local length = math.sqrt(edge[1]^2 + edge[2]^2)
        if length > 1e-10 then
            axes[#axes+1] = {-edge[2]/length, edge[1]/length}
        end
    end
    for i = 1, 4 do
        local p1, p2 = corners2[i], corners2[i % 4 + 1]
        local edge = {p2[1]-p1[1], p2[2]-p1[2]}
        local length = math.sqrt(edge[1]^2 + edge[2]^2)
        if length > 1e-10 then
            axes[#axes+1] = {-edge[2]/length, edge[1]/length}
        end
    end

    for _, axis in ipairs(axes) do
        local min1, max1 = ProjectPolygon(axis, corners1)
        local min2, max2 = ProjectPolygon(axis, corners2)
        if max1 < min2 or max2 < min1 then
            return false
        end
    end

    return true
end

local function IsValidForTouchDetection(frame)
    if frame.Destroyed then return false end
    local ok, result = pcall(function()
        return frame.GetAbsolute and frame.SinkInputs and frame.CanQuery
            and IsFullyVisible(frame) and not frame.Destroyed
            and frame.TouchBegan_Private and frame.TouchEnded_Private
    end)
    return ok and result
end


local hoveredFrames = {}
local touchingPairs = {}
local cachedInstances = {} 
local isFirstRun = true


local function SnapshotKeys(t)
    local keys = {}
    if type(t) ~= "table" then
        return keys
    end
    
    
    local ok, _ = pcall(function()
        for k, v in pairs(t) do
            
            if k ~= nil then
                keys[#keys+1] = k
            end
        end
    end)
    
    
    if not ok then
        return {}
    end
    
    return keys
end


local function CleanupDestroyedFrames()
    if isFirstRun then
        return 
    end
    
    
    for cachedFrame in pairs(cachedInstances) do
        if cachedFrame and cachedFrame.Destroyed then
            
            local pairsToRemove = {}
            
            for pairKey, pair in pairs(touchingPairs) do
                local frame1, frame2 = pair[1], pair[2]
                
                if frame1 == cachedFrame or frame2 == cachedFrame then
                    
                    if frame1 == cachedFrame and frame2 and not frame2.Destroyed and frame2.TouchEnded_Private then
                        pcall(function() frame2.TouchEnded_Private:Fire(frame1) end)
                    elseif frame2 == cachedFrame and frame1 and not frame1.Destroyed and frame1.TouchEnded_Private then
                        pcall(function() frame1.TouchEnded_Private:Fire(frame2) end)
                    end
                    
                    pairsToRemove[pairKey] = true
                end
            end
            
            
            for pairKey in pairs(pairsToRemove) do
                touchingPairs[pairKey] = nil
            end
            
            
            hoveredFrames[cachedFrame] = nil
        end
    end
end


local function CacheCurrentInstances()
    cachedInstances = {}
    
    for id, frame in pairs(Instances) do
        if frame then
            cachedInstances[frame] = true
        end
    end
    
    
    for pairKey, pair in pairs(touchingPairs) do
        local frame1, frame2 = pair[1], pair[2]
        if frame1 then cachedInstances[frame1] = true end
        if frame2 then cachedInstances[frame2] = true end
    end
end

return function(DT)
    
    CleanupDestroyedFrames()
    
    local mouseX, mouseY = love.mouse.getPosition()

    
    local instSnapshot = {}
    for _, f in pairs(Instances) do 
        if f and not f.Destroyed then  
            instSnapshot[#instSnapshot+1] = f 
        end
    end
    
    for _, frame in ipairs(instSnapshot) do
        if frame and not frame.Destroyed
            and frame.GetAbsolute and frame.SinkInputs and frame.CanQuery
            and IsFullyVisible(frame) then
            local isOver = PointInRotatedRect(mouseX, mouseY, frame)
            local wasOver = hoveredFrames[frame] or false

            if isOver and not wasOver then
                if frame.MouseHoverBegin_Private then
                    frame.MouseHoverBegin_Private:Fire()
                end
            elseif not isOver and wasOver then
                if frame.MouseHoverRelease_Private then
                    frame.MouseHoverRelease_Private:Fire()
                end
            end

            hoveredFrames[frame] = isOver
        end
    end

    
    local validFrames = {}
    for _, f in pairs(Instances) do
        if f and IsValidForTouchDetection(f) then  
            validFrames[#validFrames+1] = f
        end
    end

    local currentTouching = {}
    for i = 1, #validFrames do
        for j = i+1, #validFrames do
            local frame1, frame2 = validFrames[i], validFrames[j]
            if frame1 and frame2 and not frame1.Destroyed and not frame2.Destroyed then
                local ok, touching = pcall(function() return AreFramesTouching(frame1, frame2) end)
                if ok and touching then
                    local pairKey = tostring(frame1) .. ":" .. tostring(frame2)
                    currentTouching[pairKey] = {frame1, frame2}
                    if not touchingPairs[pairKey] then
                        pcall(function() 
                            if frame1.TouchBegan_Private then
                                frame1.TouchBegan_Private:Fire(frame2) 
                            end
                        end)
                        pcall(function() 
                            if frame2.TouchBegan_Private then
                                frame2.TouchBegan_Private:Fire(frame1) 
                            end
                        end)
                    end
                end
            end
        end
    end

    
    local tpKeys = SnapshotKeys(touchingPairs)
    for _, pairKey in ipairs(tpKeys) do
        local pair = touchingPairs[pairKey]
        if pair and not currentTouching[pairKey] then
            local frame1, frame2 = pair[1], pair[2]
            if frame1 and not frame1.Destroyed and frame1.TouchEnded_Private then
                pcall(function() frame1.TouchEnded_Private:Fire(frame2) end)
            end
            if frame2 and not frame2.Destroyed and frame2.TouchEnded_Private then
                pcall(function() frame2.TouchEnded_Private:Fire(frame1) end)
            end
        end
    end
    touchingPairs = currentTouching
    
    
    CacheCurrentInstances()
    isFirstRun = false
end