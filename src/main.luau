local Game = require("@packages/Game")

local Task, Instance, Udim, Color4 = Game:GetCommonUtils()

local NewFrame:UI2D = Instance.new("Frame")

NewFrame.Size = Udim.FromScale(0.5, 0.5)
NewFrame.Position = Udim.FromScale(0.5, 0.5)
NewFrame.AnchorPoint = Udim.FromScale(0.5, 0.5)
NewFrame.Color = Color4.FromHex("#ab6a4f")
NewFrame.Rotation = 43

local SecondFrame:Frame = NewFrame:Clone()

SecondFrame.Parent  = NewFrame

SecondFrame.Size = Udim.FromScale(0.9, 0.9)
SecondFrame.Rotation = 0

SecondFrame.Color = Color4.FromHex("#77e09c")

Game.Workspace.Color = Color4.White()

Task.spawn(function()
    while true do
        if SecondFrame.Destroyed ~= true then
            SecondFrame.Rotation += 0.5
        end
        
        NewFrame.Rotation -= 0.25
        Task.wait(0.03)
    end
end)


Task.delay(5, function()
    SecondFrame:Destroy()
end)