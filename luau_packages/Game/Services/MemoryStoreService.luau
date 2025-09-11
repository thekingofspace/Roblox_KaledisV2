local module = {}
local Json = require("@game/Vendors/Json")

local lfs = love.filesystem

local Maps = {
    Sorted = {},
    Hash = {}
}

if not lfs.getInfo("MemoryStore") then
    lfs.createDirectory("MemoryStore")
end

if not lfs.getInfo("MemoryStore/Hash.json") then
    lfs.write("MemoryStore/Hash.json", "{}")
end

if not lfs.getInfo("MemoryStore/Sorted.json") then
    lfs.write("MemoryStore/Sorted.json", "{}")
end

local function loadJson(path)
    if lfs.getInfo(path) then
        local content = lfs.read(path)
        if content and content ~= "" then
            local ok, data = pcall(function()
                return Json.decode(content)
            end)
            if ok and type(data) == "table" then
                return data
            end
        end
    end
    return {}
end

Maps.Sorted = loadJson("MemoryStore/Sorted.json")
Maps.Hash = loadJson("MemoryStore/Hash.json")

local function AssembleMeta(Value, Expire, Key)
    return {
        Data = Value,
        MetaData = {
            Updated = os.time(),
            Expires = Expire,
            Key = Key
        }
    }
end

local function saveJson(path, tbl)
    local ok, encoded = pcall(function()
        return Json.encode(tbl, false)
    end)
    if ok and encoded then
        lfs.write(path, encoded)
    end
end

local function timeUntil(unixTimestamp)
    local now = os.time()
    local diff = unixTimestamp - now
    if diff < 0 then
        return 0
    end
    return diff
end

local function cleanupSortedMap(mapName)
    if not Maps.Sorted[mapName] then
        return
    end
    
    local cleaned = {}
    for i, item in ipairs(Maps.Sorted[mapName]) do
        if item and item.MetaData and timeUntil(item.MetaData.Expires) > 0 then
            table.insert(cleaned, item)
        end
    end
    Maps.Sorted[mapName] = cleaned
    saveJson("MemoryStore/Sorted.json", Maps.Sorted)
end

function module:GetSortedMap(MapName)
    local DefMap = {}

    Maps.Sorted[MapName] = Maps.Sorted[MapName] or {}

    function DefMap:GetAsync(Key)
        for I, item in ipairs(Maps.Sorted[MapName]) do
            if item and item.MetaData and item.MetaData.Key == Key then
                if timeUntil(item.MetaData.Expires) > 0 then
                    return item.Data, timeUntil(item.MetaData.Expires)
                else
                    table.remove(Maps.Sorted[MapName], I)
                    saveJson("MemoryStore/Sorted.json", Maps.Sorted)
                    return nil, 0
                end
            end
        end
        return nil, 0
    end

    function DefMap:SetAsync(Key, Value, Expire)
        local Index = nil

        for I, item in ipairs(Maps.Sorted[MapName]) do
            if item and item.MetaData and item.MetaData.Key == Key then
                Index = I
                break
            end
        end

        local newItem = AssembleMeta(Value, os.time() + Expire, Key)

        if Index then
            Maps.Sorted[MapName][Index] = newItem
        else
            table.insert(Maps.Sorted[MapName], newItem)
        end

        saveJson("MemoryStore/Sorted.json", Maps.Sorted)
    end

    function DefMap:RemoveAsync(Key)
        for I, item in ipairs(Maps.Sorted[MapName]) do
            if item and item.MetaData and item.MetaData.Key == Key then
                table.remove(Maps.Sorted[MapName], I)
                saveJson("MemoryStore/Sorted.json", Maps.Sorted)
                return
            end
        end
    end

    function DefMap:ListAsync()
        cleanupSortedMap(MapName)
        return Maps.Sorted[MapName] or {}
    end

    return setmetatable(DefMap, {__index = DefMap})
end

function module:GetHashMap(MapName)
    local DefMap = {}

    Maps.Hash[MapName] = Maps.Hash[MapName] or {}

    function DefMap:GetAsync(Key)
        local item = Maps.Hash[MapName][Key]
        if item then
            if timeUntil(item.MetaData.Expires) > 0 then
                return item.Data, timeUntil(item.MetaData.Expires)
            else
                Maps.Hash[MapName][Key] = nil
                saveJson("MemoryStore/Hash.json", Maps.Hash)
                return nil, 0
            end
        end
        return nil, 0
    end

    function DefMap:SetAsync(Key, Value, Expire)
        Maps.Hash[MapName][Key] = AssembleMeta(Value, os.time() + Expire, Key)
        saveJson("MemoryStore/Hash.json", Maps.Hash)
    end

    function DefMap:RemoveAsync(Key)
        if Maps.Hash[MapName][Key] then
            Maps.Hash[MapName][Key] = nil
            saveJson("MemoryStore/Hash.json", Maps.Hash)
        end
    end

    return setmetatable(DefMap, {__index = DefMap})
end

return module
