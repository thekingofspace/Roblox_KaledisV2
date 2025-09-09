local SignalStorage = require("@game/SignalStorage")

local Heartbeat: Signal = SignalStorage.HeartBeat

local Task = {}
Task.__index = Task

local Queue = {}
local DelayQueue = {}

local getTime = os.clock

Heartbeat:Connect(function()
    local now = getTime()

    for i = #DelayQueue, 1, -1 do
        local d = DelayQueue[i]
        if now >= d.executeAt then
            table.remove(DelayQueue, i)
            table.insert(Queue, d.fn)
        end
    end

    local nextTask = table.remove(Queue, 1)
    if nextTask then
        coroutine.wrap(nextTask)()
    end
end)

function Task.wait(seconds: number?)
    local thread = coroutine.running()
    if not thread then error("task.wait() must be used inside coroutine") end

    local resumeTime = getTime() + (seconds or 0)

    table.insert(DelayQueue, {
        executeAt = resumeTime,
        fn = function()
            coroutine.resume(thread)
        end
    })

    return coroutine.yield()
end

function Task.spawn(fn, ...)
    local args = {...}
    table.insert(Queue, function()
        fn(unpack(args))
    end)
end

function Task.defer(fn, ...)
    local args = {...}
    table.insert(Queue, function()
        fn(unpack(args))
    end)
end

function Task.delay(seconds, fn, ...)
    local args = {...}
    table.insert(DelayQueue, {
        executeAt = getTime() + seconds,
        fn = function()
            fn(unpack(args))
        end
    })
end

return Task
