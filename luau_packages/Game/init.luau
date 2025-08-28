local Game = {}
local SignalStorage = require("@self/SignalStorage")
local Signal = require("@self/Vendors/signal")

SignalStorage.HeartBeat = Signal.CreateSignal()
SignalStorage.RenderStep = Signal.CreateSignal()

local Injects = {
    ["Draw"] = {
        require("@self/Injections/DrawInjects/Draw");
        require("@self/Injections/DrawInjects/Check");
    };

    ["Update"] = {

    }
}

local Task = require("@self/KeyWords/Task")
local Instance = require("@self/KeyWords/Instance")
local TweenInfo = require("@self/KeyWords/TweenInfo")
local Enum = require("@self/KeyWords/Enum")

local UDIM = require("@self/Types/Udim")
local Color4 = require("@self/Types/Color4")

local GetService = require("@self/ServiceGetter")

function Game:GetCommonUtils()
    return Task, Instance, UDIM, Color4, TweenInfo, Enum
end

local lastTime = love.timer.getTime()

function love.draw()
    local currentTime = love.timer.getTime()
    local dt = currentTime - lastTime
    lastTime = currentTime

    for I, item in pairs(Injects.Draw) do
        item(dt)
    end

    SignalStorage.RenderStep:Fire(dt)
end

function love.update()
    for I, item in pairs(Injects.Update) do
        item()
    end

    SignalStorage.HeartBeat:Fire()
end

Game.Workspace = Instance.new("Frame")::UI2D

Game.Workspace.AnchorPoint = UDIM.FromScale(0.5, 0.5)
Game.Workspace.Size = UDIM.FromScale(1, 1)
Game.Workspace.Position = UDIM.FromScale(0.5, 0.5)
Game.Workspace.Color = Color4.Black()
Game.Workspace.Name = "Workspace"
Game.Workspace.ZIndex =  -999
Game.Workspace.CanQuery = false
Game.Workspace.SinkInputs = false

function Game:BindToClose(Callback:() -> nil)
    function love.quit()
        Callback()
    end
end


function Game:GetService(Service:GetService.Services)
   return GetService(Service)
end


return Game