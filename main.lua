
local world = require 'world'
local viewport = require 'viewport'
local ship = require 'ship'

-- main loop, die world von rechts nach links reinschiebt

function love.load()
	viewport.load()
	viewport.set_world(world)
end

function love.update(dt)
	world.update(dt)
	viewport.update(dt)
end

function love.draw()
	world.draw()
	viewport.draw()
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

