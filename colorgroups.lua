local function hexToCol(hex)
	-- Idea from https://love2d.org/forums/viewtopic.php?p=58171#p58171
	_,_,r,g,b,a = (hex.."FF"):find('(%x%x)(%x%x)(%x%x)(%x%x)')
	-- print(hex,r,g,b,a)
	if a == nil then a = 255 end
	local hexToN = function(val)
		return (math.floor(tonumber(val,16))%256)/255
	end
	-- print(hexToN(r),hexToN(g),hexToN(b),hexToN(a))
	return {hexToN(r),hexToN(g),hexToN(b),hexToN(a)}
end
return {
	default={
		{1,0.5,0.25,1},
		{0,0.75,0.25,1},
		{0.25,0,1,1},
		{1,0.25,1,1}
	},
	rgb={
		{.5,.5,.5,1},
		{.9,.1,.1,1},
		{0,.66,0,1},
		{0,0,1,1}
	},
	blindnes={
		{.8,.8,0,1},
		{1,0,1,1},
		{0,.8,.5,1},
		{.5,.5,.5,1}
	},
	ItoOkabe={  -- https://jfly.uni-koeln.de/color/
		-- {0,0,0,1}, -- Black
		-- {.9,.6,0,1}, -- Orange
		-- {.35,.7,.9,1}, -- Sky Blue
		{0,.6,.5,1}, -- bluish Green
		-- {.95,.9,.25,1}, -- Yellow
		{0,.45,.7,1}, -- Blue
		{.8,.4,.0,1}, -- Vermilion
		{.8,.6,.7,1} -- reddish Purple
	},
	grayscales={
		{.8,.8,.8,1},
		{.6,.6,.6,1},
		{.35,.35,.35,1},
		{.15,.15,.15,1},
	},
	SomeOtherArielColors={ -- https://www.color-hex.com/color-palette/103239
		hexToCol("ff0500"),
		hexToCol("c594ff"),
		hexToCol("ffec94"),
		hexToCol("1ae272")
	},
	OviPureMinerals={--https://www.color-hex.com/color-palette/103296
		hexToCol("b9f2ff"),
		hexToCol("008000"),
		hexToCol("ffd700"),
		hexToCol("cd7f32")
	},
	MetroUIColors={--https://www.color-hex.com/color-palette/700
		hexToCol("d11141"),
		-- hexToCol("00b159"),
		hexToCol("00aedb"),
		hexToCol("f37735"),
		hexToCol("ffc425")
	},
	qoolors_1={--https://poolors.com/fcb600-ce3561-074974-1f9db8
		hexToCol("fcb600"),
		hexToCol("ce3561"),
		hexToCol("074974"),
		hexToCol("1f9db8")
	},
	qoolors_2={--https://poolors.com/0c0b23-fac855-fbfaf6-08b7a0
		hexToCol("0c0b23"),
		hexToCol("fac855"),
		hexToCol("fbfaf6"),
		hexToCol("08b7a0")
	}
}
