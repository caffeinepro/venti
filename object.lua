
local M = {}
local physics_w_ = {}

-- basiskram fuer objekte
-- position, zerstörbar
-- was passiert wenn man gegenfliegt
-- bewegungspfad

-- sub-dinger z.B.
	-- enemy
	-- lebloser kram
	-- goodie
local images_ = {
	wall_basic = love.graphics.newImage('resources/wall_tile_1_basic.png'),
	wall_air = love.graphics.newImage('resources/wall_tile_1_air.png'),
	wall_blood = love.graphics.newImage('resources/wall_tile_1_blood.png'),
	wall_crack = love.graphics.newImage('resources/wall_tile_1_crack.png'),
	wall_stained = love.graphics.newImage('resources/wall_tile_1_stained.png'),
	slime = love.graphics.newImage('resources/slime.png'),
	slime_eye = love.graphics.newImage('resources/slime_eye.png'),
}



function M.load(physics_world)
	physics_w_ = physics_world
end

function M.create_default_object(size, position)
	size_ = size
	position_ = position
	local new_object = {}
	new_object.body = love.physics.newBody(physics_w_, size_[X], size_[Y], "dynamic")
	new_object.shape = love.physics.newRectangleShape(size_[X], size_[Y])
	new_object.fixture = love.physics.newFixture(new_object.body,new_object.shape,1)

	local img = images_.wall_basic

	function new_object.collision(self, damage) 
	end

	--function new_object.destroy(self)
	--	table.remove(draw_me, new_object)
--		table.remove(update_me, new_object)
--	end

	function new_object.update(self, dt)
	--	self.anim_:update(dt)
		--self:change_position(1,0)
	end

	function new_object.draw(self)
		love.graphics.draw(img,
			new_object.body:getX(), new_object.body:getY(), 0,
			size_[X] / img:getWidth(),
			size_[Y] / img:getHeight(),0,0)
		--self.anim_:draw(self.phys.getX(),self.phys.getY())
	end
	
	--table.insert(draw_me, new_object)
	--table.insert(update_me, new_object)
	
	return new_object
end

function M.create_block(size, position)
  return M.create_default_object(size,position)
end


function M.create_rocket(position, speed)
	local rocket = create_default_object()
	local size = {49,19}
	local img = love.graphics.newImage('resources/rocket_propelled_49_19.png')
	rocket.anim_ = newAnimation(img, size[X], size[Y], 0.1, 0)
	rocket.position_ = {position[X], position[Y] - size[Y]/2}
	rocket.speed_ = speed or 20
	rocket.size_ = size
	return new_rocket
end

function M.create_double_rocket(position1, position2, speed)
	local rocket1 = create_default_object()
	local rocket2 = create_default_object()
	local size = {25,10}
	local img = love.graphics.newImage('resources/rocket_propelled_25_10.png')
	rocket1.anim_ = newAnimation(img, size[X], size[Y], 0.1, 0)
	rocket1.position_ = {position1[X], position1[Y] - size[Y]/2}
	rocket1.speed_ = speed or 20
	rocket1.size_ = size
	rocket2.anim_ = newAnimation(img, size[X], size[Y], 0.1, 0)
	rocket2.position_ = {position2[X], position2[Y] - size[Y]/2}
	rocket2.speed_ = speed or 20
	rocket2.size_ = size	return new_rocket
end

function M.create_slime(size, position)
	local p = math.random()
	local img 
	if p < 0.01 then img = images_.slime_eye
	else img = images_.slime
	end
	return {
		size_ = size,
		position_ = position,
		image_ = img,
		draw = function(self)
			love.graphics.draw(self.image_,
				self.position_[X], self.position_[Y], 0,
				self.size_[X] / self.image_:getWidth(),
				self.size_[Y] / self.image_:getHeight(), 0, 0)
		end,
	}
end

-- dummy von droggl
--[[
function M.create_block(size, position)
	local p = math.random()
	local img 
	--if p < 0.05 then img = images_.wall_blood
	--elseif p < 0.2 then img = images_.wall_air
	--elseif p < 0.3 then img = images_.wall_crack
	--elseif p < 0.5 then img = images_.wall_stained
	--else img = images_.wall_basic
	img = images_.wall_basic
	--end
	self.body = love.physics.newBody(physics_w_, size[X], size[Y], "dynamic"),
	
	return {
		--defobj = create_default_object(),
		--size
		size_ = size,
		position_ = position,
		image_ = img,
		self.shape = love.physics.newRectangleShape(size[X], size[Y])
		fixture = love.physics.newFixture(body,shape,2),
		draw = function(self)
			love.graphics.draw(self.image_,
				self.position_[X], self.position_[Y], 0,
				self.size_[X] / self.image_:getWidth(),
				self.size_[Y] / self.image_:getHeight(), 0, 0)
		end,
	}
end
]]--
return M

