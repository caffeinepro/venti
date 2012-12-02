local M = {}
local controller = {}

function controller.fire(self)
end

function controller.keypressed(self, key)
	if key == self.up_key_ then self.directions_[Y] = -1 end
	if key == self.down_key_ then self.directions_[Y] = 1 end
	if key == self.left_key_ then self.directions_[X] = -1 end
	if key == self.right_key_ then self.directions_[X] = 1 end
	if key == self.fire_key_ then self.fire_ = true end
end

function controller.keyreleased(self, key)
	if key == self.up_key_ then self.directions_[Y] = 0 end
	if key == self.down_key_ then self.directions_[Y] = 0 end
	if key == self.left_key_ then self.directions_[X] = 0 end
	if key == self.right_key_ then self.directions_[X] = 0 end
	if key == self.fire_key_ then self.fire_ = false end
end

function controller.update(self)
	if (self.directions_[X] ~= 0
	or self.directions_[Y] ~= 0) then
		self.ship_:change_position(self.directions_[X],self.directions_[Y])
	end
	if self.fire then
		self.ship_:fire()
	end
end

function controller.init_(self, ship)
	--[[
		directions:
		-1 0 1
		 0
		 1
	]]--
	self.directions_ = {0,0}
	self.up_key_ = "up"
	self.down_key_ = "down"
	self.left_key_ = "left"
	self.right_key_ = "right"
	self.fire_key_ = " "

	self.fire_ = false
	
	self.ship_ = ship
end

function M.create(ship)
	local new_controller = table_copy(controller,true)
	new_controller:init_(ship)
	return new_controller
end

return M
