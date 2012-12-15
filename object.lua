
require 'lib/AnAL'
local viewport = require 'viewport'

local M = {}


-- Animation Cache shit

local animation_cache_ = {}

local function cache_image(n)
	local short = string.gsub(n, "[.][^.]+", "")
	animation_cache_[short] = love.graphics.newImage('resources/' .. n)
end

local function cache_animation(n, w, h, delay, frames)
	local short = string.gsub(n, "[.][^.]+", "")
	animation_cache_[short] = {
		love.graphics.newImage('resources/' .. n),
		w, h, delay, frames
	}
end

local function get_animation(n)
	local a = animation_cache_[n]
	if type(a) == 'table' then
		return newAnimation(unpack(a))
	else
		return a
	end
end

local function choose_animation(t)
	local p = math.random()
	local q = 0.0
	for _, v in ipairs(t) do
		q = q + v[1]
		if p <= q then
			return get_animation(v[2])
		end
	end
	return get_animation(t.default)
end

local function cache_animations()
	local imgs = {
		'wall_tile_1_basic.png',
		'wall_tile_1_air.png',
		'wall_tile_1_blood.png',
		'wall_tile_1_crack.png',
		'wall_tile_1_stained.png',
		'slime.png',
		'slime_eye.png'
	}
	for _, i in pairs(imgs) do cache_image(i) end
	
	cache_animation('rocket_propelled_49_19.png', 49, 19, .1, 0)
	cache_animation('rocket_propelled_25_10.png', 25, 10, .1, 0)
end

cache_animations()




-- Object shit

local function create_object(name, size, ...)
	local arg = {...}
	
	local body_type = 'dynamic'
	
	for k, a in pairs(arg) do
		if a == 'static' then
			body_type = 'static'
		end
	end
	
	local new_object = {
		name = name,
		size_ = size,
		size = function(self) return self.size_ end,
		
		body_type_ = body_type,
		body = love.physics.newBody(physical_world, size[X], size[Y], body_type),
		shape = love.physics.newRectangleShape(size[X], size[Y]),
		
		animation_ = nil,
		
		position = function(self) return { self.body:getX(), self.body:getY() } end,
		set_position = function(self, p)
			self.body:setPosition(p[X], p[Y])
			if self.body_type == 'static' and self.redraw ~= nil then
				self.draw = self.redraw
			end
		end,
		
		set_mass = function(self, m) self.body:setMass(m) end,
		set_velocity = function(self, v) self.body:setLinearVelocity(v[X], v[Y]) end,
		
		set_animation = function(self, a)
			self.animation_ = a
			if body_type == 'static' then
				self.draw = function(s)
					love.graphics.setCanvas(viewport.canvas())
					a:draw(s.body:getX(), s.body:getY())
					love.graphics.setCanvas()
					
					-- as this is a static object, painting on canvas once
					-- is enough, only update when position changes!
					self.redraw = self.draw
					self.draw = function(s) end
				end
			else
				self.draw = function(s)
					a:draw(viewport.canvas_to_viewport_x(s.body:getX()), viewport.canvas_to_viewport_y(s.body:getY()))
				end
			end
		end,
		
		set_image = function(self, a)
			self.animation_ = a
			if body_type == 'static' then
				self.draw = function(s)
					love.graphics.setCanvas(viewport.canvas())
					love.graphics.draw(a, s.body:getX(), s.body:getY(), 0, s.size_[X] / a:getWidth(),
						s.size_[Y] / a:getHeight(), 0, 0)
					love.graphics.setCanvas()
					
					-- as this is a static object, painting on canvas once
					-- is enough, only update when position changes!
					self.redraw = self.draw
					self.draw = function(s) end
				end
			else
				self.draw = function(s)
					love.graphics.draw(a,
						viewport.canvas_to_viewport_x(s.body:getX()),
						viewport.canvas_to_viewport_y(s.body:getY()), 0,
						s.size_[X] / a:getWidth(), s.size_[Y] / a:getHeight(), 0, 0)
				end
			end
		end,
		
		update = function(self, dt)
			if self.animation_ ~= nil and self.animation_.update ~= nil then
				self.animation_:update(dt)
			end
		end,
		draw = function(self) end,
		
		destroy = function(self)
			self.body:destroy()
		end,
	}
	
	new_object.fixture = love.physics.newFixture(new_object.body, new_object.shape, 1)
	new_object.fixture:setUserData(new_object)
	
	table.insert(objects, new_object)
	return new_object
end

function M.create_rocket(position, speed)
	local rocket = create_object('Rocket', { 49, 19 })
	rocket:set_animation(get_animation('rocket_propelled_49_19'))
	rocket:set_position({ position[X], position[Y] - 19/2 })
	rocket:set_velocity({ speed[X] or 20, speed[Y] or 0 })
	return rocket
end

function M.create_double_rocket(position1, position2, speed)
	local size = {25, 10}
	
	local rocket1 = create_object('DoubleRocket 1', size)
	rocket1:set_animation(get_animation('rocket_propelled_25_10'))
	rocket1:set_position({ position1[X], position1[Y] - size[Y]/2 })
	rocket1:set_velocity({ speed[X] or 20, speed[Y] or 0 })

	local rocket2 = create_object('DoubleRocket 2', size)
	rocket2:set_animation(get_animation('rocket_propelled_25_10'))
	rocket2:set_position({ position2[X], position2[Y] - size[Y]/2 })
	rocket2:set_velocity({ speed[X] or 20, speed[Y] or 0 })
	
	return { rocket1, rocket2 }
end

function M.create_slime(size, position)
	local slime = create_object('Slime', size, 'static')
	slime:set_image(
		choose_animation {
			{ 0.01, 'slime_eye' },
			default = 'slime'
		}
	)
	slime:set_position(position)
	slime:set_mass(0)
	return slime
end

function M.create_block(size, position)
	local block = create_object('Block', size, 'static')
	block:set_image(
		choose_animation {
			{ 0.05, 'wall_tile_1_blood' },
			{ 0.15, 'wall_tile_1_air' },
			{ 0.10, 'wall_tile_1_crack' },
			{ 0.20, 'wall_tile_1_stained' },
			default = 'wall_tile_1_basic'
		}
	)
	block:set_position(position)
	block:set_mass(0)
	return block
end

return M

