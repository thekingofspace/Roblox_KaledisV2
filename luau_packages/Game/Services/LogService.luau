local log = {}

local function getDateTime()
    return os.date("%Y-%m-%d %H:%M:%S")
end

function log:Push(message: string)
    local f = io.open("log.txt", "a")
    if f then
        print(string.format("[%s] - %s\n", getDateTime(), message))
        f:write(string.format("[%s] - %s\n", getDateTime(), message))
        f:close()
    else
        error("Could not open log.txt for writing")
    end
end

function log:Clear()
    local f = io.open("log.txt", "w")
    if f then
        f:write("")
        f:close()
    else
        error("Could not clear log.txt")
    end
end

return log
