local M = {}



local function init_controller(ship)
	--[[
		directions:
		-1 0 1
		 0
		 1
	]]--
	local controller = {}
	
	controller.directions_ = {0,0}
	controller.up_key_ = "up"
	controller.down_key_ = "down"
	controller.left_key_ = "left"
	controller.right_key_ = "right"
	controller.fire_key_ = " "

	controller.fire_ = false
	
	controller.ship_ = ship
	
	function controller.keypressed(self, key)
		if key == self.up_key_ then self.directions_[Y] = self.directions_[Y] - 1 end
		if key == self.down_key_ then self.directions_[Y] = self.directions_[Y] + 1 end
		if key == self.left_key_ then self.directions_[X] = self.directions_[X] - 1 end
		if key == self.right_key_ then self.directions_[X] = self.directions_[X] + 1 end
		if key == self.fire_key_ then self.fire_ = true end
	end

	function controller.keyreleased(self, key)
		if key == self.up_key_ then self.directions_[Y] = self.directions_[Y] + 1 end
		if key == self.down_key_ then self.directions_[Y] = self.directions_[Y] - 1 end
		if key == self.left_key_ then self.directions_[X] = self.directions_[X] + 1 end
		if key == self.right_key_ then self.directions_[X] = self.directions_[X] - 1 end
		if key == self.fire_key_ then self.fire_ = false end
	end

	function controller.update(self,dt)
		if (self.directions_[X] ~= 0
		or self.directions_[Y] ~= 0) then
			self.ship_:change_position(self.directions_[X],self.directions_[Y])
		end
		if (self.fire_==true) then
			self.ship_:fire()
		end
	end
	
	table.insert(update_me, controller)
	return controller
end

function M.create(ship)
	local new_controller = table_copy(controller,true)
	new_controller = init_controller(ship)
	return new_controller
end

return M
