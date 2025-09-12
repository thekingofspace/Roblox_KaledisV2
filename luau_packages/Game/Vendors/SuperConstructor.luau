local module = {}

function module.new()
    local self = setmetatable({}, {})
    self.Methods = {}

    self.Properties = {}

    self.PrivateProperties = {}

    self.Extensions = {}

    self.ClassTypes = {}

    function self:InjectMethod(ID:string, Callback:(self:any, ...any) -> any)
        table.insert(self.Methods, {
            Name = ID,

            Code = Callback
        })
    end

    function self:InjectExtension(ID:string, Callback:((self:any, ...any) -> any))
        self.Extensions[ID] = self.Extensions[ID] or {}

        table.insert(self.Extensions[ID], Callback)
    end

    function self:InjectClassType(ID:string)
        table.insert(self.ClassTypes, ID)
    end

    function self:InjectPropertyExtension(Property:string, ReadTransform:((self:any, Value:any) -> nil)?, WriteTransform:((self:any, OldValue:any, Value:any) -> nil)?)
        if ReadTransform then
            self.Extensions[`_R/{Property}`] = self.Extensions[`_R/{Property}`] or {}

            table.insert(self.Extensions[`_R/{Property}`], ReadTransform)
        end

        if WriteTransform then
            self.Extensions[`_W/{Property}`] = self.Extensions[`_W/{Property}`] or {}

            table.insert(self.Extensions[`_W/{Property}`], ReadTransform)
        end
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
            Extensions = self.Extensions;
            ClassTypes = self.ClassTypes
        }
    end

    function self:GetPrivate(ID:string)
        return self.PrivateProperties[ID]
    end
    
    self.__index = self

    return self
end

return module