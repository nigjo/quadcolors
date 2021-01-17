local Locale=Local or {initialized=false}

local function loadLocale(self, lang)
	print("try to load "..lang)
	self.lastLocale = lang
	if love.filesystem.getInfo('lang/'..lang..'.lua', 'file') ~= nil then
		local langdata = require('lang/'..lang)
		for k,v in pairs(langdata) do
			self.texts[k] = v
		end
	else
		print("... not found")
	end
end

function Locale:init()
	self.texts={}
	loadLocale(self, 'en')
end

function Locale:getLocale()
	return self.lastLocale
end

function Locale:setLocale(newlang)
	self:init()
	loadLocale(self, newlang)
end

Locale.get = function(key)
	return Locale.texts[key] ~= nil and Locale.texts[key] or key
end

if not Locale.initialized then Locale:init() end
return Locale