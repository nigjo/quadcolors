require "overlay"
require "settings"
require "field"

GameFrame=Overlay:new()

function GameFrame:init()
  -- local f = {}
  -- setmetatable(f, self)
  -- self.__index = self
  
  -- f.width = w
  -- f.height = h
	f=self
  
  f.titleH = f.height-gamedata.f.height
  f.menuW = f.width-gamedata.f.width
  
  f.colorDotsGrid = gamedata.f.height / 10
  f.colorDotsSize = math.min(f.colorDotsGrid*.9, f.menuW/3)
	
	f.titleFont = love.graphics.newFont("res/DejaVuSans.ttf",f.titleH/2)
	f.texts={
		point={
			x=f.menuW+gamedata.f.width*.1,
			text = love.graphics.newText( f.titleFont, "Points: ")
		},
		size={
			x=f.menuW+gamedata.f.width*.4,
			text= love.graphics.newText( f.titleFont, "Size: ")
		},
		playtime={
			x=f.menuW+gamedata.f.width*.7,
			text = love.graphics.newText( f.titleFont, "Time: ")
		}
	}
	f.baseline = (f.titleH-f.texts.point.text:getHeight())/2

	f.colorGem = {}
	for i=math.pi/4,2*math.pi,math.pi/4 do
		table.insert(f.colorGem,f.colorDotsSize*math.cos(i))
		table.insert(f.colorGem,f.colorDotsSize*math.sin(i))
	end
	
	f.logoCanvas = self:createLogo()

  return f
end

function GameFrame:createLogo() -- -> Frame
	local c = love.graphics.newCanvas()
	love.graphics.setCanvas(c)
	love.graphics.clear()
	love.graphics.setColor(1,1,1,1)
	local logo = love.graphics.newImage("res/frame64.png")
	local titlesize = math.min(self.menuW, self.titleH)*.95
	local logomax = math.max(logo:getPixelWidth(),logo:getPixelHeight())
	local scale=titlesize/logomax
	local logoScale = love.math.newTransform()
	logoScale:translate(
		(self.menuW-(logo:getPixelWidth()*scale))/2,
		(self.titleH-logo:getPixelHeight()*scale)/2
	)
	logoScale:scale(scale,scale)
	love.graphics.draw(logo, logoScale)
	local logoFont = love.graphics.newFont("res/DejaVuSans.ttf",self.titleH/2)
	local logoText1 = love.graphics.newText(logoFont, "Quad")
	local logoText2 = love.graphics.newText(logoFont, "Colors")
	local logoborder=self.titleH/12
	love.graphics.setColor(0,0,0,.5)
	love.graphics.draw(logoText1,math.floor(logoborder),math.floor(logoborder))
	love.graphics.draw(logoText2,self.menuW-logoborder-logoText2:getWidth(),
		self.titleH-logoborder-logoText2:getHeight())
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(logoText1,math.floor(logoborder),math.floor(logoborder))
	love.graphics.draw(logoText2,self.menuW-logoborder-logoText2:getWidth(),
		self.titleH-logoborder-logoText2:getHeight())
	love.graphics.setCanvas()
	
	return c
end

function GameFrame:findShape(x,y) -- -> Frame

  if x<self.menuW and y<self.titleH then
    -- Menue
    return {
      name = "menu",
      action=function()
				-- self.menuActive = true
				-- love.event.quit( "restart" )
				print("buh")
				gamedata.overlay = SettingsUI:new(self.width,self.height)
			end
    }
  elseif x<self.menuW  then
    -- Farbwaehler
    local idx = self:getColorChooser(x,y)
    print("col"..idx)
    if idx>0 then
      return {
        name="colorbutton"..idx,
        action=function()
          gamedata:setCurrentColor(idx)
        end
      }
		-- elseif y>self.height-(self.colorDotsGrid*2/3) then
			-- return {
				-- name="colortoggle",
				-- action=function()
					-- gamedata:toggleColors()
				-- end
			-- }
    end
  elseif y<self.titleH then
    -- "Titelzeile" Punkte
    return {
      name = "title",
      action=function() end
    }
  else
	  -- mitten drin
		if not gamedata.finished then
			return {
				name = "field",
				action=function()
					gamedata.f:setSelected(x-self.menuW,y-self.titleH)
				end
			}
		end
  end
  return {
    name = "none",
    action=function() end
  }
