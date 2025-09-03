local module = {}

function module.new()
    local self = setmetatable({}, {})
    self.Methods = {}

    self.Properties = {}

    self.PrivateProperties = {}

    self.Extensions = {}

    function self:InjectMethod(ID:string, Callback:(self:any, ...any) -> any)
        table.insert(self.Methods, {
            Name = ID,

            Code = Callback
        })
    end

    function self:InjectExtension(ID:string, Callback:(self:any, ...any) -> any)
        table.insert(self.Extensions, {
            Name = ID,

            Code = Callback
        })
    end

    function self:InjectProperty(ID:string, Value:any, Type:(string & {string})?, ReadTransform:((self:any, Value:any) -> ...any)?, WriteTransform:((self:any, OldValue:any, Value:any) -> any)?)
        table.insert(self.Properties, {
            Name = ID;

            Value = Value;

            Type = Type;

            ReadTransform = ReadTransform;

            WriteTransform = WriteTransform;
        })
    end

    function self:InjectPrivate(ID:string, Value:any)
        self.PrivateProperties[ID] = Value
    end

    function self:BuildArray():SuperInject
        return {
            Methods = self.Methods;
            Properties = self.Properties;
            PrivateProperties = self.PrivateProperties;
            Extensions = self.Extensions
        }
    end

    function self:GetPrivate(ID:string)
        return self.PrivateProperties[ID]
    end
    
    self.__index = self

    return self
end

return module