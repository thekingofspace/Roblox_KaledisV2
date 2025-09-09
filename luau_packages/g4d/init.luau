local G4D_Static = require("@self/g4d")
local G4D = {}

G4D_Static.shader = love.graphics.newShader("assets/shaders/g3d.vert")

G4D.newModel = require("@self/model")
G4D.camera = require("@self/camera")
G4D.camera.updateProjectionMatrix()
G4D.camera.updateViewMatrix()
G4D.vectors = require("@self/vectors")
G4D.collisions = require("@self/collisions")
G4D.loadObj = require("@self/objloader")

love.graphics.setDepthMode("lequal", true)

return G4D
