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

-- change the position cx pixels in x- and cy pixels in y direction
function ship.change_position(self, cx, cy)
	-- ship can only navigate inside the viewport
	if not ((self.position_view_[X]+self.size_[X] > viewport.size()[X]-1) 
	or not (self.position_view_[X] < 0)) then
		self.position_view_[X]=self.position_view_[X]+cx
	end
	if not ((self.position_view_[Y]+self.size_[Y] > viewport.size()[Y]-1) 
	or not (self.position_view_[Y] < 0)) then
		self.position_view_[Y]=self.position_view_[Y]+cy
	end
end

function ship.fire()
	-- TODO
end

function ship.update(self, dt)
	self.position_canvas_ = 
	{
		viewport.position()[X]+self.position_view_[X],
		viewport.position()[Y]+self.position_view_[Y]
	}
	-- Updates the animation. (Enables frame changes)
	self.anim:update(dt)
end

function ship.draw(self)
	self.anim:draw(self.position_canvas_[X],self.position_canvas_[Y])
	--self.anim:draw(100,100)
end

function ship.init_(self)
	-- states:
	-- 0: normal
	-- 1: invincible
	-- 2: reversed controls
	-- tbc...
	-- TODO
	self.condition_ = 0

	-- weapons:
	-- TODO
	self.weapons_ = {}

	-- size of the ship
	self.size_ = {1,1}

	-- absolute position of the upper left corner of the ship 
	-- in relation to the upper left corner of the viewport
	self.position_view_ = {0,(viewport.size()[Y]-(self.size_[Y]/2))}
	-- and in relation to the upper left corner of the canvas
	self.position_canvas_ = 
	{
		viewport.position()[X] + self.position_view_[X],
		viewport.position()[Y] + self.position_view_[Y]
	}

	-- filename for the sprite of the ship
	self.sprite_ = "resources/rocket_propelled_49_19.png"
	local img  = love.graphics.newImage(self.sprite_)
	self.anim = newAnimation(img, 49, 19, 0.1, 0)
	self.size_ = {49,19}
end

function M.create()
	new_ship = table_copy(ship,true)
	new_ship:init_()
	return new_ship
end

return M
