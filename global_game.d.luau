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