--[[ 
-- LOADING SCREEN
-- Uncomment to activate
-- Can be an image for example

love.graphics.clear(255,255,255)
local w, h = love.window.getMode()

> love.graphics.draw(...)
> love.graphics.print(...)
> ...

love.graphics.present()
]]--


-- this fixes compatibility for LÖVE v11.x colors (0-255 instead of 0-1)
require('lib.compatibility')
--
require('lib.colors')
-- Load Libraries
local ScreenManager = require('lib.ScreenManager')
socket = require('lib.socket_m')
--

-- Load Screens
local MainScreen = require('screens.mainoff')  
local CreateRoomScreen = require('screens.createroom')
local JoinRoomScreen = require('screens.joinroom')
local AboutScreen = require('screens.about')
local TrackScreen = require('screens.track')
local FinishScreen = require('screens.finishoff') 
--


-- Load Game
function love.load()
	-- 初始化网络
	socket:load()

	local screenManager = ScreenManager()
	-- Register your screens here (A screen with the path '/' is mandatory!)
	screenManager:register('/', MainScreen)
	screenManager:register('room/create', CreateRoomScreen)
	screenManager:register('room/join', JoinRoomScreen)
	screenManager:register('game/about', AboutScreen)
	screenManager:register('game/track', TrackScreen)
	screenManager:register('game/finish', FinishScreen)
	-- screenManager:register('game/run', RunScreen)
	
	-- Load the main screen. Only needed if you didn't register a screen with path "/"
	--screenManager:view('test/index', 'Wow!')
end
--


