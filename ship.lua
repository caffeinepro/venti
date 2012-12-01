local M = {}
local ship = {}

require("lib/AnAL") -- Animations

-- Number of remaining lives
ship.lives_ = 5

function ship.lives(self)
	return self.lives_
end

function ship.lives(new_lives)
	self.lives_ = new_lives
end

-- states:
-- 0: normal
-- 1: invincible
-- 2: reversed controls
-- tbc...
-- TODO
ship.condition_ = 0

-- weapons:
-- TODO
ship.weapons_ = {}

-- size of the ship
ship.size_ = {1,1}

-- absolute position of the upper left corner of the ship 
-- in relation to the upper left corner of the viewport
ship.position_ = {viewport.position()[X],(viewport.position()[Y]+viewport.size()[Y]-(ship.size_[Y]/2))}

-- filename for the sprite of the ship
ship.sprite_ = "resources/rocket_propelled_49_19.png"

-- change the position cx pixels in x- and cy pixels in y direction
function ship.change_position(self, cx, cy)
	-- ship can only navigate inside the viewport
	if not ((self.position_[X] > viewport.position()[X]+viewport.size()[X]+self.size_[X]) 
	or not (self.position_[X] < viewport.position()[X])) then
		self.position_[X]=self.position_[X]+cx
	end
	if not ((self.position_[Y] > viewport.position[Y]+viewport.size[Y]+self.size[Y]) 
	or not (self.position_[Y] < viewport.position[Y])) then
		self.position_[Y]=self.position_[Y]+cy
	end
end

function ship.fire()
	-- TODO
end

function ship.update(self, dt)
	-- Updates the animation. (Enables frame changes)
	self.anim:update(dt)
end

function ship.draw(self)
	self.anim:draw(self.position_[X],self.position_[Y])
end

function ship.init_(self)
	local img  = love.graphics.newImage(ship.sprite_)
	self.anim = newAnimation(img, 49, 19, 0.1, 0)
	self.size_ = {49,19}
end

function M.create()
	new_ship = table_copy(ship,true)
	new_ship:init_()
	return new_ship
end

return M
