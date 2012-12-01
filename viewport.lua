
require 'constants'

local M = {}

local size_ = {800, 600}
local position_ = {0, 0}
local speed_ = 100.0
local canvas_size_ = {2000, size_[Y]}
local canvas_
local world_
local schedule_next_canvas_ = false
local world_fill_position_ = 0
local world_fill_min_ = math.floor(size_[X] * 1.5)

local function init_canvas()
	canvas_ = love.graphics.newCanvas(canvas_size_[X], canvas_size_[Y])
	--love.graphics.setCanvas(canvas_)
	print("canvas inited:", canvas_, canvas_size_[X], canvas_size_[Y])
	print("getCanvas:", love.graphics.getCanvas())
end

local function next_canvas()
	print("next_canvas()")
	schedule_next_canvas_ = false
	
	local canvas = love.graphics.newCanvas(canvas_size_[X], canvas_size_[Y])
	love.graphics.setCanvas(canvas)
	love.graphics.draw(canvas_, 0, 0, 0, 1, 1, position_[X], position_[Y])
	canvas_ = canvas
	world_fill_position_ = world_fill_position_ - position_[X] 
	position_[X] = 0
end

function M.load() init_canvas() end

function M.size() return size_ end
function M.position() return position_ end
function M.canvas_size() return canvas_size_ end
function M.canvas() return canvas_ end
function M.set_world(w) world_ = w end

function M.viewport_to_canvas_x(x)
	return x + position_[X]
end
function M.viewport_to_canvas(p)
	return {p[X] + position_[X], p[Y] + position_[Y]}
end

function M.update(dt)
	local delta = math.floor(dt * speed_)
	position_[X] = position_[X] + delta
	world_fill_position_ = world_fill_position_ -- delta
	
	local fill_left = world_fill_position_
	local fill_right = M.viewport_to_canvas_x(0) + world_fill_min_
	if fill_right > canvas_size_[X] then
		fill_right = canvas_size_[X]
	end
	if world_ ~= nil and fill_right > fill_left then
		local old = world_fill_position_ 
		world_fill_position_ = world_.fill(fill_left, fill_right)
		print(world_fill_position_ - old)
	end
	
	if position_[X] > canvas_size_[X] - size_[X] then
		schedule_next_canvas_ = true
	end
end

function M.draw()
	if schedule_next_canvas_ then next_canvas() end
	
	--love.graphics.setCanvas()
	--love.graphics.setColor(200, 0, 0, 155)
	--love.graphics.rectangle("fill", 0, 0, 100, 100)
	
	love.graphics.setCanvas()
	love.graphics.draw(canvas_, 0, 0, 0, 1, 1, position_[X], position_[Y])
	--love.graphics.setCanvas(canvas_)
	
	--love.graphics.setColor(0, 200, 0, 255)
	--love.graphics.circle("fill", 400, 400, 10)
	
end

return M

