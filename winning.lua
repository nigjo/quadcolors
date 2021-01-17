require "overlay"
require "lib/button/button"

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
	return {
		sx=self.width*.1+math.random(self.width*.8),
		sy=self.height,
		ex=self.width*.1+math.random(self.width*.8),
		ey=self.height*.1+math.random(self.width*.4),
		x=-1,y=-1,
		dur=1+math.random(),
		t=0,
		exr=0,
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

function WinningParty:draw(h,w)
	Overlay.draw(self,h,w)
	for i=1,#self.rockets do
		local r = self.rockets[i]
		if r.t>r.dur then
			love.graphics.setColor(r.excol)
			love.graphics.circle("line", r.ex,r.ey,r.exr)
			love.graphics.circle("line", r.ex,r.ey,r.exr*2/3)
			love.graphics.circle("line", r.ex,r.ey,r.exr/3)
		else
			love.graphics.setColor(1,1,1)
			love.graphics.points(r.x,r.y)
		end
	end
	Button.drawAll(self.buttons)
end

local explodeTime = 1.25

function WinningParty:update(dt)
	for i=1,#self.rockets do
		local r = self.rockets[i]
		r.t=r.t+dt
		
		if r.t>r.dur+explodeTime then
			self.rockets[i] = self:createRocket()
			self.rockets[i].x = self.rockets[i].sx
			self.rockets[i].y = self.rockets[i].sy
		elseif r.t>r.dur then
			local exdelta=r.t-r.dur
			r.exr = self.maxr * (exdelta/explodeTime)
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