end

function GameFrame:isField(x,y)
  return x>self.menuW and y>self.titleH
end

function GameFrame:getColorChooser(x,y)
  local px=self.menuW/2
  if y<self.titleH then return -1 end
  for i=1,4 do
    local dx=px-x
    local py=self.titleH+self.colorDotsGrid*i*2
    local dy=py-y
    delta = math.sqrt(dx*dx+dy*dy)
    -- print (i..":delta "..delta.."/"..self.colorDotsSize)
    if delta<self.colorDotsSize then
      return i
    end
  end
  return -1
end

local function drawFrameBasics(self, dx,dy)
  local g=love.graphics
  g.setColor(.75,.75,.75)
  g.rectangle("fill",dx,dy,self.menuW,self.height)
  g.rectangle("fill",dx,dy,self.width,self.titleH)
  g.setColor(.66,.66,.66)
  g.rectangle("line",dx,dy,self.menuW,self.titleH)
	-- for i=1,4 do
		-- g.setColor(gamedata:getColor(i))
		-- g.rectangle("fill",dx+(i-1)*(self.menuW/4),dy+self.height-(self.colorDotsGrid*2/3),
			-- self.menuW/4,(self.colorDotsGrid*2/3))
	-- end
end

local function drawColorSelectors(self, dx,dy)
  local g=love.graphics
	g.push()
	g.translate(dx+self.menuW/2,self.titleH+self.colorDotsGrid*2)
	drawFieldGem({points=self.colorGem,centroid={x=0,y=0}}, gamedata:getColor(1))
	g.translate(0,self.colorDotsGrid*2)
	drawFieldGem({points=self.colorGem,centroid={x=0,y=0}}, gamedata:getColor(2))
	g.translate(0,self.colorDotsGrid*2)
	drawFieldGem({points=self.colorGem,centroid={x=0,y=0}}, gamedata:getColor(3))
	g.translate(0,self.colorDotsGrid*2)
	drawFieldGem({points=self.colorGem,centroid={x=0,y=0}}, gamedata:getColor(4))
	g.pop()
	local colIdx = gamedata:getCurrentColor()
  if colIdx ~= nil then
    g.setColor(1,1,1,.25)
    g.circle("fill",dx+self.menuW/2,self.titleH+self.colorDotsGrid*colIdx*2,self.colorDotsSize*.6)
    g.setColor(0,0,0,.25)
    g.circle("fill",dx+self.menuW/2,self.titleH+self.colorDotsGrid*colIdx*2,self.colorDotsSize*.33)
  end
end

local function drawGameStatistics(self,dx,dy)
  local g=love.graphics
  
	g.setColor(1,1,1,1)
	for n,data in pairs(self.texts) do
		g.draw(data.text, dx+data.x, dy+self.baseline)
	end
	
	g.setColor(0.15,.5,.25,1)
	local f=g.getFont()
	g.setFont(self.titleFont)

	g.print(gamedata:getPoints(),
		dx+self.texts.point.x+ self.texts.point.text:getWidth(),
		dy+self.baseline)

	local count = #gamedata.f.dots
	local done = gamedata:getValidCount()
	g.print(done.."/"..count,
		dx+self.texts.size.x+ self.texts.size.text:getWidth(),
		dy+self.baseline)

	local dur = gamedata:getDuration()
	local timeMin = math.floor(dur/60)
	local timeSec = math.floor(dur) % 60
	if timeSec < 10 then timeSec = '0'..timeSec end
	g.print(timeMin..":"..timeSec,
		dx+self.texts.playtime.x+ self.texts.playtime.text:getWidth(),
		dy+self.baseline)

	g.setFont(f)
end

function GameFrame:draw(dx,dy)
  local g=love.graphics
  
	-- Rahmen
	drawFrameBasics(self,dx,dy)
	-- Spielfeld
	g.setColor(1, 1, 1)
  g.draw(gamedata.canvas,dx+self.menuW,dy+self.titleH)
  -- Farbwaehler
	drawColorSelectors(self, dx,dy)
	
	drawGameStatistics(self, dx, dy)
	
	g.push()
	g.setColor(1, 1, 1)
	g.translate(dx,dy)
	g.draw(self.logoCanvas)
	g.pop()

end