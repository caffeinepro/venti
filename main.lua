-- list of all objects to be updated or drawn
objects = {}
physical_world = nil

require 'utils'
local world = require 'world'
local viewport = require 'viewport'
local ship_module = require 'ship'
local controller_module = require 'controller'
local music = require 'music'

-- main loop, die world von rechts nach links reinschiebt

function love.load()
	engine_sound = love.audio.newSource("resources/engine.ogg")
	engine_sound:setVolume(100.0)
	engine_sound:setPitch(0.8)
	engine_sound:setLooping( 0 )
	love.audio.play(engine_sound)
	-- music = love.audio.newSource("resources/music.ogg")
	-- music:setVolume(1.0)
	-- music:setPitch(1.0)
	-- music:setLooping( 0 )
	-- love.audio.play(music)	
	world.load()
	music.load()
	viewport.load()
	viewport.set_world(world)
	ship = ship_module.create()
	controller = controller_module.create(ship)
	love.physics.setMeter(64)
	physical_world = love.physics.newWorld(0, 9.81, true)

end

function love.update(dt)
	music.update(dt)
	world.update(dt)
	viewport.update(dt)
	for i,v in pairs(objects) do
		if v.update ~= nil then
			v:update(dt)
		end
	end
end

function love.draw()
	world.draw()
	viewport.draw()
	for i,v in pairs(objects) do
		if v.draw ~= nil then
			v:draw()
		end
	end
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
	controller:keypressed(key)
end

function love.keyreleased(key, unicode)
	controller:keyreleased(key)
end

function love.focus(f)
end

function love.quit()
end

