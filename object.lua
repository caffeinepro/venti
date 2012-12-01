
local M = {}

-- basiskram fuer objekte
-- position, zerstörbar
-- was passiert wenn man gegenfliegt
-- bewegungspfad

-- sub-dinger z.B.
	-- enemy
	-- lebloser kram
	-- goodie


-- dummy von droggl
function M.create_block(size, position)
	return {
		size_ = size,
		position_ = position,
		draw = function(self)
			love.graphics.setColor(200, 220, 240, 255)
			love.graphics.rectangle('fill',
				self.position_[X], self.position_[Y],
				self.size_[X], self.size_[Y])
		end,
	}
end

return M

