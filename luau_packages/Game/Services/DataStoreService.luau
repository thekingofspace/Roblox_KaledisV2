--!nocheck
local module = {}
local Json = require("@game/Vendors/Json")

local BASE_FOLDER = "datastores"
love.filesystem.createDirectory(BASE_FOLDER)

local function NewData(folderName)
    local self = {}
    
    self.folder = BASE_FOLDER .. "/" .. (folderName or "DataStore")
    love.filesystem.createDirectory(self.folder)

    function self:SetAsync(key, value)
        local path = self.folder .. "/" .. key .. ".json"
        local encoded = Json.encode(value, true)
        love.filesystem.write(path, encoded)
    end
    
    function self:UpdateAsync(key, Callback:(OldData:any) -> any)
        local current = self:GetAsync(key)
        local updated = Callback(current)
        self:SetAsync(key, updated)
    end

    local function ReadAsync(key)
        local path = self.folder .. "/" .. key .. ".json"
        if love.filesystem.getInfo(path) then
            return love.filesystem.read(path)
        end
        return nil
    end

    function self:GetAsync(key)
        local raw = ReadAsync(key)
        if raw then
            local success, decoded = pcall(Json.decode, raw)
            if success then
                return decoded
            end
        end
        return nil
    end

    function self:ListStores()
        local files = love.filesystem.getDirectoryItems(self.folder)
        local result = {}
        for _, file in ipairs(files) do
            if file:sub(-5) == ".json" then
                local key = file:sub(1, -6)
                local value = self:GetAsync(key)
                table.insert(result, {Key = key, Value = value})
            end
        end
        return result
    end

    self = setmetatable(self, {})
    self.__index = self

    return self
end

function module:GetDataStore(folderName)
    return NewData(folderName)
end

function module:ListDataStores()
    local folders = love.filesystem.getDirectoryItems(BASE_FOLDER)
    local result = {}
    for _, item in ipairs(folders) do
        local info = love.filesystem.getInfo(BASE_FOLDER .. "/" .. item)
        if info and info.type == "directory" then
            table.insert(result, item)
        end
    end
    return result
end

return module
