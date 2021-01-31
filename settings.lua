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
require "lib.scrollable"
require "lib.button.button"

ColorGroupSelector = require "colorselection"

BrowserLink = Button:new()
function BrowserLink:new(href, text, posx, posy, alignment)
	local b
	b = Button.new(self, text or href, function()
		b.pressed = true
		b.pressedstart = love.timer.getTime()
		love.system.openURL(href)
	end, posx, posy, alignment)
	b.name = 'btnGetsources'
	return b
end

function BrowserLink:draw()
	local g=love.graphics
	if self.pressed then
		g.setColor(1, .5,.5)		
		local now = love.timer.getTime()
		if now-self.pressedstart > 1.25 then
			self.pressed = false
			self.pressedstart = nil
		end
	else
		g.setColor(.5,.5,1)
	end
	Button.drawShadowText(self.title, self.posx+self.tx, self.posy+self.ty, self.enabled)
	g.rectangle("line", self.posx,self.posy,self.width,self.height)
end

SettingsUI=Overlay:new()
function SettingsUI:init()
	print("Settings UI")
	self.name="SettingsUI"

	local borderx = self.width*.10
	local bordery = self.height*.10
	local btnBorder = math.min(self.width*.05,self.height*.05)
	self.dim = {
		borderx, bordery,
		self.width-2*borderx, self.height-2*bordery
	}

	local quit = Button:new(Locale.get("settings_quit"), function()
			print("quit")
			-- gamedata.overlay = nil
			self:close()
			love.event.quit( "quit" )
		end, btnBorder, self.dim[4]-btnBorder, "BL")
	local restart = Button:new(Locale.get("settings_new_game"), function()
			print("restart")
			self:close()
			love.event.quit( "restart" )
		end, quit.posx+quit.width+btnBorder, quit.posy, "TL")

	local github = BrowserLink:new(
		"https://github.com/nigjo/quadcolors", "view on github",
		self.dim[3]-btnBorder, self.dim[4]-btnBorder, "BR")

	self.colors = ColorGroupSelector:new(self.dim[3]-2*btnBorder, quit.posy-2*btnBorder)
	self.colors.dim = {btnBorder,btnBorder,self.colors.width,self.colors.height}

	self.buttons={
		quit, restart, github
	}
end

function SettingsUI:closed()
	gamedata:store()
end

local function inShape(x,y, left,top,width,height)
	return x>left and x<left+width
			and y>top and y<top+height
end

function SettingsUI:findShape(x,y)
	if inShape(x,y, unpack(self.dim)) then
		local dlgX = x-self.dim[1]
		local dlgY = y-self.dim[2]
		if inShape(dlgX,dlgY, unpack(self.colors.dim)) then
			return self.colors:findShape(dlgX-self.colors.dim[1],dlgY-self.colors.dim[2])
		end
	
		for i=1,#self.buttons do
			if self.buttons[i].enabled
					and inShape(dlgX,dlgY, unpack(self.buttons[i]:getBounds())) then
				local btnName = self.buttons[i].name or ("dialogBtn"..i)
				return {
					name=btnName,
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

-- function SettingsUI:wheelmoved(x, y)
	-- print('SettingsUI',love.mouse.getX(),love.mouse.getY(),x,y)
	-- local shape = self:findShape(love.mouse.getX(),love.mouse.getY())
	-- print('SettingsUI','shape', shape.name)
	-- -- love.mouse.
-- end

function SettingsUI:draw(dx,dy)
	Overlay.draw(self, dx,dy)
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
	g.push()
	g.translate(self.colors.dim[1],self.colors.dim[2])
	self.colors:draw()
	g.pop()

	Button.drawAll(self.buttons)

	g.pop()
end
