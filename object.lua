
local M = {}

-- basiskram fuer objekte
-- position, zerstörbar
-- was passiert wenn man gegenfliegt
-- bewegungspfad

-- sub-dinger z.B.
	-- enemy
	-- lebloser kram
	-- goodie

object = {}

object.x1 = ""
object.x2 = ""
object.y1 = ""
object.y2 = ""
object.destructable = ""

function object.createblock(self,x1,x2,y1,y2)
end

function object.collision(self, damage) 
end

function object.destroy(self)
  
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

