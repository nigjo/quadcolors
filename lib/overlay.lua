Overlay= Overlay or {}

local mouseAction = nil

local OverlayStack = {
	layers={},
	push=function(self, newOverlay)
		-- if self~=OverlayStack then error("invalid stack call") end
		table.insert(self.layers, 1, newOverlay)
	end,
	pop=function(self,oldOverlay)
		if #self.layers == 1 then
			print("unable to pop base layer.")
		elseif self.layers[1] == oldOverlay then
			table.remove(self.layers, 1)
		else
			print("unable to pop overlay '"
				..(oldOverlay.name or 'unknown').."', found '"
				..(self.layers[1].name or 'unknown').."'. Stacksize: "..#self.layers)
		end
	end
}

function Overlay:new(w,h)
  local f = {}
  setmetatable(f, self)
  self.__index = self
	f.name="Overlay"

	f.width = w or 0
	f.height = h or 0
	print (f.width.."x"..f.height)
	
	self.init(f)

	return f
end

function Overlay:init()
end

function Overlay:open()
	OverlayStack:push(self)
end

function Overlay:close()
	print("closing overlay '"..(self.name or 'invalid').."'", self)
	if self:closing() then
		print("removing overlay from stack")
		OverlayStack:pop(self)
		self:closed()
		print("overlay closed")
	end
end

function Overlay:closing()
	return true
end

function Overlay:closed()
end


function Overlay:findShape(x,y)
	local context=self
	return {
		name="closeOverlay",
		action=function()
			context:close()
		end
	}
end

function Overlay:keypressed(key)
	if key == "escape" then
		OverlayStack.layers[1]:close()
	end
end

function Overlay:update(dt)
	if self==Overlay then
		if #OverlayStack.layers > 1 then
			gamedata:addPauseTime(dt)
		end
		OverlayStack.layers[1]:update(dt)
	end
end

function Overlay:draw(dx,dy)
	if self==Overlay then
		for i = #OverlayStack.layers, 1, -1 do
			love.graphics.push()
			OverlayStack.layers[i]:draw(dx,dy)
			love.graphics.pop()
		end
	else
		love.graphics.setColor(0,0,0,.66)
		love.graphics.rectangle("fill", posx,posy, self.width, self.height)
		love.graphics.setColor(1,1,1)
	end
end

function Overlay:mousepressed(x, y, button, istouch, presses)
	if self==Overlay then
		if button==1 then
			mouseAction = OverlayStack.layers[1]:findShape(x-posx,y-posy)
			print ("down with "..mouseAction.name)
		else
			mouseAction = nil
		end
	end
end

function Overlay:mousereleased( x, y, button, istouch, presses )
	if self==Overlay then
		if button==1 and mouseAction ~= nil then
			local releaseAction
			releaseAction = OverlayStack.layers[1]:findShape(x-posx,y-posy)
			print ("up with "..releaseAction.name)
			if releaseAction.name == mouseAction.name then
				mouseAction.action()
			end
			releaseAction = nil
		end
		mouseAction = nil
	end
end

