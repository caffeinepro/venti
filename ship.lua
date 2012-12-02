local M = {}
local ship = {}

require("lib/AnAL") -- Animations

function ship.lives(self)
	return self.lives_
end

function ship.size(self)
	return self.size
end

function ship.lives(new_lives)
	self.lives_ = new_lives
end

-- change the position cx pixels in x- and cy pixels in y direction
function ship.change_position(self, cx, cy)
	-- ship can only navigate inside the viewport
	if ((self.position_view_[X]+self.size_[X]+cx < viewport.size()[X]) 
	and (self.position_view_[X]+cx >= 0)) then
		self.position_view_[X]=self.position_view_[X]+(cx*self.speed_)
	end
	if ((self.position_view_[Y]+self.size_[Y]+cy < viewport.size()[Y]) 
	and (self.position_view_[Y]+cy >= 0)) then
		self.position_view_[Y]=self.position_view_[Y]+(cy*self.speed_)
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
	love.graphics.setCanvas()
	self.anim:draw(self.position_view_[X],self.position_view_[Y])
end

function ship.init_(self)
	-- Number of remaining lives
	self.lives_ = 5
	
	self.speed_ = 10
	-- weapons:
	-- TODO
	self.weapons_ = {}

	-- size of the ship
	self.size_ = {1,1}

	-- absolute position of the upper left corner of the ship 
	-- in relation to the upper left corner of the viewport
	self.position_view_ = {0,(viewport.size()[Y]/2-(self.size_[Y]/2))}
	-- and in relation to the upper left corner of the canvas
	self.position_canvas_ = 
	{
		viewport.position()[X] + self.position_view_[X],
		viewport.position()[Y] + self.position_view_[Y]
	}

	-- filename for the sprite of the ship
	self.sprite_ = "resources/ship_propelled_50_47.png"
	local img  = love.graphics.newImage(self.sprite_)
	self.anim = newAnimation(img, 50, 47, 0.1, 0)
	self.size_ = {50,47}
end

function M.create()
	new_ship = table_copy(ship,true)
	new_ship:init_()
	return new_ship
end

return M
