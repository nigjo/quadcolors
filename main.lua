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
	print "init done"
  gamedata:updateField()
end

-- function debugRearrange(dt)
  -- if not gamedata.f:isArranged() then
    -- gamedata.last = gamedata.last + dt
    -- if gamedata.last > 1 then
      -- gamedata.last = 0
      -- gamedata.f:rearrange()
      -- gamedata.f:checkEdges()
    -- end
    -- gamedata:updateField()
  -- end
-- end

function love.mousepressed(x, y, button, istouch, presses)
  if button==1 then
    if gamedata.overlay ~= nil then
			mouseAction = gamedata.overlay:findShape(x-posx,y-posy)
		else
			mouseAction = gamedata.frame:findShape(x-posx,y-posy)
		end
    print ("down with "..mouseAction.name)
  else
    mouseAction = nil
  end
end

function love.mousereleased( x, y, button, istouch, presses )
  if button==1 and mouseAction ~= nil then
    local releaseAction
    if gamedata.overlay ~= nil then
			releaseAction = gamedata.overlay:findShape(x-posx,y-posy)
		else
			releaseAction = gamedata.frame:findShape(x-posx,y-posy)
		end
    print ("up with "..releaseAction.name)
    if releaseAction.name == mouseAction.name then
      mouseAction.action()
    end
    releaseAction = nil
  end
  mouseAction = nil
end

function love.keypressed(key)
	if gamedata.overlay ~= nil then
		gamedata.overlay:keypressed(key)
	else
		gamedata.frame:keypressed(key)
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
  if mouseAction == nil and gamedata.frame:isField(x-posx,y-posy) == true then
    mousePos = {x,y}
  else
    mousePos = nil
  end
end

function love.update(dt)
	gamedata.frame:update(dt)
	if gamedata.overlay ~= nil then
		if gamedata.starttime>0 and gamedata.endduration<0 then
			gamedata.pauseduration = gamedata.pauseduration + dt
		end
		gamedata.overlay:update(dt)
	end
end

function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.push()
	-- Frame wird immer gezeichnet
  gamedata.frame:draw(posx, posy)
	love.graphics.pop()

	-- Overlay nur, wenn es da ist
	if gamedata.overlay ~= nil then
		love.graphics.setColor(0,0,0,.66)
		love.graphics.rectangle("fill", posx,posy, gamedata.overlay.width,gamedata.overlay.height)
		love.graphics.setColor(1,1,1)
		love.graphics.push()
		gamedata.overlay:draw(posx, posy)
		love.graphics.pop()
	end

  -- love.graphics.draw(gamedata.canvas, posx, posy)
  love.graphics.setColor(1, 1, 1)
  for i=1,table.getn(texts) do
    love.graphics.print(texts[i],20,20+(i*16))
  end
  -- if mousePos ~= nil then
    -- love.graphics.setColor(1,1,0,.5)
    -- love.graphics.circle("fill", mousePos[1],mousePos[2], 20)
  -- end
end