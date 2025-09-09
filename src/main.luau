local Game = require("@packages/Game")

local Task, Instance, Udim, Color4, TweenInfo, Enum = Game:GetCommonUtils()
local LogService:LogService = Game:GetService("LogService")
local UInput:UserInputService = Game:GetService("UserInputService")
local Mouse = UInput:GetMouse()
LogService:Clear()
LogService:Push("Program began running")

local LeftFrame:UI2D = Instance.new("Frame")
LeftFrame.Size = Udim.FromScale(0.6, 0.6)
LeftFrame.Position = Udim.FromScale(0.5, 0.5) 
LeftFrame.AnchorPoint = Udim.FromScale(0.5, 0.5)
LeftFrame.Color = Color4.FromHex("#ab6a4f")
LeftFrame:AddTag("Test")
LogService:Push("Created frame 1")
LeftFrame.ZIndex = 1
LeftFrame.Parent = Game.Workspace

local RightFrame:UI2D = Instance.new("Frame")
RightFrame.Size = Udim.FromScale(0.6, 0.6)
RightFrame.Position = Udim.FromScale(0.5, 0.5) 
RightFrame.AnchorPoint = Udim.FromScale(0.5, 0.5)
RightFrame.Color = Color4.FromHex("#4f6aab")
RightFrame.Parent = LeftFrame
RightFrame:AddTag("Test")
LogService:Push("Created frame 2")
local TweenService = require("@game/Services/TweenService")
RightFrame.ZIndex = 2

Game.Workspace.Color = Color4.FromHex("#41ff41")

Task.spawn(function()
    while true do
        LogService:Push("Started Loop")
        local Tween = TweenService:Create(RightFrame, TweenInfo.New(5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Color = Color4.Black(),  Rotation = 360})

        Tween:Play()

        Tween.Completed:Wait()

        Task.wait(1)

        Tween = TweenService:Create(RightFrame, TweenInfo.New(5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Color = Color4.FromHex("#4f6aab"),  Rotation = 0})

        Tween:Play()
        Tween.Completed:Wait()

        LogService:Push("Finished  Loop")

        Task.wait(1)
    end
end)

local CenterFrame = RightFrame:Clone()
CenterFrame.ZIndex = 3
CenterFrame:RemoveTag("Test")

CenterFrame.Parent = RightFrame

CenterFrame.MouseHoverBegin:Connect(function()
    Mouse:SetCursor(Enum.CursorType.hand)
end)


CenterFrame.MouseHoverRelease:Connect(function()
    Mouse:SetCursor(Enum.CursorType.arrow)
end)

local TestFrame:Frame = Instance.new("Frame")

TestFrame.Size = Udim.FromScale(0.2, 0.2)

TestFrame.AnchorPoint = Udim.FromScale(0.5, 0.5)

TestFrame.Position = Udim.FromScale(0.9, 0.5)
TestFrame.Parent = nil

CenterFrame.TouchBegan:Connect(function(Instance)
    if Instance == TestFrame then
        LogService:Push(CenterFrame, "Touched", TestFrame)
    end
end)

CenterFrame.MouseClick:Connect(function()
    LogService:Push(CenterFrame, "Has been clicked")
end)


LogService:Push("Program Concluded.")

Mouse.Scrolled:Connect(function(X, Y)
    if UInput:IsKeyDown(Enum.KeyInputs.leftshift) then
        if Y > 0 then
            CenterFrame.Size += Udim.FromScale(0.05, 0.05)
        else
            CenterFrame.Size -= Udim.FromScale(0.05, 0.05)
        end
    end
end)

Game.Workspace.Color = Color4.FromHex("#41ff41")