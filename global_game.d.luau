export type Instance = {
    Name:string;
    ClassName:string;
    ID:number;
    Changed:ReadOnlySignal<string, any>,
    Type:string;
    Destroyed:boolean;

    Destroy:(self:Instance) -> nil;
    Clone:(self:Instance) -> any;
    GetAttribute:(self:Instance, Attribute:string) ->  any;
    SetAttribute:(self:Instance, Attribute:string, Newvalue:any) ->  nil;
    GetAttributeChangedSignal:(self:Instance, Attribute:string) ->  ReadOnlySignal<any>;
    GetPropertyChangedSignal:(self:Instance, Property:string) ->  ReadOnlySignal<any>;
    IsA:(self:UI2D, Type:string)  -> boolean
}

export type UI2D = Instance & {
    Position:UDim;
    Size:UDim;
    AnchorPoint:UDim;
    Color:Color4;
    Rotation:number;
    Visible:boolean;
    ZIndex:number;
    Parent:UI2D | nil;
    CanQuery:boolean;
    SinkInputs:boolean;

    TouchBegan:ReadOnlySignal<UI2D>;
    TouchEnded:ReadOnlySignal<UI2D>;
    MouseClick:ReadOnlySignal<>;
    MouseRelease:ReadOnlySignal<>;
    MouseHoverBegin:ReadOnlySignal<>;
    MouseHoverRelease:ReadOnlySignal<>;

    GetPosition:(self:UI2D) -> (number, number);
    IsDescendantOf:(self:UI2D, Target:UI2D) -> boolean;
    GetChildren:(self:UI2D) -> {UI2D};
    GetDescendants:(self:UI2D) -> {UI2D};
}

export type Frame = UI2D & {
    GetAbsolute:(self:Frame) -> (number,  number, number,  number, number)
}



export type Connection = {
    Callback: (...any) -> (),
    IsConnected: boolean,
    Disconnect: (self: Connection) -> (),
}

export type Signal = {
    Connect: (self: Signal, Callback: (...any) -> ()) -> Connection,
    ConnectAsync: (self: Signal, Callback: (...any) -> ()) -> Connection,
    Wait: (self: Signal, timeout: number?) -> ...any,
    Fire: (self: Signal, ...any) -> (),
    Destroy: (self:Signal) -> nil
}

export type ReadOnlySignal<T...> = {
    Connect: (self: ReadOnlySignal<T...>, callback: (T...) -> ()) -> Connection,
    ConnectAsync: (self: ReadOnlySignal<T...>, callback: (T...) -> ()) -> Connection,
    Wait: (self: ReadOnlySignal<T...>, timeout: number?) -> (T...),
}

export type PropertyInject = {
    Name:string;
    Type:(string | {string})?;
    Value:any;

    ReadTransform:((self:any, Value:any) -> ...any)?,
    WriteTransform:((self:any, OldValue:any, Value:any) -> any)?
}

export type MethodInject = {
    Name:string;
    Code:(self:any) -> nil
}

export type SuperInject = {
    Properties:{
        PropertyInject
    };

    PrivateProperties:{
        [string]:any
    };


    Methods:{
        MethodInject
    };

    Extensions:{
        MethodInject
    };
}

export type UDim = {
    X: {Scale:number, Offset:number},
    Y:  {Scale:number, Offset:number},

    ToAbsolute:(self:UDim) -> (number, number)
}

export type Color4 = {
    R: number,
    G: number,
    B: number,
    A: number,

    GetSerial: (self:Color4) -> { R: number, G: number, B: number, A: number },
    GetColor: (self:Color4) -> (number, number, number, number)
}

export type RunService = {
    RenderStep:ReadOnlySignal<number>;
    HeartBeat:ReadOnlySignal<>;

    Quit:(self:RunService, Code:number)  -> nil
}

export type Types =  "Linear" | "Exponential" | "Cubic" | "Quart"| "Quint" | "Sine" | "Bounce" | "Back"| "Elastic"
export type Direciton = "In" | "Out"  | "InOut"

export type TweenInfo = {
    Time:number;
    EasingStyle:Types;
    EasingDirection:Direciton
}

export type TweenProperties = {
    [string]: any
}

export type Tween = {
    Instance: Instance,
    Time: number,
    Properties: TweenProperties,
    StartValues: TweenProperties,
    EndValues: TweenProperties,
    Completed: ReadOnlySignal<>,
    Play: (self: Tween) -> (),
}

export type TweenService = {
    Create: (self: TweenService, instance: Instance, info: TweenInfo, properties: TweenProperties) -> Tween
}

export type StoreEntry = {
    Key: string,
    Value: any
}

export type DataStore = {
    folder: string,
    SetAsync: (self: DataStore, key: string, value: any) -> (),
    GetAsync: (self: DataStore, key: string) -> any?,
    ListStores: (self: DataStore) -> {StoreEntry},
    UpdateAsync:(self:DataStore, Key:string,Callback:(OldData:any) -> any) -> nil
}

export type DataStoreService = {
    GetDataStore: (self: DataStoreService, DataStore: string?) -> DataStore,
    ListDataStores: (self: DataStoreService) -> {string},
}