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

require "lib.overlay"
require "lib.button.button"

local gameIsRunning = false

gamedata:addListener('started', function()
	gameIsRunning = true
	print("waiting for finished game")
end)
gamedata:addListener('finished', function()
	print("game finished")
	if gameIsRunning then
		print("lets party")
		gameIsRunning = false
		local success = WinningParty:new(gamedata.width, gamedata.height)
		success:open()
	end
end)

WinningParty=Overlay:new()
function WinningParty:createRocket()
	-- print("new rocket")
	local sx=self.width*.05+math.random(self.width*.9)
	local ex=self.width*.1+math.random(self.width*.8)
	while math.abs(ex-sx) > self.width*.25 do
		ex=sx+(ex-sx)/2
	end
	return {sx=sx,
		sy=self.height,
		ex=ex,
		ey=self.height*.1+math.random(self.height*.6),
		x=-1,y=-1,
		dur=1+math.random(),
		t=0,
		exr=0,
		edur=1+math.random(),
		excol=gamedata:getColor(math.random(4))
	}
end

function WinningParty:init()
	self.name="WinningParty"
	local count = math.ceil(self.width/100)
	self.rockets={}
	for i=1,count do
		self.rockets[i] = self:createRocket()
	end
	self.maxr=math.min(self.width,self.height)*.075
	local btnBorder=math.min(self.width*.05,self.height*.05)
	
	local restart = Button:new(Locale.get('winning_new_game'), function()
		print("restart")
		self:close()
		love.event.quit( "restart" )
	end, btnBorder,btnBorder)
	local nextLevel = Button:new(Locale.get('winning_next_level'),
	function()
	end, restart.posx+restart.width+btnBorder,restart.posy)
	nextLevel.enabled = false
	nextLevel.visible = false
	
	self.buttons = {
		nextLevel,restart
	}
end

local function star(g,x,y)
	g.line(x-1,y-3,x+1,y+3)
	g.line(x-3,y+1,x+3,y-1)
end

function WinningParty:draw(h,w)
	Overlay.draw(self,h,w)
	local g=love.graphics
	for i=1,#self.rockets do
		local r = self.rockets[i]
		if r.t>r.dur then
			local r1 = r.exr
			local r2 = r.exr*.6
			local r3 = r.exr*.4
			local red,green,b = unpack(r.excol)
			g.setColor(red,green,b,.33)
			-- g.circle("fill", r.ex,r.ey,r1)
			g.setColor(r.excol)
			--g.circle("line", r.ex,r.ey,r1)
			star(g,r.ex,r.ey-r1)
			star(g,r.ex,r.ey+r1)
			star(g,r.ex-r1,r.ey)
			star(g,r.ex+r1,r.ey)
			--g.circle("line", r.ex,r.ey,r.exr*2/3)
			star(g,r.ex-r2,r.ey-r2)
			star(g,r.ex+r2,r.ey-r2)
			star(g,r.ex-r2,r.ey+r2)
			star(g,r.ex+r2,r.ey+r2)
			star(g,r.ex,r.ey-r3)
			star(g,r.ex,r.ey+r3)
			star(g,r.ex-r3,r.ey)
			star(g,r.ex+r3,r.ey)
			
			--g.circle("line", r.ex,r.ey,r.exr/3)
		else
			g.setColor(1,1,1,.25)
			-- g.points(r.x,r.y)
			g.line(r.sx+(r.x-r.sx)*3/4,r.sy+(r.y-r.sy)*3/4,r.x,r.y)
		end
	end
	Button.drawAll(self.buttons)
end

local explodeTime = 1.25

function WinningParty:update(dt)
	for i=1,#self.rockets do
		local r = self.rockets[i]
		r.t=r.t+dt
		
		if r.t>r.dur+r.edur then
			self.rockets[i] = self:createRocket()
			self.rockets[i].x = self.rockets[i].sx
			self.rockets[i].y = self.rockets[i].sy
		elseif r.t>r.dur then
			local exdelta=r.t-r.dur
			r.exr = self.maxr * (exdelta/r.edur)
		else
			local dx = r.ex-r.sx
			local dy = r.ey-r.sy
			local f = r.t/r.dur
			r.x = r.sx + f*dx
			r.y = r.sy + f*dy
		end
	end
end

function WinningParty:findShape(x,y)
	btnAction=Button.findAction(x,y,self.buttons)
	if btnAction.name=="none" then
		return Overlay.findShape(self,x,y)
	else
		return btnAction
	end
end