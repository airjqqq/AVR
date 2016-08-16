local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRPolygonMesh={Embed=Core.Embed}
AVRPolygonMesh.meshInfo={
	class="AVRPolygonMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Icon"],
	receivable=true
}
function AVRPolygonMesh:New(line,outalpha,inalpha)
	if self ~= AVRPolygonMesh then return end
	local s=AVRMesh:New()
	AVRPolygonMesh:Embed(s)
	s.class=AVRPolygonMesh.meshInfo.class
	s.line=line
	s.oa=outalpha or 0.2
	s.ia=inalpha or 0.4
	s.vertices=nil
	s.name=L["Polygon"]
	return s
end

function AVRPolygonMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.lin=self.line
	s.oa=self.oa
	s.ia=self.ia
	return s
end

function AVRPolygonMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.lin
	self.oa=s.oa
	self.ia=s.ia

	self.vertices=nil
end

function AVRPolygonMesh:SetLine(line)
	self.line=line
	self.vertices=nil
	return self
end
function AVRPolygonMesh:AddPoint(point)
	tinsert(self.line,point)
	self.vertices=nil
	return self
end

function AVRPolygonMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.polygon = {
		type = "group",
		name = L["Polygon"],
		inline = true,
		order = 80,
		args = {
			oa = {
				type = "range",
				name = L["Appha"],
				order = 10,
				width = "full",
				min = 0, max=1, bigStep=0.02
			},
			ia = {
				type = "range",
				name = L["InsideAppha"],
				order = 20,
				width = "full",
				min = 0, max=1, bigStep=0.02
			},
		}
	}
	return o
end


function AVRPolygonMesh:GenerateMesh()
	local line=self.line
	if #line>=3 then
		local o,s = line[1],line[2]
		for i=3,#line then
			local n = line[i]
			self:AddTriangle(o[1],o[2],o[3],s[1],s[2],s[3],n[1],n[2],n[3])
			s=n
		end
	end
	AVRMesh.GenerateMesh(self)
end

function AVRPolygonMesh:OnUpdate(threed)
	if self.vertices==nil or self.lines==nil or self.triangles==nil or self.textures==nil then
		self.vertices={}
		self.lines={}
		self.triangles={}
		self.textures={}
		self.icons={}
		self:GenerateMesh()
	end
	if self.oa or self.ia then
		local px,py,pz=threed.playerPosX,threed.playerPosY,threed.playerPosZ
		local vs = self.vertices
		local s=vs[#vs]
		local inside=false
		for i,v in ipairs(vs) do
			local e = v
			if py>s[2] and py<=e[2] or py>e[2] and py<=s[2] then
				local l,r = (px-s[1])*(e[2]-s[2]),(py-s[2])*(e[1]-s[1])
				if e[2]>s[2] and l>r or e[2]<s[2] and l<r then
					inside = not inside
				end
			end
			s=e
		end
		if inside then
			self.a=self.ia
		else
			self.a=self.oa
		end
	end
end

AVR:RegisterMeshClass(AVRPolygonMesh)
