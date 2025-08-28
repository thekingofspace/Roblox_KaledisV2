local Game = require("@packages/Game")

local Task, Instance, Udim, Color4, TweenInfo, Enum = Game:GetCommonUtils()

local LeftFrame:UI2D = Instance.new("Frame")
LeftFrame.Size = Udim.FromScale(0.6, 0.6)
LeftFrame.Position = Udim.FromScale(0.5, 0.5) 
LeftFrame.AnchorPoint = Udim.FromScale(0.5, 0.5)
LeftFrame.Color = Color4.FromHex("#ab6a4f")

local RightFrame:UI2D = Instance.new("Frame")
RightFrame.Size = Udim.FromScale(0.6, 0.6)
RightFrame.Position = Udim.FromScale(0.5, 0.5) 
RightFrame.AnchorPoint = Udim.FromScale(0.5, 0.5)
RightFrame.Color = Color4.FromHex("#4f6aab")
RightFrame.Parent = LeftFrame

local TweenService = require("@game/Services/TweenService")


Task.spawn(function()
    local Tween = TweenService:Create(RightFrame, TweenInfo.New(2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Color = Color4.Black(),  Rotation = 360})

    Tween:Play()

    Tween.Completed:Wait()

    Task.wait(0.7)

    Tween = TweenService:Create(RightFrame, TweenInfo.New(5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Color = Color4.FromHex("#4f6aab"),  Rotation = 0})

    Tween:Play()
end)

--