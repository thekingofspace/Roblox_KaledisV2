local module =  {}
local InstanceStorage = require("@game/InstanceStorage")
local ID_Generator = require("@game/ID_Generator")
local SignalStorage = require("@game/SignalStorage")
local Signals = require("@game/Vendors/signal")
local Task = require("@game/KeyWords/Task")
local CollectionService = require("@game/Services/CollectionService")

local function CheckType(ID: string, Value, Properties)
    local prop = Properties[ID]

    if prop == "frozen" then
        return false, prop
    end

    if typeof(prop) == "string" then
        if typeof(Value) == "table" and Value.Type ~= nil then
            return Value.Type == prop, prop
        else
            return typeof(Value) == prop, prop
        end
    end

    if typeof(prop) == "table" then
        for _, item in ipairs(prop) do
            if typeof(Value) == item then
                return true, prop
            end
        end

        for _, item in ipairs(prop) do
            if typeof(Value) == "table" and item == Value.Type then
                return true, prop
            end
        end

        return false, prop
    end

    return false, prop
end

local Property_Types = {
    Name = "string";
    ClassName = "frozen",
    ID = "frozen",
    Changed = "frozen",
    Type = "string"
}

local function HandleEXTS(self, Key:string, Extensions, Passed)
    if Extensions[Key] then
        if typeof(Extensions[Key]) == "table" then
            local Returns = {}
            for I, item in ipairs(Extensions[Key]) do
                for I, item in ipairs({Returns, item(self, unpack(Passed))}) do
                    table.insert(Returns, item)
                end
            end

            return unpack(Returns)
        else
            return Extensions[Key](self, unpack(Passed))
        end
    end

    return 
end

