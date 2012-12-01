require 'utils'
local world = require 'world'
local viewport = require 'viewport'
local ship_module = require 'ship'
local controller_module = require 'controller'

-- main loop, die world von rechts nach links reinschiebt

function love.load()
	viewport.load()
	ship = ship_module.create()
	controller = controller_module.create(ship)
end

function love.update(dt)
	viewport.update(dt)
	world.update(dt)
	ship:update(dt)
	controller:update(dt)
end

function love.draw()
	--world.draw()
	viewport.draw()
	ship:draw()
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
end

function love.focus(f)
end

function love.quit()
end

