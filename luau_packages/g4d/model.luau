--!nocheck
local g4d = require("@g4d/g4d")

local newMatrix = require("@g4d/matrices")
local loadObjFile = require("@g4d/objloader")
local collisions = require("@g4d/collisions")
local vectors = require("@g4d/vectors")
local camera = require("@g4d/camera")
local vectorCrossProduct = vectors.crossProduct
local vectorNormalize = vectors.normalize

local model = {}
model.__index = model

model.vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexTexCoord", "float", 2},
    {"VertexNormal", "float", 3},
    {"VertexColor", "byte", 4},
}
model.shader = g4d.shader

local function newModel(verts, texture, translation, rotation, scale)
    local self = setmetatable({}, model)
    if type(verts) == "string" then
        verts = loadObjFile(verts)
    end

    if type(texture) == "string" then
        texture = love.graphics.newImage(texture)
    end

    self.verts = verts
    self.texture = texture
    self.mesh = love.graphics.newMesh(self.vertexFormat, self.verts, "triangles")
    self.mesh:setTexture(self.texture)
    self.matrix = newMatrix()
    if type(scale) == "number" then scale = {scale, scale, scale} end
    self:setTransform(translation or {0,0,0}, rotation or {0,0,0}, scale or {1,1,1})

    return self
end

function model:makeNormals(isFlipped)
    for i=1, #self.verts, 3 do
        if isFlipped then
            self.verts[i+1], self.verts[i+2] = self.verts[i+2], self.verts[i+1]
        end

        local vp = self.verts[i]
        local v = self.verts[i+1]
        local vn = self.verts[i+2]

        local n_1, n_2, n_3 = vectorNormalize(vectorCrossProduct(v[1]-vp[1], v[2]-vp[2], v[3]-vp[3], vn[1]-v[1], vn[2]-v[2], vn[3]-v[3]))
        vp[6], v[6], vn[6] = n_1, n_1, n_1
        vp[7], v[7], vn[7] = n_2, n_2, n_2
        vp[8], v[8], vn[8] = n_3, n_3, n_3
    end

    self.mesh = love.graphics.newMesh(self.vertexFormat, self.verts, "triangles")
    self.mesh:setTexture(self.texture)
end


function model:setTransform(translation, rotation, scale)
    self.translation = translation or self.translation
    self.rotation = rotation or self.rotation
    self.scale = scale or self.scale
    self:updateMatrix()
end

function model:setTranslation(tx,ty,tz)
    self.translation[1] = tx
    self.translation[2] = ty
    self.translation[3] = tz
    self:updateMatrix()
end

function model:setRotation(rx,ry,rz)
    self.rotation[1] = rx
    self.rotation[2] = ry
    self.rotation[3] = rz
    self.rotation[4] = nil
    self:updateMatrix()
end


function model:setAxisAngleRotation(x,y,z,angle)
    x,y,z = vectorNormalize(x,y,z)
    angle = angle / 2

    self.rotation[1] = x * math.sin(angle)
    self.rotation[2] = y * math.sin(angle)
    self.rotation[3] = z * math.sin(angle)
    self.rotation[4] = math.cos(angle)

    self:updateMatrix()
end

function model:setQuaternionRotation(x,y,z,w)
    self.rotation[1] = x
    self.rotation[2] = y
    self.rotation[3] = z
    self.rotation[4] = w
    self:updateMatrix()
end

function model:setScale(sx,sy,sz)
    self.scale[1] = sx
    self.scale[2] = sy or sx
    self.scale[3] = sz or sx
    self:updateMatrix()
end

function model:updateMatrix()
    self.matrix:setTransformationMatrix(self.translation, self.rotation, self.scale)
end

function model:lookAtFrom(pos, target, up)
    local pos = pos or self.translation
    self.matrix:lookAtFrom(pos, target, up or {0,0,1}, self.scale)
end

function model:lookAt(target, up)
    self.matrix:lookAtFrom(self.translation, target, up or {0,0,1}, self.scale)
end




function model:draw(shader)
    local shader = shader or self.shader
    love.graphics.setShader(shader)
    shader:send("modelMatrix", self.matrix)
    shader:send("viewMatrix", camera.viewMatrix)
    shader:send("projectionMatrix", camera.projectionMatrix)
    if shader:hasUniform "isCanvasEnabled" then
        shader:send("isCanvasEnabled", love.graphics.getCanvas() ~= nil)
    end
    love.graphics.draw(self.mesh)
    love.graphics.setShader()
end

function model:compress()
    print("[g4d warning] Compression requires FFI!\n" .. debug.traceback())
end

local success, ffi = pcall(require, "ffi")
if success then
    ffi.cdef([[
        struct vertex {
            float x, y, z;
            float u, v;
            float nx, ny, nz;
            uint8_t r, g, b, a;
        }
    ]])

    function model:compress()
        local data = love.data.newByteData(ffi.sizeof("struct vertex") * #self.verts)
        local datapointer = ffi.cast("struct vertex *", data:getFFIPointer())

        for i, vert in ipairs(self.verts) do
            local dataindex = i - 1
            datapointer[dataindex].x  = vert[1]
            datapointer[dataindex].y  = vert[2]
            datapointer[dataindex].z  = vert[3]
            datapointer[dataindex].u  = vert[4] or 0
            datapointer[dataindex].v  = vert[5] or 0
            datapointer[dataindex].nx = vert[6] or 0
            datapointer[dataindex].ny = vert[7] or 0
            datapointer[dataindex].nz = vert[8] or 0
            datapointer[dataindex].r  = (vert[9] or 1)*255
            datapointer[dataindex].g  = (vert[10] or 1)*255
            datapointer[dataindex].b  = (vert[11] or 1)*255
            datapointer[dataindex].a  = (vert[12] or 1)*255
        end

        self.mesh:release()
        self.mesh = love.graphics.newMesh(self.vertexFormat, #self.verts, "triangles")
        self.mesh:setVertices(data)
        self.mesh:setTexture(self.texture)
        self.verts = nil
    end
end

function model:rayIntersection(...)
    return collisions.rayIntersection(self.verts, self, ...)
end

function model:isPointInside(...)
    return collisions.isPointInside(self.verts, self, ...)
end

function model:sphereIntersection(...)
    return collisions.sphereIntersection(self.verts, self, ...)
end

function model:closestPoint(...)
    return collisions.closestPoint(self.verts, self, ...)
end

function model:capsuleIntersection(...)
    return collisions.capsuleIntersection(self.verts, self, ...)
end

return newModel
