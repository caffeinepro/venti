
require 'constants'

local M = {}

local size_ = {800, 600}
local position_ = {0, 0}
local speed_ = 200.0
local background_speed_ = speed_ / 2.0
local canvas_size_ = {2048, size_[Y]}
local canvas_
local world_
local schedule_next_canvas_ = false
local world_fill_position_ = 0
local world_fill_min_ = math.floor(size_[X] * 1.2)
local background_
local background_position_

local function init_canvas()
	canvas_ = love.graphics.newCanvas(canvas_size_[X], canvas_size_[Y])
end

local function next_canvas()
	schedule_next_canvas_ = false
	
	local canvas = love.graphics.newCanvas(canvas_size_[X], canvas_size_[Y])
	love.graphics.setCanvas(canvas)
	love.graphics.draw(canvas_, 0, 0, 0, 1, 1, position_[X], position_[Y])
	canvas_ = canvas
	world_fill_position_ = world_fill_position_ - position_[X] 
	
	
	local objs = 0
	local deleted = 0
	for k, v in pairs(objects) do
		objs = objs + 1
		if v ~= nil and v.position ~= nil then
			v:set_position({
				v:position()[X] - position_[X],
				v:position()[Y]
			})
			
			if v:position()[X] < -v:size()[X] or
				v:position()[X] > canvas_size_[X] then
				deleted = deleted + 1
				if v.destroy ~= nil then
					v:destroy()
				end
				objects[k] = nil
			end
		end
	end
	
	print("next_canvas() objs=" .. tostring(objs) .. " deleted=" .. tostring(deleted))
	
	position_[X] = 0
end

function M.load()
	init_canvas()
	background_ = love.graphics.newImage('resources/rock.png')
	background_position_ = 0
end

function M.size() return size_ end
function M.position() return position_ end
function M.canvas_size() return canvas_size_ end
function M.canvas() return canvas_ end
function M.set_world(w) world_ = w end

function M.viewport_to_canvas_x(x)
	return x + position_[X]
end
function M.viewport_to_canvas(p) return { p[X] + position_[X], p[Y] + position_[Y] } end
function M.canvas_to_viewport(p) return { p[X] - position_[X], p[Y] - position_[Y] } end
function M.canvas_to_viewport_x(x) return x - position_[X] end
function M.canvas_to_viewport_y(y) return y - position_[Y] end

function M.update(dt)
	if schedule_next_canvas_ then return end
	
	local delta = math.floor(dt * speed_)
	position_[X] = position_[X] + delta
	background_position_ = background_position_ + dt * background_speed_
	if background_position_ > background_:getWidth() then
		background_position_ = background_position_ - background_:getWidth()
	end
	
	local fill_left = world_fill_position_
	local fill_right = M.viewport_to_canvas_x(0) + world_fill_min_
	if fill_right > canvas_size_[X] then
		fill_right = canvas_size_[X]
	end
	if world_ ~= nil and fill_right > fill_left then
		local old = world_fill_position_ 
		world_fill_position_ = world_.fill(fill_left, fill_right)
	end
	
	if position_[X] > canvas_size_[X] - (world_fill_min_ + 50) then
		schedule_next_canvas_ = true
	end
end

function M.draw()
	if schedule_next_canvas_ then next_canvas() end
	
	love.graphics.setCanvas()
	drawColored(background_, 0, 0, 0, 1, 1, background_position_, 0, {130, 100, 100, 255})

	
	if background_position_ + size_[X] > background_:getWidth() then
		drawColored(background_, background_:getWidth() - background_position_, 0, 0, 1, 1, 0, 0, {130, 100, 100, 255})
	end
	
	love.graphics.draw(canvas_, 0, 0, 0, 1, 1, position_[X], position_[Y])
end

return M

