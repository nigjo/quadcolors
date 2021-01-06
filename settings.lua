require "overlay"
require "lib/button/button"

ColorGroupButton = Radiobutton:new()

function ColorGroupButton:setColors(name)
end

function ColorGroupButton:draw()
	-- Radiobutton.draw(self)
	local g=love.graphics
	if self.selected==true then
		g.setColor(0,0,0,1)
		g.rectangle("fill", 0,0,self.width,self.height)
	end
	g.setColor(1,1,1,.5)
	g.rectangle("line", 0,0,self.width,self.height)
	
	-- g.line(0,0,self.width,self.height)
	-- g.line(0,self.height,self.width,0)
	-- g.setColor(0,1,1,1)
	-- g.rectangle("line", 0,0,self.width-2,dy)
	--local colName = self.names[(self.viewStart+i-2)%#self.names+1]
	if self.selected==true then
	g.setColor(1,1,1,.25)
	else
	g.setColor(0,0,0,.25)
	end
	g.print(self.colName,1,1)
	g.push()
	g.translate(0,self.height/2)
	-- print((self.viewStart+i-1)%#self.names+1, self.names[(self.viewStart+i-1)%#self.names+1])
	local cols = gamedata:getColorsOf(self.colName)
	local px=self.width/5
	-- print(tostring(cols))
	for j=1,4 do
		--g.circle("line", j*px,dy/2,dy/5*2)
		g.translate(px,0)
		drawFieldGem({points=self.colorGem,centroid={x=0,y=0}},cols[j])
	end
	g.pop()
end

ColorGroupSelector={
	lines = 4
}
function ColorGroupSelector:new(w,h)
	local s = {}
	setmetatable(s,self)
	self.__index = self
	
	s.names = gamedata:getColorNames()
	local currentName = gamedata:getColorName()
	s.viewStart = 1
	for i,name in ipairs(s.names) do
		if name==currentName then
			s.viewStart = i
			break
		end
	end

	s.btnBorder=12
	local btnBorder=s.btnBorder
	local up = Button:new("mehr", function(btn)
			s.viewStart = s.viewStart - 1
			s:refresh()
		end, w-btnBorder, 2*btnBorder, "TR")
	up.enabled = #s.names > self.lines
	local down = Button:new("mehr", function(btn)
			s.viewStart = s.viewStart + 1
			s:refresh()
		end, w-btnBorder, h-btnBorder, "BR")
	down.enabled = #s.names > self.lines
	
	s.width=up.posx-2*btnBorder
	s.height=h-btnBorder

	local dy=math.floor((s.height-self.lines-2)/self.lines)
	local px=s.width/5
	local gemSize = math.min(dy,px)*2/5
	s.colorGem = {}
	for i=math.pi/4,2*math.pi,math.pi/4 do
		table.insert(s.colorGem,gemSize*math.cos(i))
		table.insert(s.colorGem,gemSize*math.sin(i))
	end
	
	
	self.colSelectors={}
	for i=1,self.lines do
		local nextBtn = ColorGroupButton:new("colSel"..i, function(btn)
				gamedata:setColors(gamedata:getColorsOf(btn.colName))
			end, btnBorder,btnBorder+dy*(i-1))
		nextBtn:setGroup(self.colSelectors)
		nextBtn.visible = false
		nextBtn.height = dy
		nextBtn.width = s.width
		nextBtn.colorGem = s.colorGem
		table.insert(self.colSelectors,nextBtn)		
	end
	-- Initial ist "currentName" oben
	-- self.colSelectors[1].selected = true

	s.buttons = {up,down, unpack(self.colSelectors)}
	s:refresh()

	return s
end

function ColorGroupSelector:refresh()
	local currentName = gamedata:getColorName()
	-- self.colSelectors[1].selected = true
	for i=1,self.lines do
		local nextBtn = self.colSelectors[i]
		nextBtn.colName = self.names[(self.viewStart+i-2)%#self.names+1]
		nextBtn.selected = nextBtn.colName == currentName
	end
end

function ColorGroupSelector:draw()
	local g=love.graphics
	g.push()
	g.setColor(0,0,1,1)
	-- g.rectangle("line", 8,8,self.width,self.height)
	--TODO Gems auf ein Canvas malen. Ist seltener
	g.translate(self.btnBorder+1,self.btnBorder+1)
	local dy=math.floor((self.height-self.lines-2)/self.lines)
	local px=self.width/(4+1)
	for i=1,self.lines do
		--TODO: draw button
		self.colSelectors[i]:draw()
		g.translate(0,dy+1)
	end
	g.pop()
end

SettingsUI=Overlay:new()
function SettingsUI:init()
	print("Einstellungen")

	local borderx = self.width*.10
	local bordery = self.height*.10
	local btnBorder = math.min(self.width*.05,self.height*.05)
	self.dim = {
		borderx, bordery,
		self.width-2*borderx, self.height-2*bordery
	}
	
	local quit = Button:new("Beenden", function()
			print("quit")
			-- gamedata.overlay = nil
			love.event.quit( "quit" )
		end, btnBorder, self.dim[4]-btnBorder, "BL")
	local restart = Button:new("Neues Spiel", function()
			print("restart")
			love.event.quit( "restart" )
		end, quit.posx+quit.width+btnBorder, quit.posy, "TL")
		
	self.colors = ColorGroupSelector:new(self.dim[3], quit.posy-btnBorder)
	
	self.buttons={
		quit, restart, unpack(self.colors.buttons)
	}
end

local function inShape(x,y, left,top,width,height)
	return x>left and x<left+width
			and y>top and y<top+height
end

function SettingsUI:findShape(x,y)
	if inShape(x,y, unpack(self.dim)) then
		for i=1,#self.buttons do
			if self.buttons[i].enabled
					and inShape(x-self.dim[1],y-self.dim[2], unpack(self.buttons[i]:getBounds())) then
				return {
					name="dialogBtn"..i,
					action=self.buttons[i].action
				}
			end
		end
		return {
			name="dialog",
			action=function() end
		}
	end
	return Overlay.findShape(self)
end

function SettingsUI:draw(dx,dy)
	g=love.graphics

	g.push()
	
	g.translate(dx,dy)

	g.setColor(.66,.66,.66)
	g.rectangle("fill",unpack(self.dim))
	local s = g.getLineWidth()
	g.setLineWidth(s+2)
	g.setColor(.75,.75,.75)
	g.rectangle("line",unpack(self.dim))
	g.setLineWidth(s)

	g.translate(self.dim[1],self.dim[2])
	for i=1,#self.buttons do
		if self.buttons[i].visible ~= false then
			self.buttons[i]:draw()
		end
	end

	self.colors:draw()

	g.pop()
end