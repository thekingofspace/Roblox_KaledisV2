export  type Services = "RunService" | "TweenService" | "DataStore" | "CollectionService"

local Services = {
    RunService = require("@game/Services/RunService");
    TweenService = require("@game/Services/TweenService");
    DataStore = require("@game/Services/DataStoreService");
    CollectionService = require("@game/Services/CollectionService");
}

return function(Service:Services)
    if Services[Service] then
        return Services[Service]
    else
        return
    end
end
