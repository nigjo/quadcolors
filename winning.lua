require "overlay"

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
		gamedata.overlay = WinningParty:new(gamedata.width, gamedata.height)
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
	local count = math.ceil(self.width/150)
	self.rockets={}
	for i=1,count do
		self.rockets[i] = self:createRocket()
	end
	self.maxr=math.min(self.width,self.height)*.075
end

function WinningParty:draw(h,w)
	Overlay.draw(self,h,w)
	for i=1,#self.rockets do
		local r = self.rockets[i]
		if r.t>r.dur then
			love.graphics.setColor(r.excol)
			love.graphics.circle("line", r.ex,r.ey,r.exr)
		else
			love.graphics.setColor(1,1,1)
			love.graphics.points(r.x,r.y)
		end
	end
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