
local M = {}

-- basiskram fuer objekte
-- position, zerstörbar
-- was passiert wenn man gegenfliegt
-- bewegungspfad

-- sub-dinger z.B.
	-- enemy
	-- lebloser kram
	-- goodie

local function create_default_object()
	new_object = {}
	new_object.speed_ = {0,0}
	new_object.position_ = {0,0}
	new_object.size_ = {0,0}

	-- change the position cx pixels in x- and cy pixels in y direction
	function new_object.change_position(self, cx, cy)
		cx = cx or 1
		cy = cy or 0
		local new_position = 
		{
			self.position_[X]+(cx*self.speed_[X]),
			self.position_[Y]+(cy*self.speed_[Y])
		}
		if (new_position[X] - viewport.position()[X] > viewport.size()[X]) then
			self.destroy()
		end
		self.position_=new_position
	end


	function new_object.collision(self, damage) 
	end

	function new_object.destroy(self)
	  
	end

	function new_object.update(self, dt)
		self.anim_:update(dt)
		self:change_position(1,0)
	end

	function new_object.draw(self)
		self.anim_:draw(self.position_[X],self.position_[Y])
	end
	
	table.insert(draw_me, new_object)
	table.insert(update_me, new_object)
	
	return new_object
end

local images_ = {
	wall_basic = love.graphics.newImage('resources/wall_tile_1_basic.png'),
	wall_air = love.graphics.newImage('resources/wall_tile_1_air.png'),
	wall_blood = love.graphics.newImage('resources/wall_tile_1_blood.png'),
	wall_crack = love.graphics.newImage('resources/wall_tile_1_crack.png'),
	wall_stained = love.graphics.newImage('resources/wall_tile_1_stained.png'),
	slime = love.graphics.newImage('resources/slime.png'),
	slime_eye = love.graphics.newImage('resources/slime_eye.png'),
}



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
function M.create_block(size, position)
	local p = math.random()
	local img 
	if p < 0.05 then img = images_.wall_blood
	elseif p < 0.2 then img = images_.wall_air
	elseif p < 0.3 then img = images_.wall_crack
	elseif p < 0.5 then img = images_.wall_stained
	else img = images_.wall_basic
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

return M

