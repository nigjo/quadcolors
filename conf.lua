function love.conf(t)
	
	t.identity = "de_nigjo_QuadColors"
	-- t.appendidentity = true
	t.version = "11.3"

	t.window.title = "QuadColors"
	t.window.icon = "res/frame.png"
	t.window.fullscreen = love._os == "Android" or love._os == "iOS"
	t.window.width = 908
	t.window.height = 450
	
	t.accelerometerjoystick = false
end
