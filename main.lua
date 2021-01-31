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

Locale = require "lang"
require "gamedata"
require "frame"
require "winning"

function love.load()
	print "initialize"
  math.randomseed(os.time())

	love.graphics.setFont(love.graphics.newFont("res/DejaVuSans.ttf",
	    love.graphics.getFont():getHeight()))

  posx, posy, width, height = love.window.getSafeArea( )
  ww, wh = love.graphics.getDimensions()

  texts={
    -- "save: "..posx..","..posy.." "..width.."x"..height,
    -- "dim: "..ww.."x"..wh
  }

  gamedata:init(width, height)
	
	local frame = GameFrame:new(width, height)
	frame:open()
	
	print "init done"
  gamedata:updateField()
end

function love.mousepressed(x, y, button, istouch, presses)
	Overlay:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased( x, y, button, istouch, presses )
	Overlay:mousereleased(x, y, button, istouch, presses)
end

function love.keypressed(key)
	Overlay:keypressed(key);
end

function love.wheelmoved(x, y)
	Overlay:wheelmoved(x, y);
end

function love.mousemoved( x, y, dx, dy, istouch )
	Overlay:mousemoved(x, y, dx, dy, istouch);
end

function love.update(dt)
	Overlay:update(dt)
end

function love.draw()
	love.graphics.setColor(1,1,1)
	
	Overlay:draw(posx, posy)

  love.graphics.setColor(1, 1, 1)
  for i=1,table.getn(texts) do
    love.graphics.print(texts[i],20,20+(i*16))
  end
end