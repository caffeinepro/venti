
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
	
	cache_animation('ship_propelled_50_47.png', 50, 47, .1, 0)
	cache_animation('rocket_propelled_49_19.png', 49, 19, .1, 0)
	cache_animation('rocket_propelled_25_10.png', 25, 10, .1, 0)
end

cache_animations()


-- defines groups of collision objects.
-- objects of the same a negative group dont collide
-- objects of the same a positive group always collide
-- always of different groups are looked up by category (see below)
local groups = {
	static = -1, good = -2, evil = -3
}

-- if groups of colliding objects are different,
-- categories are being matached.
-- collision <=> (catA & maskB) && (catB & maskA)
local cats = {
	background = 0x0001,
	guy = 0x0002,
	bullet = 0x0004,
}

-- defines, for each category of object, which category it collides with.
-- i.e. "background" (solid blocks) collide with "guys", but not with bullets
-- (bullets pass through)
local collision_masks = {
	[cats.background] = cats.guy,
	[cats.guy] = cats.guy + cats.background + cats.bullet,
	[cats.bullet] = cats.guy,
}

-- Object shit

local function create_object(name, size, ...)
	local arg = {...}
	
	local body_type = 'dynamic'
	local canvas = false
	
	for k, a in pairs(arg) do
		d = {
			static = function() body_type = 'static' end,
			canvas = function() canvas = true end,
		}
		if d[a] ~= nil then d[a]() end
	end
	local new_object = {
		health = 100,
		name = name,
		size_ = size,
		size = function(self) return self.size_ end,
		
		set_collision = function(self, group, cat)
			self.fixture:setFilterData(cats[cat], collision_masks[cats[cat]], groups[group])
		end,
		
		body_type_ = body_type,
		body = love.physics.newBody(physical_world, size[X], size[Y], body_type),
		shape = love.physics.newRectangleShape(size[X], size[Y]),
		
		animation_ = nil,
		
		position = function(self) return { self.body:getX(), self.body:getY() } end,
		set_position = function(self, p)
			self.body:setPosition(p[X], p[Y])
			if canvas and self.redraw ~= nil then
				self.draw = self.redraw
			end
		end,
		
		set_mass = function(self, m) self.body:setMass(m) end,
		set_velocity = function(self, v) self.body:setLinearVelocity(v[X], v[Y]) end,
		
		set_animation = function(self, a)
			self.animation_ = a
			if canvas then
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
			if canvas then
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
		
		deal_damage = function(self, n)
			self.health = self.health - n
			if self.health <= 0 then
				self:die()
			end
		end,
		
		die = function(self)
			self.draw = function(self) end
			if self.body ~= nil then
				self.body:destroy()
				self.body = nil
			end
			self.fixture = nil
			self.shape = nil
			self.destroy = function(self) end
			self.update = function(self, dt) end
			self.draw = function(self) end
			self.dead = true
		end,
		
		dead = false,
	}
	
	new_object.fixture = love.physics.newFixture(new_object.body, new_object.shape, 1)
	new_object.fixture:setUserData(new_object)
	
	table.insert(objects, new_object)
	return new_object
end

function M.create_ship(position, speed, size)
	local ship = create_object('Ship', size)
	local ship_animation = get_animation('ship_propelled_50_47')
	ship:set_animation(ship_animation)
	ship:set_position(position)
	ship:set_velocity(speed)
	ship.body:setBullet(true)
	ship:set_mass(0)
	
	ship.deal_damage = function(self, n) end
	ship:set_collision('good', 'guy')
	
	ship.update = function(self, dt)
		if (self:position()[X]
		< viewport.position()[X]) then
			self:set_position(
			{
				viewport.position()[X],
				self:position()[Y]
			})
		end
		if (self:position()[X]
		> viewport.position()[X]+viewport.size()[X]-self:size()[X]) then
		self:set_position(
		{
			viewport.position()[X]+viewport.size()[X]-self:size()[X],
			self:position()[Y]
		})
		end
		
		
		if self.animation_ ~= nil and self.animation_.update ~= nil then
			self.animation_:update(dt)
		end
	end
	
	function ship.on_collide(self, other, contact)
		-- self:die()
	end
	return ship
end

function M.create_rocket(position, speed)
	local rocket = create_object('Rocket', { 49, 19 })
	rocket:set_animation(get_animation('rocket_propelled_49_19'))
	rocket:set_position({ position[X], position[Y] - 19/2 })
	rocket:set_velocity({ speed[X] or 20, speed[Y] or 0 })
	rocket.body:setBullet(true)
	rocket:set_collision('good', 'bullet')
	
	function rocket.on_collide(self, other, contact)
		other:deal_damage(100)
		self:die()
	end
	
	return rocket
end

function M.create_double_rocket(position1, position2, speed)
	local size = {25, 10}
	
	local rocket1 = create_object('DoubleRocket 1', size)
	rocket1:set_animation(get_animation('rocket_propelled_25_10'))
	rocket1:set_position({ position1[X], position1[Y] - size[Y]/2 })
	rocket1:set_velocity({ speed[X], -speed[Y] })
	rocket1.body:setBullet(true)
	rocket1:set_collision('good', 'bullet')
	
	function rocket1.on_collide(self, other, contact)
			other:deal_damage(50)
			self:die()
	end

	local rocket2 = create_object('DoubleRocket 2', size)
	rocket2:set_animation(get_animation('rocket_propelled_25_10'))
	rocket2:set_position({ position2[X], position2[Y] - size[Y]/2 })
	rocket2:set_velocity({ speed[X], speed[Y] })
	rocket2.body:setBullet(true)
	rocket2:set_collision('good', 'bullet')
	
	function rocket2.on_collide(self, other, contact)
			other:deal_damage(50)
			self:die()
	end
	
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
	slime:set_collision('evil', 'guy')
	slime:set_position(position)
	slime:set_mass(0)
	return slime
end

function M.create_block(size, position)
	local block = create_object('Block', size, 'static', 'canvas')
	block:set_image(
		choose_animation {
			{ 0.05, 'wall_tile_1_blood' },
			{ 0.15, 'wall_tile_1_air' },
			{ 0.10, 'wall_tile_1_crack' },
			{ 0.20, 'wall_tile_1_stained' },
			default = 'wall_tile_1_basic'
		}
	)
	block:set_collision('static', 'background')
	block:set_position(position)
	block:set_mass(0)
	return block
end

return M

