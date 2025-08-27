export type Instance = {
    Name:string;
    ClassName:string;
    ID:number;
    Changed:ReadOnlySignal<string, any>,
    Type:string;

    Destroy:(self:Instance) -> nil;
    Clone:(self:Instance) -> any;
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
    IsA:(self:UI2D, Type:string)  -> boolean
}

export type Frame = UI2D & {
    GetAbsolute:(self:Frame) -> (number,  number, number,  number, number)
}