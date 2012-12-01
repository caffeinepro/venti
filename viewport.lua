
require 'constants'

local M = {}

local size_ = {800, 600}
local position_ = {0, 0}
local speed_ = 30.0
local canvas_size_ = {2048, size_[Y]}
local canvas_ = nil

local function init_canvas()
	canvas_ = love.graphics.newCanvas(canvas_size_[X], canvas_size_[Y])
	love.graphics.setCanvas(canvas_)
	print("canvas inited:", canvas_size_[X], canvas_size_[Y])
end

local function next_canvas()
	local canvas = love.graphics.newCanvas(canvas_size_[X], canvas_size_[Y])
	canvas:renderTo(
		love.graphics.draw(canvas_, 0, 0, 0, 1, 1, position_[X], position_[Y])
	)
	position_[X] = 0
	canvas_ = canvas
	love.graphics.setCanvas(canvas_)
end

function M.load() init_canvas() end

function M.size() return size_ end
function M.position() return position_ end
function M.canvas_size() return canvas_size_ end

function M.viewport_to_canvas(p)
	return {p[X] + position_[X], p[Y] + position_[Y]}
end

function M.update(dt)
	position_[X] = position_[X] + dt * speed_
	print("pos=", position_[X])
	if position_[X] > canvas_size_[X] - size_[X] then
		new_canvas()
	end
	love.graphics.setCanvas(canvas_)
	love.graphics.setColor(200, 000, 0, 255)
	love.graphics.circle("fill", 400, 300, 10)
end

function M.draw()
	love.graphics.setCanvas()
	print("--", position_[X], position_[Y])
	love.graphics.draw(canvas_, 0, 0, 0, 1, 1, position_[X], position_[Y])
	love.graphics.setColor(0, 200, 0, 255)
	love.graphics.circle("fill", 400, 400, 10)
	love.graphics.setCanvas(canvas_)
end

return M

