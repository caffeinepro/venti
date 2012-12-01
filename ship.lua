ship = {}
-- Number of remaining lives
ship.lives_ = 5

function ship.lives(self)
	return lives_
end

function ship.lives(new_lives)
	lives_ = new_lives
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

function ship.load(self)
   local img  = love.graphics.newImage(ship.sprite_)
   ship.anim = newAnimation(img, 49, 19, 0.1, 0)
   ship.size_ = {49,19}
end

function ship.update(self)
	-- Updates the animation. (Enables frame changes)
	ship.anim:update(dt)
end

function draw(self)
	ship.anim:draw(sprite,position_[X],position_[Y])
end

-- change the position cx pixels in x- and cy pixels in y direction
function ship.change_position (self, cx, cy)
	-- ship can only navigate inside the viewport
	if not (position_[X] > viewport.position()[X]+viewport.size()[X]+ship.size_[X]) 
	or not (position_[X] < viewport.position()[X]) then
		position_[X]=position_[X]+cx
	end
	if not (position_[Y] > viewport.position[Y]+viewport.size[Y]+ship.size[Y]) 
	or not (position_[Y] < viewport.position[Y]) then
		position_[Y]=position_[Y]+cy
	end
end

function ship.fire()
	-- TODO
end
