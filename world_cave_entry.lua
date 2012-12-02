
object = require 'object'
viewport = require 'viewport'

local M = {}

local wall_tilesize_ = 32
local wall_tiles_y_ = math.floor(viewport.size()[Y] / wall_tilesize_)
local entry_length_ = 0
local min_entry_length_ = 1.5 * viewport.size()[X]
local done_ = false

function M.fill(l, r)
	love.graphics.setCanvas(viewport.canvas())
	
	local x = l
	while x < r do
		object.create_block(
			{ wall_tilesize_, wall_tilesize_ },
			{ x, 0 }
		):draw()
		
		object.create_block(
			{ wall_tilesize_, wall_tilesize_ },
			{ x, wall_tiles_y_ * wall_tilesize_ }
		):draw()
		
		x = x + wall_tilesize_
		entry_length_ = entry_length_ + wall_tilesize_
		if entry_length_ > min_entry_length_ then
			done_ = true
		end
	end
	
	love.graphics.setCanvas()
	return x
end

function M.done() return done_ end

function M.reset()
	entry_length_ = 0
	done_ = false
end

return M

