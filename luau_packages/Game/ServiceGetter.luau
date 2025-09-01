export  type Services = "RunService" | "TweenService" | "DataStore" | "CollectionService" | "LogService"

local Services = {
    RunService = require("@game/Services/RunService");
    TweenService = require("@game/Services/TweenService");
    DataStore = require("@game/Services/DataStoreService");
    CollectionService = require("@game/Services/CollectionService");
    LogService = require("@game/Services/LogService")
}

return function(Service:Services)
    if Services[Service] then
        return Services[Service]
    else
        return
    end
end
