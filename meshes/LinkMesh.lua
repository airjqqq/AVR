local ADDON_NAME="AVR"
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, true)

local _G = _G
local sin = math.sin
local cos = math.cos
local pi = math.pi

local Core=AVR

local unpackDouble=AVRUnpackDouble
local packDouble=AVRPackDouble

AVRLinkMesh={Embed=Core.Embed}
AVRLinkMesh.meshInfo={
	class="AVRLinkMesh",
	derived=false,
	guiCreateNew=true,
	guiName=L["Link"],
	receivable=true
}
function AVRLinkMesh:New(target,width,alpha)
	if self ~= AVRLinkMesh then return end
	local s=AVRMesh:New()
	AVRLinkMesh:Embed(s)
	s.class=AVRLinkMesh.meshInfo.class
	s.vertices=nil
	s.name=L["Link"]
	s.maxlength = 100
	s.followPlayer = true
	s.target = target or "target"
	s.width = width or 0.4
	s.blank = 8
	s.num = 7
	s.a = alpha or 0.5
	return s
end

function AVRLinkMesh:Pack()
	local s=AVRMesh.Pack(self)
	s.tar=self.target
	s.wid=self.width
	s.clc=self.classColor
	s.bla=self.blank
	s.num=self.num
	return s
end

function AVRLinkMesh:Unpack(s)
	AVRMesh.Unpack(self,s)
	self.target=s.tar or "target"
	self.width=s.wid or 0.4
	self.classColor=s.clc
	self.blank=s.bla or 8
	self.num=s.num or 7


	self.vertices=nil
end

function AVRLinkMesh:SetWidth(width)
	self.width=width
	self.vertices=nil
	return self
end
function AVRLinkMesh:SetTarget(target)
	if strsub(target,1,1) == "!" then
		target = UnitGUID(strsub(target,2))
	end
	self.target=target
	self.vertices=nil
	return self
end
function AVRMarkerMesh:SetClassColor(value)
	self.classColor=value
end
function AVRMarkerMesh:GetClassColor()
	return self.classColor
end

function AVRLinkMesh:GetOptions()
	local o=AVRMesh.GetOptions(self)
	o.args.link = {
		type = "group",
		name = L["Circle properties"],
		inline = true,
		order = 80,
		args = {
			target = {
				type = "input",
				name = L["Target"],
				order = 10,
				width = "full",
			},
			classColor = {
				type = "toggle",
				name = L["Class color"],
				order = 20,
				width = "full"
			},
			width = {
				type = "range",
				name = L["Width"],
				order = 30,
				width = "full",
				min = 0.04, max=10, bigStep=0.02
			},
			blank = {
				type = "range",
				name = L["Blank"],
				order = 40,
				width = "full",
				min = 0, max=10, bigStep=0.1
			},
			num = {
				type = "range",
				name = L["Number"],
				order = 50,
				width = "full",
				min = 0, max=100, bigStep=1
			},
		}
	}
	return o
end


function AVRLinkMesh:GenerateMesh()
	self.v1=self:AddVertex(0,0,0)
	self.v2=self:AddVertex(1,0,0)
	self.v3=self:AddVertex(0,1,0)
	self.v4=self:AddVertex(1,1,0)
	self.v5=self:AddVertex(1,1,1)
	local t1 = AVRTriangle:New(self.v1,self.v2,self.v3)
	local t2 = AVRTriangle:New(self.v4,self.v2,self.v3)
	self:AddTriangle(t1)
	self:AddTriangle(t2)
	local text1 = AVRText:New(self.v5)
	text1.a = 1
	text1.size = 800
	text1.oy = 0
	self:AddText(text1)
	self.tri1=t1
	self.tri2=t2
	self.text1=text1
	-- AVRMesh.GenerateMesh(self)
end

function AVRLinkMesh:OnUpdate(threed)
	if self.classColor then
		local	_,cls=UnitClass(self.target)
		if cls then
			local c=RAID_CLASS_COLORS[cls]
			if c then self:SetColor(c.r,c.g,c.b)
			else self:SetColor(1.0,1.0,1.0) end
		end
	end
	if self.vertices==nil or self.lines==nil or self.triangles==nil or self.textures==nil then
		self.vertices={}
		self.lines={}
		self.triangles={}
		self.textures={}
		self.icon={}
		self:GenerateMesh()
	end
	local px,py,pz=threed.playerPosX,threed.playerPosY,threed.playerPosZ
	local sx,sy,sz = 0,0,0
	if self.followUnit then
		threed:GetUnitPosition(self.followUnit)
	end
	if not (sx==0 and sy==0 and sz==0) then
		sx,sy,sz=sx-px,sy-py,sz-pz
	end
	local tx,ty,tz=0,0,0
	if self.target then
		if self.target="point" then
			tx,ty,tz=self.meshTranslateX，self.meshTranslateY，self.meshTranslateZ
		else
			tx,ty,tz=threed:GetUnitPosition(self.target)
		end
	end
	local tarzero = tx==0 and ty==0 and tz==0
	tx,ty,tz = tx-px,ty-py,tz-pz
	local x,y,z = tx-sx,ty-sy,tz-sz
	local l=sqrt(x*x+y*y+z*z)
	if tarzero or l==0 then
		self.tri1.visible=false
		self.tri2.visible=false
		self.text1.visible=false
	else
		local w=self.width/2
		local r = self.blank
		local v1=self.vertices[self.v1]
		local v2=self.vertices[self.v2]
		local v3=self.vertices[self.v3]
		local v4=self.vertices[self.v4]
		local a=math.atan2(ty-sy, tx-sx)
		local t=math.asin(z/l)
		local s,c = sin(a),cos(a)
		local ct=cos(t)
		local mh = self.meshRotateZ
		local text1 = self.text1
		if self.showNumber then

			local v5=self.vertices[self.v5]
			local textr = math.min(self.num,l)
			v5[1]=sx+textr*c*ct
			v5[2]=sy+textr*s*ct
			v5[3]=sz+textr*z/l+mh
			text1.visible=true
			text1.text=string.format("%.0f",l)
			do
				local r,g,b
				if l>60 then
					r,g,b = 1,0,0
				elseif l>40 then
					r,g,b = 1,(60-l)/20,0
				elseif l>20 then
					r,g,b = (l-20)/20,1,0
				else
					r,g,b = 0,1,(20-l)/20
				end
				text1.r,text1.g,text1.b = r,g,b
			end
		else
			text1.visible=false
		end
		if l<=r then
			self.tri1.visible=false
			self.tri2.visible=false
		else
			self.tri1.visible=true
			self.tri2.visible=true
			v1[1]=sx-w*s+r*c*ct
			v1[2]=sy+w*c+r*s*ct
			v1[3]=sz+r*z/l+mh
			v2[1]=sx+w*s+r*c*ct
			v2[2]=sy-w*c+r*s*ct
			v2[3]=sz+r*z/l+mh
			v3[1]=tx-w*s
			v3[2]=ty+w*c
			v3[3]=tz+mh
			v4[1]=tx+w*s
			v4[2]=ty-w*c
			v4[3]=tz+mh
		end
	end
	AVRMesh.OnUpdate(self,threed)
end


AVR:RegisterMeshClass(AVRLinkMesh)
