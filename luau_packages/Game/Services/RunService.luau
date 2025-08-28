local SignalStorage = require("@game/SignalStorage")
local Signals = require("@game/Vendors/signal")
local module = {
    RenderStep = Signals.CreateReadOnlySignal(SignalStorage.RenderStep);
    HeartBeat = Signals.CreateReadOnlySignal(SignalStorage.HeartBeat);
}

function module:Quit(Code:number)
    love.event.quit(Code)
end

return module