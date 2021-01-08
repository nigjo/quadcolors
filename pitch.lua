-- The MIT License (MIT)
--
-- Copyright © 2021 Jens Hofschröer
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the “Software”), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--
FCPolygon={}
function FCPolygon:new()
	local p ={}
	setmetatable(p, self)
	self.__index = self
	p.points={}
	return p
end

function FCPolygon:add(x,y)
	table.insert(self.points,x)
	table.insert(self.points,y)
end

function FCPolygon:getBounds()
	if #self.points == 0 then return nil end
	local xmin=self.points[1]
	local ymin=self.points[2]
	local xmax=self.points[1]
	local ymax=self.points[2]
	for i=3,#self.points,2 do
		if xmin>self.points[i] then
			xmin=self.points[i]
		elseif xmax<self.points[i] then
			xmax=self.points[i]
		end
		if ymin>self.points[i+1] then
			ymin=self.points[i+1]
		elseif ymax<self.points[i+1] then
			ymax=self.points[i+1]
		end
	end
	return xmin,ymin,xmax,ymax
end

function FCPolygon:getCenter()
	if self.centroid ~= nil then
		return self.centroid.x,self.centroid.y
	end
	local bounds = {self:getBounds()}
	local cx = bounds[1]+(bounds[3]-bounds[1])/2
	local cy = bounds[2]+(bounds[4]-bounds[2])/2
	return cx,cy
end

FCPatch=FCPolygon:new()
function FCPatch:new(...)
	local p = FCPolygon.new(self)
	if arg~=nil and #arg>0 then
		p.points = {...}
	end
	p.colidx = 0
	return p
end


FCPitchBase={}
function FCPitchBase:new(knotCount, width, height)
	local p = {}
	setmetatable(p, self)
	self.__index = self

	p.width = width
	p.height = height

	p.patchCount = self.init(p, knotCount)

	return p
end

function FCPitchBase:init(knotCount)
	return knotCount
end

---
-- scans the current pitch for the right patch
-- @return FCPatch or nil
--
function FCPitchBase:findPatch(x,y)
	return nil
end

function FCPitchBase:setSelected(x,y)
	local patch = self:findPatch(x,y)
	self._lastSelected = patch
	if patch~=nil then
		local nextcol = gamedata:getCurrentColor()
		if patch.colidx == 0 then
			gamedata:checkStart()
			gamedata:addPoints(gamedata.gains.newTile)
		elseif patch.colidx ~= nextcol then
			gamedata:addPoints(gamedata.gains.changed)
		else
			-- no change
			return
		end
		patch.colidx=nextcol
		self:updateValidCounter()
		gamedata:updateField()
	end
end

function FCPitchBase:updateValidCounter(polygons)
	if polygons~=nil then
		local counter = 0
		for i,fcPolgon in ipairs(polygons) do
			local sameOrNone = false
			for n,nPolygon in ipairs(self:_getNeighbors(fcPolgon)) do
				if nPolygon.colidx == 0 or nPolygon.colidx == fcPolgon.colidx then
					sameOrNone = true
					break
				end
			end
			if not sameOrNone then counter = counter + 1 end
		end
		self.finished = counter == #polygons
		gamedata:setValidCount(counter)
	end
end

--[[--
	Creates a FCPolygon for the color selection. This polygon will be passed to
	@{FCPitchBase:drawFieldGem} as a first argument.

	@param size height and width of the polygon. The polygon should extend from
	  `-size` to `size`. If the gem is a circle the radius will be `size`
		
	@return FCPolygon
]]
function FCPitchBase:createSelectorGem(size)
	local gem = FCPolygon:new()
	return gem
end

function FCPitchBase:drawFieldGem(polygon, color)
	if #polygon.points >= 6 then
		if type(color) == 'number' then 
			color = gamedata:getColor(color)
		elseif color==nil and polygon.colidx~=nil then
			color = gamedata:getColor(polygon.colidx)
		end
		love.graphics.setColor(color)
		love.graphics.polygon("fill", unpack(polygon.points))
	-- else
		-- print("polygon", #polygon.points)
	end
end

function FCPitchBase:drawPolygon(polygon)
end

function FCPitchBase:draw()
end

function FCPitchBase:_getNeighbors(fcPolgon)
	return {}
end

function FCPitchBase:_debugDrawNeighbors(fcPolgon)
	if fcPolgon~=nil then
		local cx,cy=fcPolgon:getCenter()
		-- eine Auswahl vorhanden
		for i,nPolygon in pairs(self:_getNeighbors(fcPolgon)) do
			love.graphics.setColor(1,0,0,1)
			local nbounds = {nPolygon:getBounds()}
			-- love.graphics.polygon('line',unpack(polygon.points))
			local nx,ny=nPolygon:getCenter()
			love.graphics.line(nx,ny,cx,cy)
			love.graphics.setColor(1,1,1,0.75)
			love.graphics.print("#"..i.."/"..nPolygon.colidx,nx,ny)
		end

		love.graphics.setColor(1,0,0,1)
		local xi,yi,xx,yx = fcPolgon:getBounds()
		love.graphics.circle("line", cx,cy,
			math.min(math.abs(xi-cx),math.abs(xx-cx),math.abs(yi-cy),math.abs(yx-cy))*.75)
	end
end
