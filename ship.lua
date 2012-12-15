local M = {}
local ship = {}

require 'lib/AnAL' -- Animations
local weapons = require 'object'

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
	local new_position = 
	{
		self.position_view_[X]+(cx*self.speed_),
		self.position_view_[Y]+(cy*self.speed_)
	}
	-- ship can only navigate inside the viewport
	if (new_position[X]+self.size_[X] > viewport.size()[X]) then
		new_position[X]=viewport.size()[X]-self.size_[X]
	end
	if (new_position[X] < 0) then
		new_position[X] = 0
	end
	
	if (new_position[Y]+self.size_[Y] > viewport.size()[Y]) then
		new_position[Y]=viewport.size()[Y]-self.size_[Y]
	end
	if (new_position[Y] < 0) then
		new_position[Y]=0
	end
	self.position_view_=new_position
end

function ship.fire(self)
	if(love.timer.getTime( ) - self.last_fire_ > self.fire_delay_) then
		local center={
			self.position_canvas_[X]+self.size_[X],
			self.position_canvas_[Y]+self.size_[Y]/2
		}
		local wing1={
			self.position_canvas_[X],
			self.position_canvas_[Y]
		}
		local wing2={
			self.position_canvas_[X],
			self.position_canvas_[Y]+self.size_[Y]
		}
		
		self.last_fire_ = love.timer.getTime( )
		if self.weapon_==1 then weapons.create_rocket(center,{800,0}) end
		if self.weapon_==2 then weapons.create_double_rocket(wing1, wing2,{1200,0}) end
	end
end

function ship.select_weapon(self, number)
	if self.weapons_[number] ~= nil then
		self.weapon_ = number
		if number == 1 then self.fire_delay_=0.5 end
		if number == 2 then self.fire_delay_=0.1 end
	end
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
	-- 1:rocket
	-- 2:double rocket
	self.weapons_ = {1,2}
	self.weapon_ = 1

	-- size of the ship
	self.size_ = {1,1}
	
	self.fire_delay_ = 0.5
	self.last_fire_ = love.timer.getTime( )-1000

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
	table.insert(objects, self)
end

function M.create()
	new_ship = table_copy(ship,true)
	new_ship:init_()
	return new_ship
end

return M
