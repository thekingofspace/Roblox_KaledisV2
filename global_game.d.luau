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
    Destroy: (self:Signal) -> nil,
    AddConstructor: (self:Signal ,Callback: (...any) -> ...any) -> nil
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
    Code:(self:any, ...any) -> nil
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

export type CollectionService = {
	Tagged: { [string]: { [Instance?]: true } },

	AddTag: (self: CollectionService, Instance: Instance?, Tag: string) -> (),
	RemoveTag: (self: CollectionService, Instance: Instance?, Tag: string) -> (),
	GetTagged: (self: CollectionService, Tag: string) -> { Instance? },
	DropTag: (self: CollectionService, Tag: string) -> (),
}

export type LogService = {
    Push: (self: LogService, ...any) -> (),
    Clear: (self: LogService) -> ()
}

export type Mouse = {
    X:number;
    Y:number;
    Visible:boolean;
    Cursor:string;

    Clicked: ReadOnlySignal<number, number, string>;
    Release: ReadOnlySignal<number, number, string>;
    Moved: ReadOnlySignal<number, number, number, number>;
    Scrolled: ReadOnlySignal<number, number>;

    SetCursor:(self:Mouse) -> nil
}

export type UserInputService = {
    InputBegan: ReadOnlySignal <string>;
    InputReleased: ReadOnlySignal <string>;

    GetMouse:(self:UserInputService) -> Mouse;
    GetScanCode:(self:UserInputService, KeyCode:string) -> string;
    GetKeyCode:(self:UserInputService, ScanCode:string) -> string;
    IsKeyDown:(self:UserInputService, KeyCode:string) -> boolean;
}

export type EncodeTypes = "json" | "toml"

export type EncodeService = {
    Encode:(self:EncodeService, Type:EncodeTypes, Data:any, Pretty:boolean?) -> string;
    Decode:(self:EncodeService, Type:EncodeTypes, Data:string) -> any
}

export type MetaData = {
    Updated: number,
    Expires: number,
    Key: string,
    Score: number?,
}

export type Entry<T = any> = {
    Data: T,
    MetaData: MetaData
}

export type SortedMap<T = any> = {
    GetAsync: (self: SortedMap<T>, Key: string) -> (T?, number),
    SetAsync: (self: SortedMap<T>, Key: string, Value: T, Expire: number, Score: number?) -> (),
    RemoveAsync: (self: SortedMap<T>, Key: string) -> (),
    ListAsync: (self: SortedMap<T>, reverse: boolean?) -> { Entry<T> },
    Drop: (self: SortedMap<T>) -> (),
}

export type HashMap<T = any> = {
    GetAsync: (self: HashMap<T>, Key: string) -> (T?, number),
    SetAsync: (self: HashMap<T>, Key: string, Value: T, Expire: number) -> (),
    RemoveAsync: (self: HashMap<T>, Key: string) -> (),
    ListAsync: (self: HashMap<T>) -> { Entry<T> },
    Drop: (self: HashMap<T>) -> (),
}

export type MemoryStoreService = {
    GetSortedMap: (self: MemoryStoreService, MapName: string) -> SortedMap<any>,
    GetHashMap: (self: MemoryStoreService, MapName: string) -> HashMap<any>,
}

type ClassName =
"UI_Element" | "Instance" | "Parentable" |
"Frame" | "BindableEvent" | "Sink" |
"UI_Group"


declare class Instance
    Name: string
    ClassName: string
    ID: number
    Type: string
    Destroyed: boolean

    Changed: ReadOnlySignal<string, any>
    Destroying: ReadOnlySignal<>

    Destroy: (self: Instance) -> ()
    Clone: <T>(self: T) -> T
    GetAttribute: (self: Instance, Attribute: string) -> any
    SetAttribute: (self: Instance, Attribute: string, Newvalue: any) -> ()
    GetAttributeChangedSignal: (self: Instance, Attribute: string) -> ReadOnlySignal<any>
    GetPropertyChangedSignal: (self: Instance, Property: string) -> ReadOnlySignal<any>
    IsA: (self: Instance, Type: ClassName | string) -> boolean
    AddTag: (self: Instance, Tag: string) -> ()
    RemoveTag: (self: Instance, Tag: string) -> ()
    HasTag: (self: Instance, Tag: string) -> (boolean)
end

declare class Parentable extends Instance
    Parent: any

    ChildAdded: ReadOnlySignal<any>
    ChildRemoved: ReadOnlySignal<any>
    DescendantAdded: ReadOnlySignal<any>
    DescendantRemoved: ReadOnlySignal<any>

    IsDescendantOf: (self: Parentable, Target: any) -> (boolean)
    GetChildren: (self: Parentable) -> ({any})
    GetDescendants: (self: Parentable) -> ({any})
    FindFirstChild: (self: Parentable, ChildName:string) -> (any?)
    WaitForChild: (self: Parentable, ChildName:string, Timeout:number?) -> (any?)
end

declare class UI2D extends Parentable
    Position: UDim
    Size: UDim
    AnchorPoint: UDim
    Color: Color4
    Rotation: number
    Visible: boolean
    ZIndex: number
    CanQuery: boolean
    SinkInputs: boolean

    TouchBegan: ReadOnlySignal<UI2D>
    TouchEnded: ReadOnlySignal<UI2D>
    MouseClick: ReadOnlySignal<string>
    MouseRelease: ReadOnlySignal<string?>
    MouseHoverBegin: ReadOnlySignal<>
    MouseHoverRelease: ReadOnlySignal<>

    GetPosition: (self: UI2D) -> (number, number)
    GetAbsolute: (self: UI2D) -> (number, number, number, number, number)
    IsWithin: (self: UI2D, X:number, Y:number) -> (boolean)
end

declare class Frame extends UI2D

end

declare class UI_Group extends Parentable
    Visible: boolean
end

declare class BindableEvent extends Instance
    Event: ReadOnlySignal<any>

    Fire: (self: BindableEvent, ...any) -> ()
end

declare class Sink extends Instance
    StackSize:number

    Push:(self:Sink, Value:any) -> (nil)
    Pop:(self:Sink, Index:number?) -> (nil)
    Peek:(self:Sink) -> (any)
    Process:(self:Sink, Callback:(any) -> nil) -> (nil)
    Find:(self:Sink, Predicate:(any) -> boolean) -> (boolean)
end