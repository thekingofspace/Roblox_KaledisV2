local Game = require("@packages/Game")

local Task, Instance, Udim, Color4 = Game:GetCommonUtils()


local LeftFrame:UI2D = Instance.new("Frame")
LeftFrame.Size = Udim.FromScale(0.6, 0.6)
LeftFrame.Position = Udim.FromScale(0, 0.5) 
LeftFrame.AnchorPoint = Udim.FromScale(0, 0.5)
LeftFrame.Color = Color4.FromHex("#ab6a4f")


local RightFrame:UI2D = Instance.new("Frame")
RightFrame.Size = Udim.FromScale(0.6, 0.6)
RightFrame.Position = Udim.FromScale(1, 0.5) 
RightFrame.AnchorPoint = Udim.FromScale(1, 0.5)
RightFrame.Color = Color4.FromHex("#4f6aab")

RightFrame.TouchBegan:Connect(function(Instance)
    print(Instance)
end)

RightFrame.TouchEnded:Connect(function(Instance)
    print(Instance)
end)

Game.Workspace.Color = Color4.White()

Task.delay(8, function()
    RightFrame:Destroy()
end)

Game:BindToClose(function()
    print("goodbye")
end)
