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
		gamedata.pitch:drawFieldGem(self.colorGem,cols[j])
	end
	g.pop()
end

ColorGroupSelector=Scrollable:new()
function ColorGroupSelector:init(w,h)
	print('GCS','init')
	self.lines = 4
end

function ColorGroupSelector:new(w,h)
	print('GCS','new')
	local s = Scrollable.new(self,0,0,w,h)
	-- setmetatable(s,self)
	-- self.__index = self
	print('GCS','new2')
	
	s.names = gamedata:getColorNames()
	local currentName = gamedata:getColorName()
	s.viewStart = 1
	for i,name in ipairs(s.names) do
		if name==currentName then
			s.viewStart = i
			break
		end
	end

	s.btnBorder=math.min(s.width*.05,s.height*.05)
	local btnBorder=s.btnBorder
	local up = Button:new(Locale.get('settings_more_up'), function(btn)
			s.viewStart = s.viewStart - 1
			s:refresh()
		end, w, 0, "TR")
	up.name='btnColorsUp'
	up.enabled = #s.names > s.lines
	local down = Button:new(Locale.get('settings_more_down'), function(btn)
			s.viewStart = s.viewStart + 1
			s:refresh()
		end, w, h, "BR")
	down.name='btnColorsDown'
	down.enabled = #s.names > s.lines

	s.selWidth=up.posx-btnBorder
	s.selHeight=s.height

	local dy=math.floor((s.selHeight-s.lines-2)/s.lines)
	local px=s.selWidth/5
	local gemSize = math.min(dy,px)*2/5
	s.colorGem = gamedata.pitch:createSelectorGem(gemSize)
	
	s.colSelectors={}
	for i=1,s.lines+2 do
		local nextBtn = ColorGroupButton:new("colSel"..i, function(btn)
				gamedata:setColors(gamedata:getColorsOf(btn.colName))
			end, btnBorder,btnBorder+dy*(i-1))
		nextBtn:setGroup(s.colSelectors)
		nextBtn.visible = false
		nextBtn.height = dy
		nextBtn.width = s.selWidth
		nextBtn.colorGem = s.colorGem
		table.insert(s.colSelectors,nextBtn)		
	end
	-- Initial ist "currentName" oben
	-- s.colSelectors[1].selected = true

	s.mybuttons = {up,down, unpack(s.colSelectors)}
	s:refresh()

	return s
end

function ColorGroupSelector:findShape(x,y)
	local action = Button.findAction(x,y, self.mybuttons)
	if action.name=='none' then
		return {
			name="selector",
			action=function() end
		}
	end
	return action
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
	-- g.setColor(0,0,1,1)
	-- g.rectangle("line",0,0,self.width,self.height)
	--TODO Gems auf ein Canvas malen. Ist seltener
	-- g.translate(self.btnBorder+1,self.btnBorder+1)
	local dy=math.floor((self.height-self.lines-2)/self.lines)
	local px=self.selWidth/(4+1)
	for i=1,self.lines do
		--TODO: draw button
		self.colSelectors[i]:draw()
		g.translate(0,dy+1)
	end
	g.pop()
	Button.drawAll(self.mybuttons)
end

return ColorGroupSelector