require "lib.board"
local pitchClass = require "board.gems"

gamedata = {
	events = {},
	gains = {
		newTile = 50,
		changed = -15,
		help = -5
	},
	starttime=0,
	endduration=-1,
	pauseduration=0,
	finished=false
}

function gamedata:init(width, height)
  local fw = width-math.max(math.floor(width*.12),50)
  local fh = height-math.max(math.floor(height*.10),50)
  self.count=math.floor((fw*fh)/4000)
	-- self.count = 5

	self.width = width
	self.height = height
  
  self.canvas = love.graphics.newCanvas()
	self.points = 0
	self.validCounter = 0
	
	Button.basefont = love.graphics.newFont("res/DejaVuSans.ttf",math.floor(math.max(height/25, 12)))
  
  self.colorGroups = require "colorgroups"
  self.colors = self.colorGroups.default
	
	-- Generate Field until all looks fine
	-- self.pitch = Field:new(count, fw,fh)
	self.pitch = pitchClass:new(self.count, fw,fh)
	if type(self.pitch.patchCount) == 'number' then
		self.count = self.pitch.patchCount
	end

  gamedata.currentColor = 3

	self:load()
end

function gamedata:store()
	content = ""
	
	content = content.."level=".."1".."\n"
	content = content.."colorName="..self:getColorName().."\n"
	content = content.."count="..self.count.."\n"
	content = content.."locale="..Locale:getLocale().."\n"
	love.filesystem.write("fc_settings.dat",content)
end

local savedataLoader= {
	-- ["level"]=function(self, val) end,
	-- ["count"]=function(self, val)
		-- self.count = val
	-- end,
	["colorName"]=function(self, val)
		if not self:setColors(val) then
			self:setColors('default')
		end
	end,
	["locale"]=function(self, val)
		Locale:setLocale(val)
	end
}

function gamedata:load()
	if not love.filesystem.getInfo("fc_settings.dat", "file") then return end
	-- love.filesystem.load("fc_settings.dat");
	for line in love.filesystem.lines("fc_settings.dat") do
		local eq=string.find(line,"=",1,true)
		local key = string.sub(line,1,eq-1)
		local val = string.sub(line,eq+1)
		
		if savedataLoader[key] ~= nil then
			print("loading",key,val)
			savedataLoader[key](self, val)
		else
			print("ignoring",key)
		end
		
		-- table.insert(highscores, line)
	end
end

function gamedata:getPatchCount()
	return self.count
end

function gamedata:addPauseTime(dt)
	if gamedata.starttime>0 and gamedata.endduration<0 then
		gamedata.pauseduration = gamedata.pauseduration + dt
	end
end

function gamedata:toggleColors()
	local found=false
	local first=nil
	for name,colors in pairs(self.colorGroups) do
		print("checking "..name)
		if first == nil then first = colors end
		if found==true then
			self.colors = colors
			print("using colors "..name)
			self:updateField()
			return
		elseif self.colors==colors then
			print("found current colors "..name)
			found = true
		end
	end
	if first ~= nil then
		print("using first color entry")
		self.colors = first
		self:updateField()
	end
end

function gamedata:getColorName()
	for name,colors in pairs(self.colorGroups) do
		if self.colors==colors then
			return name
		end
	end
	return "default"
end

function gamedata:getColorNames()
	local names={}
	for name,colors in pairs(self.colorGroups) do
		table.insert(names, name)
	end
	return names
end

function gamedata:getColorsOf(name)
	return self.colorGroups[name]
end

function gamedata:setColors(colors)
	local nextcolor;
	if type(colors)=="table" then
		nextcolor = colors
	else
		nextcolor = self.colorGroups[colors]
	end
	if nextcolor ~= nil then
		self.colors = nextcolor
		self:updateField()
	end
	return nextcolor ~= nil
end

function gamedata:checkStart()
	if self.starttime == 0 then
		self.starttime = love.timer.getTime()
		self:fireChange('started')
	end
end

function gamedata:getDuration()
	if self.starttime == 0 then
		return 0
	elseif self.endduration > 0 then
		return self.endduration
	else
		local now = love.timer.getTime()
		return (now - self.starttime - self.pauseduration)
	end
end

function gamedata:setValidCount(vcount)
	self.validCounter = vcount
	if vcount == self.count then
		self.endduration = 
			love.timer.getTime() - self.starttime - self.pauseduration
		self.finished=true
		self:fireChange('finished')
	end
end

function gamedata:getValidCount()
	return self.validCounter
end


function gamedata:updateField()
  local g = love.graphics
  g.setCanvas(self.canvas)
	--g.setBackgroundColor(1,1,1,1)
  --g.setColor(1,1,1,1)
  g.clear()
  g.setScissor(0,0,self.pitch.width,self.pitch.height)
  self.pitch:draw()
  g.setScissor()
  g.setCanvas()
	self:fireChange('repaint')
end

function gamedata:fireChange(event)
	if self.events[event] ~= nil then
		for i=1,#self.events[event] do
			local l = self.events[event][i]
			l()
		end
	end
end

function gamedata:addListener(event, listenercb)
	if self.events[event] == nil then self.events[event] = {} end
	table.insert(self.events[event], listenercb)
end

function gamedata:getPoints()
	return self.points
end

function gamedata:addPoints(points)
	self.points = self.points + points
	self:fireChange('points')
end

function gamedata:setCurrentColor(idx)
	self.currentColor = idx
	self:fireChange('color')
end

function gamedata:getCurrentColor()
	return self.currentColor
end

function gamedata:getColor(idx)
  if idx<1 or idx>4 then
    return {0,0,0}
  end
  return self.colors[idx]
end