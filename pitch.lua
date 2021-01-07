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

FCPitchBase={}
function FCPitchBase:new(knotCount, width, height)
	local p = {}
	setmetatable(p, self)
	self.__index = self

	p.width = width
	p.height = height

	self.init(p, knotCount)

	return p
end

function FCPitchBase:init(knotCount)
end

function FCPitchBase:setSelected(x,y)
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
	if #polygon.points > 6 then
		if type(color) == 'number' then 
			color = gamedata:getColor(color)
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