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
  local count=(fw*fh)/4000
	
	self.width = width
	self.height = height
  
  self.canvas = love.graphics.newCanvas()
	self.points = 0
	self.validCounter = 0
	
	Button.basefont = love.graphics.newFont("res/DejaVuSans.ttf",math.floor(math.max(height/25, 12)))
  
  self.colorGroups = require "colorgroups"
  self.colors = self.colorGroups.default
	
	-- Generate Field until all looks fine
	local defectField
	repeat
		local maxcount
		defectField = false
		repeat
			print("init field")
			self.f = Field:new(count,fw,fh)
			-- do not try endless to arrange the points
			maxcount=20
			while maxcount>0 and self.f:rearrange() do
				maxcount = maxcount - 1
			end
		until maxcount>0
		-- generate Voronoi diagram
		self.f:checkEdges()
		for index,polygon in pairs(self.f.net.polygons) do
			if #polygon.points < 6 then
				-- some polygons seems to be defective
				print ("possible defect field")
				defectField = true
				break;
			end
		end
	until not defectField
  
  gamedata.currentColor = 3

  self.frame = GameFrame:new(width,height)

  -- table.insert(texts, "frame: "..fw.."x"..fh)
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
	if type(colors)=="table" then
		self.colors = colors
	else
		self.colors = self.colorGroups[colors]
	end
	self:updateField()
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

function gamedata:setValidCount(count)
	self.validCounter = count
	if count == #self.f.dots then
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
  g.setScissor(0,0,self.f.width,self.f.height)
  self.f:draw()
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