ship = {}
-- Number of remaining lives
ship.lives = 5

-- states:
-- 0: normal
-- 1: invincible
-- 2: reversed controls
-- tbc...
ship.condition = 0

-- weapons:
-- ???
ship.weapons = {}

-- absolute position in an 800x600 world
ship.position = {0,0}

-- change the position cx pixels in x- and cy pixels in y direction
function ship.change_position (self, cx, cy)
	if not (position[0] > H) or not (position[0] < 0) then
		position[0]=position[0]+cx
	end
	if not (position[0] > H) or not (position[0] < 0) then
		position[1]=position[1]+cy
	end
end

