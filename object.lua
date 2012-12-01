
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

-- dummy von droggl
function M.create_block(size, position)
	return {
		size_ = size,
		position_ = position,
		draw = function(self)
			love.graphics.setColor(170, 180, 190, 255)
			love.graphics.rectangle('fill',
				self.position_[X], self.position_[Y],
				self.size_[X], self.size_[Y])
		end,
	}
end

return M

