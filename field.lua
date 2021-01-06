require "lib/voronoi/voronoi"

Field={}
Field.border = 20

colorInitialDot = {0,0,1} -- blue
colorSettled = {0,1,0} -- green
colorMoved = {1,0,0} -- red

function Field:new(knotCount, width, height)
	m = {}
	setmetatable(m, self)
	self.__index = self

	m.width=width
	m.height=height
	m.arranged=false
	m.finished=false

	m.dots={}
	for i=1,knotCount do
		local dot = {
			x=Field.border+math.random(width-Field.border-Field.border),
			y=Field.border+math.random(height-Field.border-Field.border),
			col=colorInitialDot,
			colidx=0
		}
		table.insert(m.dots, dot)
	end
	
	m.validCounter = 0

	return m
end

local function drawGemSide(polygon, side, x1,y1,x2,y2)
	table.insert(side,x1)
	table.insert(side,y1)
	table.insert(side,x2)
	table.insert(side,y2)
	local cx=(x2+(side[1]-x2)/2)-polygon.centroid.x
	local cy=(y2+(side[2]-y2)/2)-polygon.centroid.y
	-- print(cx,cy)
	local g=love.graphics
	if cy<=0 then
		local phi
		if x==0 then
			phi=math.pi/2
		else
			phi=math.acos(cx/math.sqrt(cx*cx+cy*cy))
		end
		if phi>=math.pi/3  then
			g.push("all")
			local deltaphi = math.abs((math.pi*4/5)-phi)
			g.setColor(1,1,1,.5*(.75-deltaphi))
			g.polygon('fill',unpack(side))
			--g.line(polygon.centroid.x+cx,polygon.centroid.y+cy,polygon.centroid.x,polygon.centroid.y)
			g.pop()
		end
	end
	
	--g.line(cx,cy,polygon.centroid.x,polygon.centroid.y)
	-- print(x2,sides[sidx-1][1],cx)
	g.polygon('line',unpack(side))
