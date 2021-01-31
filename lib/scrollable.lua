-- MIT License

-- Copyright (c) 2021 Jens Hofschröer

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

Scrollable = {}

function Scrollable:new(dx,dy, width, height)
	local s = {}
  setmetatable(s, self)
  self.__index = self

	s.dx = dx
	s.dy = dy
	s.width = width
	s.height = height
	s.scrollpos = 0
	s.scrollheight = height

	self.init(s)

	return s;
end

function Scrollable:init()
end

function Scrollable:open()
	-- scrollables
end
function Scrollable:close()
end

function Scrollable:update(dt)
end

function Scrollable:update(dt)
end

function Scrollable:drawContent()
	-- implement your scrolling here.
	-- coordinates from (0,0) to (self.width, self.scrollheight)
end

function Scrollable:draw(dx,dy)
	local g = love.graphics
	local dx = dx or self.dx
	local dy = dy or self.dy

	g.setScissor(dx,dy, self.width, self.height)
	g.setColor(0,1,0)
	g.rectangle("fill", dx,dy-self.scrollpos, self.width, self.scrollheight)
	love.graphics.push();
	g.translate(0,-self.scrollpos)
	self:drawContent()
	love.graphics.pop();
	g.setScissor()

	g.setColor(0,0,1)
	g.rectangle("line", dx,dy, self.width, self.height)
	g.setColor(1,0,0)
	g.rectangle("line", dx,dy-self.scrollpos, self.width, self.scrollheight)
end

return