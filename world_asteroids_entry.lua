
object = require 'object'
viewport = require 'viewport'

local M = {}

local entry_length_ = 0
local min_entry_length_ = 1.5 * viewport.size()[X]
local done_ = false

function M.fill(l, r)
	love.graphics.setCanvas(viewport.canvas())
	
	entry_length_ = entry_length_ + (r - l)
	if entry_length_ > min_entry_length_ then
		done_ = true
	end
	
	love.graphics.setCanvas()
	return r
end

function M.done() return done_ end

function M.reset()
	entry_length_ = 0
	done_ = false
end

return M

