local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRIconMesh={Embed=Core.Embed}
AVRIconMesh.meshInfo={
	class="AVRIconMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Icon"],
	receivable=true
}
function AVRIconMesh:New(texture,size)
	if self ~= AVRIconMesh then return end
	local s=AVRMesh:New()
	AVRIconMesh:Embed(s)
	s.class=AVRIconMesh.meshInfo.class
	s.texture=texture
	s.size=size or 1000
	s.vertices=nil
	s.name=L["Icon"]
	s.a=0.8
	s.meshTranslateZ=4
	return s
end

function AVRIconMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.tex=self.texture
	s.siz=self.size
	return s
end

function AVRIconMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.texture=s.tex
	self.size=s.siz or 1000

	self.vertices=nil
end

function AVRIconMesh:SetSize(size)
	self.size=size
	self.vertices=nil
	return self
end
function AVRIconMesh:SetTexture(texture)
	self.texture=texture
	self.vertices=nil
	return self
end

function AVRIconMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.icon = {
		type = "group",
		name = L["Circle properties"],
		inline = true,
		order = 80,
		args = {
			texture = {
				type = "input",
				name = L["Texture"],
				order = 10,
				width = "full",
			},
			size = {
				type = "range",
				name = L["Size"],
				order = 20,
				width = "full",
				min = 500, max=5000, bigStep=100
			},
		}
	}
	return o
end


function AVRIconMesh:GenerateMesh()
	local texture = self.texture or 135815
	local size = self.size
	if texture then
		local t=self:AddIcon( 0,0,0,texture,size,nil,nil,nil)
	end
	--  t.rotateTexture=false
	AVRMesh.GenerateMesh(self)
end


AVR:RegisterMeshClass(AVRIconMesh)
