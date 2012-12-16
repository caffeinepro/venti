local M = {}
local ship = {}

require 'lib/AnAL' -- Animations
local object = require 'object'

function ship.lives(self)
	return self.lives_
end

function ship.size(self)
	return self.size
end

function ship.lives(new_lives)
	self.lives_ = new_lives
end


local function init_(new_ship)
	-- Number of remaining lives
	new_ship.lives_ = 5
	
	-- weapons:
	-- 1:rocket
	-- 2:double rocket
	new_ship.weapons_ = {1,2}
	new_ship.weapon_ = 1

	new_ship.fire_delay_ = 0.5
	new_ship.last_fire_ = love.timer.getTime( )-1000
	
	function new_ship.select_weapon(self, number)
		if self.weapons_[number] ~= nil then
			self.weapon_ = number
			if number == 1 then self.fire_delay_=0.5 end
			if number == 2 then self.fire_delay_=0.2 end
		end
	end
	
	function new_ship.fire(self)
		if(love.timer.getTime( ) - self.last_fire_ > self.fire_delay_) then
			local center={
				self:position()[X]+self:size()[X]+1,
				self:position()[Y]+self:size()[Y]/2
			}
			local wing1={
				self:position()[X]+1,
				self:position()[Y]
			}
			local wing2={
				self:position()[X]+1,
				self:position()[Y]+self:size()[Y]
			}
		
			self.last_fire_ = love.timer.getTime( )
			if self.weapon_==1 then object.create_rocket(center,{400,0}) end
			if self.weapon_==2 then object.create_double_rocket(wing1, wing2, {600, 100}) end
		end
	end
	
end

function M.create()
	local size = { 50, 47 }
	local start_position = viewport.viewport_to_canvas({0,(viewport.size()[Y]/2-(size[Y]/2))})
	new_ship = object.create_ship(start_position, {viewport.speed()+100,viewport.speed()}, size)
	init_(new_ship)
	return new_ship
end

return M