end
--[[
Zeichnet einen "Edelstein" in ein Polygon.
Diese Routine solle nicht direkt in draw verwendet werden. Es ist besser
die Edelsteine in ein Canvas zu zeichnen.
]]--
function drawFieldGem(polygon, color)
	local g=love.graphics
	g.push("all")
	g.setColor(color)
	g.polygon('fill',unpack(polygon.points))
	local inner={}
	local sides={}
  -- print("#"..#polygon.points)
	g.setColor(1,1,1,.33)
	for i=1,#polygon.points,2 do
		-- print("# "..i)
		local px=polygon.points[i]
		-- local endIdx = i+1
		-- if endIdx>#polygon.points then endIdx= 1 end
		-- print("#+"..endIdx)
		local py=polygon.points[i+1]
	  -- print("#="..px.."x"..py)
		inner[i]=px+(polygon.centroid.x-px)*.4
		inner[i+1]=py+(polygon.centroid.y-py)*.4
		local sidx=(i+1)/2
		sides[sidx]={
			px,py,
			inner[i],inner[i+1]
		}
		if sidx>1 then
			drawGemSide(polygon, sides[sidx-1],inner[i],inner[i+1],px,py)
		end
	end
	drawGemSide(polygon, sides[#sides],sides[1][3],sides[1][4],sides[1][1],sides[1][2])

	g.pop()
end

local function debugDrawNeighbors(self)
	if self.selected~=nil and self.selected > 0 then
		-- eine Auswahl vorhanden
		local r,g,b = gamedata.colors[self.dots[self.selected].colidx]
		for i,polygon in pairs(self.net:getNeighbors("all",self.selected)) do
			love.graphics.setColor(0,0,0,0.25)
			-- love.graphics.polygon('line',unpack(polygon.points))
			love.graphics.line(
				self.dots[self.selected].x,self.dots[self.selected].y,
				polygon.centroid.x,polygon.centroid.y
				)
			love.graphics.setColor(1,1,1,0.75)
			love.graphics.print("#"..polygon.index.."/"..self.dots[polygon.index].colidx,
			polygon.centroid.x,polygon.centroid.y)
		end

		love.graphics.setColor(1,1,1,.25)
		love.graphics.circle("line", self.dots[self.selected].x,
				self.dots[self.selected].y,self.border*.75)
	end
end

function Field:draw()
	if not self.arranged then
		-- Punkte in rot und grün waehrend des arrangierens
		for i=1,#self.dots do
			love.graphics.setColor(self.dots[i].col and colorMoved or colorSettled)
			love.graphics.circle("fill", self.dots[i].x,self.dots[i].y,5)
			love.graphics.circle("line", self.dots[i].x,self.dots[i].y,20)
		end
	end
	if self.net ~= nil then
		-- Es sind die Voronoi-Daten vorhanden
		if not self.arranged then love.graphics.setColor(1,.5,1,1) 
		else love.graphics.setColor(1,1,1,1) end
		for index,polygon in pairs(self.net.polygons) do
			if #polygon.points >= 6 then
				if self.dots[index].colidx > 0 then
					drawFieldGem(polygon, gamedata.colors[self.dots[index].colidx])
					--love.graphics.setColor(1,0,0,1)
				end
				love.graphics.polygon('line',unpack(polygon.points))
			else
				print "defect detected"
			end
		end
	end
	
	-- dSebugDrawNeighbors(self)
end

function Field:checkEdges()
	-- print "checking..."
	self.net = nil
	self.net = voronoilib:fromPoints(self.dots, {0,0,self.width,self.height})
	-- self.polygons = diag.polygons
	-- for i=1,#self.dots do self.dots[i].colidx = 2 end
	-- print "... ok"
end

function Field:setSelected(x,y)
	if self.finished == true then return true end
	if #self.dots <= 0 then return false end
	local function qdist(x1,y1,x2,y2)
		return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
	end
	local dmin = qdist(x,y, self.dots[1].x,self.dots[1].y)
	local lastsel = self.selected
	self.selected = 1
	for i=2,#self.dots do
		local dmin2 = qdist(x,y, self.dots[i].x,self.dots[i].y)
		if dmin2 < dmin then
			dmin = dmin2
			self.selected = i
		end
	end
	local nextcol = gamedata:getCurrentColor();
	if self.dots[self.selected].colidx ~= nextcol then 
		if self.dots[self.selected].colidx == 0 then
			gamedata:checkStart()
			gamedata:addPoints(gamedata.gains.newTile)
		else
			gamedata:addPoints(gamedata.gains.changed)
		end
		self.dots[self.selected].colidx = gamedata:getCurrentColor()
		
		self:updateValidCounter()
		
		gamedata:updateField()
	elseif lastsel ~= self.selected then
		gamedata:updateField()
	end
	
	return self.finished
end

function Field:updateValidCounter()
	local counter = 0
	for pidx,polygon in pairs(self.net.polygons) do
		local sameOrNone = false
		for nidx,neighbor in pairs(self.net:getNeighbors("all",pidx)) do
			if self.dots[neighbor.index].colidx == 0 or
				self.dots[neighbor.index].colidx == self.dots[pidx].colidx then
				sameOrNone = true
				break
			end
		end
		if not sameOrNone then counter = counter + 1 end
	end
	self.finished = counter == #self.dots
	gamedata:setValidCount(counter)
	-- print("valid:"..counter)
	return counter
end

function Field:rearrange()
	if not self.arranged then
		-- print "checking..."
		local moved = false
		for i=1,#self.dots do
			self.dots[i].col = false
			for j=1,#self.dots do
				if i~=j then
					local dx = self.dots[i].x-self.dots[j].x
					local dy = self.dots[i].y-self.dots[j].y
					local delta = math.sqrt(dx*dx+dy*dy)
					if delta < Field.border*2.1 then
						-- print("dx="..dx..",dy="..dy..",delta="..delta)
						local x = self.dots[i].x
						local y = self.dots[i].y

						local mx = math.floor(dx*.5)
						if mx >=0 and mx <1 then mx = -1 end
						if mx <0 and mx >-1 then mx = 1 end
						mx = self.dots[i].x + mx
						if mx<Field.border then mx=Field.border end
						if mx>self.width-Field.border then mx=self.width-Field.border end
						self.dots[i].x = mx

						local my = math.floor(dy*.5)
						if my >=0 and my <1 then my = 1 end
						if my <0 and my >-1 then my = -1 end
						my = self.dots[i].y + my
						if my<Field.border then my=Field.border end
						if my>self.height-Field.border then my=self.height-Field.border end
						self.dots[i].y = my
						self.dots[i].col = true
						-- print("moved from "..x.."x"..y.." to "..self.dots[i].x.."x"..self.dots[i].x.."-")
						moved = true
					end
				end
			end
		end
		-- for i=1,#self.dots do self.dots[i].col = moved and colorMoved or colorSettled end
		self.arranged = not moved
		-- if not moved then print "ok" end
		return moved
	end
	return false
end

function Field:isArranged()
	return self.arranged
end
