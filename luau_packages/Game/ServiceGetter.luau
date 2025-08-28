export  type Services = "RunService" | "TweenService" | "DataStore"

local Services = {
    RunService = require("@game/Services/RunService");
    TweenService = require("@game/Services/TweenService");
    DataStore = require("@game/Services/DataStoreService");
}

return function(Service:Services)
    if Services[Service] then
        return Services[Service]
    else
        return
    end
end
