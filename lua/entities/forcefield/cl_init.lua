ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
include("shared.lua")
local TextCantEdit = ForceField.Lang.cant_edit_otherplayer
local TextInvalidPlayer = ForceField.Lang.invalidplayer
local TextEnabled = ForceField.Lang.enabled
local TextDisabled = ForceField.Lang.disabled

function ENT:CSUse()
    local Owner = self:Getowning_ent()

    if Owner == LocalPlayer() or LocalPlayer():IsAdmin() then
        ForceField.EditAccess(self:EntIndex())
    else
        local Name = Owner and Owner:IsValid() and Owner:Nick() or TextInvalidPlayer
        notification.AddLegacy(string.format(TextCantEdit, Name), NOTIFY_GENERIC, 5)
    end
end

local function CompileFieldPoly(W, H, Round, TextureScaleX, TextureScaleY, ShiftX, ShiftY)
    if W < Round * 2 then
        W = Round * 2
    end

    if H < Round * 2 then
        H = Round * 2
    end

    local Verts = {}
    local X, Y = W - Round, H - Round

    for I = 0, 32 do
        local Ang = (I / 32) * (math.pi * 2)

        if I == 8 then
            X, Y = Round, H - Round
        elseif I == 16 then
            X, Y = Round, Round
        elseif I == 24 then
            X, Y = W - Round, Round
        end

        table.insert(Verts, {
            x = X + math.cos(Ang) * Round,
            y = Y + math.sin(Ang) * Round
        })
    end

    if not TextureScaleY then
        TextureScaleY = TextureScaleX
    end

    for I, Vertex in pairs(Verts) do
        Vertex.u = (Vertex.x + (ShiftX or 0)) / TextureScaleX
        Vertex.v = (Vertex.y + (ShiftY or 0)) / TextureScaleY
        Vertex.x = Vertex.x - W / 2
        Vertex.y = Vertex.y - H / 2
    end

    return Verts
end

local TextureScale = 30

function ENT:UpdateFieldModel()
    local W, H = self:GetWidth(), self:GetHeight()
    self.VertexPolygon = CompileFieldPoly(W - 4, H - 4, 8, W - 4, H - 4, 0, 0)
    self.VertexPolygonOutline = CompileFieldPoly(W, H, 8, 16)

    if self.Frame and self.Frame.Destroy then
        self.Frame:Destory()
    end

    local Frame = Mesh()
    local Triangles = {}

    for I, Cur in pairs(self.VertexPolygon) do
        local CurN = self.VertexPolygonOutline[I]
        local Next = self.VertexPolygon[I + 1]
        local NextN = self.VertexPolygonOutline[I + 1]

        if not Next then
            Next = self.VertexPolygon[1]
            NextN = self.VertexPolygonOutline[1]
        end

        table.insert(Triangles, {
            pos = Vector(-2, CurN.x, CurN.y)
        })

        table.insert(Triangles, {
            pos = Vector(2, CurN.x, CurN.y)
        })

        table.insert(Triangles, {
            pos = Vector(2, NextN.x, NextN.y)
        })

        table.insert(Triangles, {
            pos = Vector(-2, CurN.x, CurN.y)
        })

        table.insert(Triangles, {
            pos = Vector(2, NextN.x, NextN.y)
        })

        table.insert(Triangles, {
            pos = Vector(-2, NextN.x, NextN.y)
        })

        table.insert(Triangles, {
            pos = Vector(2, CurN.x, CurN.y)
        })

        table.insert(Triangles, {
            pos = Vector(0, Cur.x, Cur.y)
        })

        table.insert(Triangles, {
            pos = Vector(0, Next.x, Next.y)
        })

        table.insert(Triangles, {
            pos = Vector(2, CurN.x, CurN.y)
        })

        table.insert(Triangles, {
            pos = Vector(0, Next.x, Next.y)
        })

        table.insert(Triangles, {
            pos = Vector(2, NextN.x, NextN.y)
        })

        table.insert(Triangles, {
            pos = Vector(-2, CurN.x, CurN.y)
        })

        table.insert(Triangles, {
            pos = Vector(0, Next.x, Next.y)
        })

        table.insert(Triangles, {
            pos = Vector(0, Cur.x, Cur.y)
        })

        table.insert(Triangles, {
            pos = Vector(-2, CurN.x, CurN.y)
        })

        table.insert(Triangles, {
            pos = Vector(-2, NextN.x, NextN.y)
        })

        table.insert(Triangles, {
            pos = Vector(0, Next.x, Next.y)
        })
    end

    for I, Vertex in pairs(Triangles) do
        Vertex.u = Vertex.pos.y / TextureScale
        Vertex.v = Vertex.pos.z / TextureScale
        Vertex.normal = Vector(Vertex.pos.x, 0, 0):GetNormalized()
    end

    Frame:BuildFromTriangles(Triangles)
    self.Frame = Frame
end

function ENT:Initialize()
    self:SetModel("models/effects/teleporttrail.mdl")
    self:PhysInitField()
    self:UpdateFieldModel()
end

function ENT:Unmount()
    ForceField.UnmountField(self)
end

local FrameMat = Material("xeon133/testtexture")

function ENT:Draw()
    render.SetBlend(0)
    self:DrawModel()
    render.SetBlend(1)

    for Yaw = -90, 90, 180 do
        cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 0)), self:LocalToWorldAngles(Angle(0, Yaw, 90)), 1)
        surface.SetMaterial(ForceField.BaseMat)
        surface.SetDrawColor(ForceField.FieldBaseColor)
        surface.DrawPoly(self.VertexPolygon)
        surface.SetMaterial(ForceField.OverlayMat)
        surface.SetDrawColor(LocalPlayer():CanPassField(self) and ForceField.FieldAllowColor or ForceField.FieldRestrictColor)
        surface.DrawPoly(self.VertexPolygon)
        cam.End3D2D()
    end

    local Transform = Matrix()
    Transform:Translate(self:GetPos())
    Transform:Rotate(self:GetAngles())
    cam.PushModelMatrix(Transform)
    render.SetMaterial(FrameMat)
    self.Frame:Draw()

    if LocalPlayer():FlashlightIsOn() then
        render.PushFlashlightMode(true)
        self.Frame:Draw()
        render.PopFlashlightMode()
    end

    cam.PopModelMatrix()
end

local UnknownPlayer = "unknown player"

function ForceField.DrawCrosshairInfo()
    local Tr = LocalPlayer():GetEyeTrace()
    local Field = Tr.Entity
    if not (Field and Field:IsValid() and Field.ClassName == "forcefield") then return end
    local Owner = Field:Getowning_ent()
    local OwnerName = Owner and Owner:IsValid() and Owner:Nick() or UnknownPlayer
    local CX, CY = ScrW() / 2, ScrH() / 2
    local OwnerInfo = ForceField.DisplayFieldOwner and " (" .. OwnerName .. ")" or ""
    ForceField.DrawHint(CX, CY - 30, "Force Field" .. OwnerInfo .. " [" .. (Field:GetEnabled() and TextEnabled or TextDisabled) .. "]")

    if ForceField.MaxHealth and ForceField.DisplayFieldHealth then
        ForceField.DrawHint(CX, CY - 10, "Health: " .. tostring(Field:Health()))
    end
end

hook.Add("HUDPaint", "ForceField.CrosshairInfo", ForceField.DrawCrosshairInfo)