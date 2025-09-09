local json = require("@game/Vendors/Json")
local toml = require("@game/Vendors/Json")
local Switch = require("@game/Vendors/Switch")

local module = {}

function module:Encode(Type:EncodeTypes, Data:any, Pretty:boolean?)
    return Switch({
        ["json"] = function(stop)
            stop()
            return json.encode(Data, Pretty)
        end;

        ["toml"] = function(stop)
            stop()
            return toml.encode(Data)
        end;

        ["default"] = function(stop)
            stop()
            error("Must be json or toml")
        end;
    }, {}, Type)
end

function module:Decode(Type:EncodeTypes, Data:string)
    return Switch({
        ["json"] = function(stop)
            stop()
            return json.decode(Data)
        end;

        ["toml"] = function(stop)
            stop()
            return toml.decode(Data)
        end;

        ["default"] = function(stop)
            stop()
            error("Must be json or toml")
        end;
    }, {}, Type)
end

return module