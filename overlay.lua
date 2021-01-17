Overlay={}

function Overlay:new(w,h)
  local f = {}
  setmetatable(f, self)
  self.__index = self


	f.width = w or 0
	f.height = h or 0
	print (f.width.."x"..f.height)

	self.init(f)

	return f
end

function Overlay:init()
end

function Overlay:close()
	gamedata.overlay = nil
	self:closing()
end

function Overlay:findShape(x,y)
	return {
		name="closeOverlay",
		action=function()
			self:close()
		end
	}
end

function Overlay:closing()
end

function Overlay:keypressed(key)
	if key == "escape" then
		self:close()
	end
end

function Overlay:update(dt)
end

function Overlay:draw(dx,dy)
end

