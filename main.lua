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

function love.mousemoved( x, y, dx, dy, istouch )
	-- Overlay:mousemoved(x, y, dx, dy, istouch);
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