function module.new(SuperInject:() -> SuperInject)
    local self  = {}

    local RealSelf = {}

    RealSelf.ExposedValues = {
        Changed_Signal = Signals.CreateSignal();
        Destroyed = false;
        Tags = {};
        Attribute = {};
        ChangedSignals_AT = {};
        ChangedSignals_PR = {}
    }

    RealSelf.Properties = {
        Name = "Instance";
        ClassName = "Instance";
        ID = ID_Generator:GetUniqueID();
        Changed = Signals.CreateReadOnlySignal(RealSelf.ExposedValues.Changed_Signal),
        Type = "instance"
    }

    RealSelf.HookedTypes = {}
    RealSelf.Overides = {}

    RealSelf.Transforms = {
        Read = {};

        Write = {}
    }

    RealSelf.ClassTypes = {"Instance"}

    RealSelf.Methods = {
        Destroy = function(self)
            if self.Destroyed == true then
                return
            end

            Task.spawn(function()
                if self.Draw ~= nil then
                    InstanceStorage.Drawable[self.ID] = nil
                    SignalStorage.RenderStep:Wait()
                else
                    InstanceStorage.Logic[self.ID] = nil
                end

                while #self.Tags ~= 0 do 
                    CollectionService:RemoveTag(self, self.Tags[1])
                end

                HandleEXTS(self, "Destroy", RealSelf.Overides, {})

                for I, item:Signal in ipairs(RealSelf.ExposedValues.ChangedSignals_AT) do
                    item:Destroy()
                end

                for I, item:Signal in ipairs(RealSelf.ExposedValues.ChangedSignals_PR) do
                    item:Destroy()
                end

                RealSelf.ExposedValues.Changed_Signal:Destroy()
                table.clear(RealSelf.Properties)
                table.clear(RealSelf.HookedTypes)
                table.clear(RealSelf.Methods)
                table.clear(RealSelf.Transforms)
                table.clear(RealSelf.Overides)
                table.clear(RealSelf.ExposedValues)

                RealSelf.ExposedValues.Destroyed = true
            end)
        end,

        Clone = function(self)
            local Clone = module.new(SuperInject)

            for I, item in pairs(RealSelf.HookedTypes) do
                if item ~= "frozen" then
                    if RealSelf.Transforms.Read[I] then
                       Clone[I] = RealSelf.Transforms.Read[I](RealSelf.Properties[I])
                    else
                        Clone[I] = RealSelf.Properties[I]
                    end
                end
            end

            HandleEXTS(self, "Clone", RealSelf.Overides, {Clone})

            return Clone
        end,

        PrivateAccess = function(self, Transform:(RealSelf:any) -> any)
            RealSelf = Transform(RealSelf)
        end;

        GetAttribute = function(self,  Attribute:string)
            return  self.Attribute[Attribute]
        end;

        SetAttribute = function(self,  Attribute:string, NewValue:any)
            self.Attribute[Attribute] = NewValue

            if self.ChangedSignals_AT[Attribute] then
                self.ChangedSignals_AT[Attribute]:Fire(NewValue)
            end
        end;

        GetAttributeChangedSignal = function(self, Attribute:string)
            if self.ChangedSignals_AT[Attribute] then
                return self.ChangedSignals_AT[Attribute]
            end

            local Changed = Signals.CreateSignal()
            
            self.ChangedSignals_AT[Attribute] = Changed

            return Signals.CreateReadOnlySignal(Changed)
        end;

        GetPropertyChangedSignal = function(self, Property:string)
            if self.ChangedSignals_PR[Property] then
                return self.ChangedSignals_PR[Property]
            end

            local Changed = Signals.CreateSignal()
            
            self.ChangedSignals_PR[Property] = Changed

            return Signals.CreateReadOnlySignal(Changed)
        end;

        IsA = function(self, Type:string)
            return self.ClassName == Type or table.find(RealSelf.ClassTypes, Type) ~= nil
        end;

        AddTag = function(self, Tag:string)
            CollectionService:AddTag(self, Tag)
        end;

        RemoveTag = function(self, Tag:string)
            CollectionService:RemoveTag(self, Tag)
        end;

        HasTag = function(self, Tag:string)
            return table.find(self.Tags, Tag) == nil
        end
    }

    for I, item in pairs(Property_Types) do
        RealSelf.HookedTypes[I] = item
    end

    if SuperInject then
       local SuperData = SuperInject()

       if SuperData.Properties then
            for I, item in ipairs(SuperData.Properties) do
                RealSelf.Properties[item.Name] = item.Value;

                RealSelf.HookedTypes[item.Name] = item.Type or typeof(item.Value)

                if item.ReadTransform then
                    RealSelf.Transforms.Read[item.Name] = function(self, Value)
                        HandleEXTS(self, `_R/{item.Name}`, RealSelf.Overides, {Value})

                        return item.ReadTransform(self, Value)
                    end
                end

                if item.WriteTransform then
                    RealSelf.Transforms.Write[item.Name] = function(self, OldValue, NewValue)
                        HandleEXTS(self, `_W/{item.Name}`, RealSelf.Overides, {OldValue, NewValue})

                        return item.WriteTransform(self, OldValue, NewValue)
                    end
                end
            end
       end

       if SuperData.PrivateProperties then
            for I, item in pairs(SuperData.PrivateProperties) do
                RealSelf.ExposedValues[I] = item
            end
       end

        if SuperData.Methods then
            for I, item in ipairs(SuperData.Methods) do
                RealSelf.Methods[item.Name] = function(self, ...)
                    HandleEXTS(self, item.Name, RealSelf.Overides, {...})

                    return item.Code(self, ...)
                end
            end
        end

        if SuperData.Extensions then
            for I, item in pairs(SuperData.Extensions) do
                RealSelf.Overides[I] = item
            end
        end

        if SuperData.ClassTypes then
            for I, item in ipairs(SuperData.ClassTypes) do
                table.insert(RealSelf.ClassTypes, item)
            end
        end
    end
    
    local  MT = {}

    MT.__newindex = function(self, Index:string,  NewValue)
        if RealSelf.ExposedValues[Index] ~= nil then
            RealSelf.ExposedValues[Index] = NewValue
        end

        if RealSelf.Properties[Index] == nil then
            error(`{Index} Is not a property of {RealSelf.Properties.ClassName}`)
        end

        local Passed, Type = CheckType(Index, NewValue, RealSelf.HookedTypes)

        if Passed  == true then
            local FinalValue = NewValue

            if RealSelf.Transforms.Write[Index] then
                FinalValue = RealSelf.Transforms.Write[Index](self, RealSelf.Properties[Index], NewValue)
            end

            RealSelf.Properties[Index] = FinalValue

            RealSelf.ExposedValues.Changed_Signal:Fire(Index, NewValue)


            if self.ChangedSignals_PR[Index] then
                self.ChangedSignals_PR[Index]:Fire(NewValue)
            end
        else
            if Type == "frozen" then
                error(`{Index} Is only read only.`)
            end

            if typeof(Type) == "table" then
                error(`You can only use {table.concat(Type, ", ")} for {Index}`)
            else
                error(`You can only use {Type} for {Index}`)
            end
        end

        return
    end

    MT.__index = function(self, Index:string)
        if RealSelf.ExposedValues.Destroyed == true then
            if Index  ==  "Destroyed" then
                return true
            else
                return nil
            end
        else
            if RealSelf.Properties[Index] ~= nil then
                if RealSelf.Transforms.Read[Index] then
                    return RealSelf.Transforms.Read[Index](self, RealSelf.Properties[Index])
                else
                    return RealSelf.Properties[Index]
                end
            elseif RealSelf.Methods[Index] ~= nil then
                return RealSelf.Methods[Index]

            elseif RealSelf.ExposedValues[Index] ~= nil then
                return RealSelf.ExposedValues[Index]
            end

            return
        end
    end

    MT.__eq = function(self, Instance)
        if typeof(Instance) ==  "table" then
            return Instance.ID == self.ID
        else
            return false
        end
    end

    MT.__tostring =  function(self)
        return `{self.Name} {self.ID}`
    end

    MT.__len = function()
        return nil
    end

    MT.__iter = function()
        error("You can not iterate a instance.")
    end

    self = setmetatable(self, MT)

    if self.Draw then
        InstanceStorage.Drawable[self.ID] = self
    else
        InstanceStorage.Logic[self.ID] = self
    end

    return self
end

return module