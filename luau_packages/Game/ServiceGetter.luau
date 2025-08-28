export  type Services = "RunService" | "TweenService"

local Services = {
    RunService = require("@game/Services/RunService");
    TweenService = require("@game/Services/TweenService");
}

return function(Service:Services)
    if Services[Service] then
        return Services[Service]
    else
        return
    end
end
