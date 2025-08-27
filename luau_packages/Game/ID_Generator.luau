local module = {
    StoragedID = {}
}

local function generateID(length:number):string
    length = length or 16
    local chars = "1234567890"
    local result = {}
    for i = 1, length do
        local rand = math.random(1, #chars)
        result[i] = string.sub(chars, rand, rand)
    end
    return table.concat(result)
end

function module:GetUniqueID():string
    local id
    repeat
        id = generateID(32)
    until not self.StoragedID[id]

    self.StoragedID[id] = true
    
    return id
end

return module