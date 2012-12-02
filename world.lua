
-- generate_objects()

require 'constants'

local M = {}


local segment_sets_ = {
	{ require 'world_cave_entry', require 'world_cave' },
	{ require 'world_asteroids_entry', require 'world_asteroids' },
}
local segment_index_ = 1
local segment_set_ = nil

function M.load()
	segment_set_ = segment_sets_[1]
	segment_index_ = 1
	segment_set_[segment_index_].reset()
end

function M.draw()
end

function M.update(dt)
end

function M.fill(l, r)
	local segment = segment_set_[segment_index_]
	local r = segment.fill(l, r)
	if segment.done() then
		segment_index_ = segment_index_ + 1
		if segment_index_ > #segment_set_ then
			segment_set_ = segment_sets_[math.random(1, #segment_sets_)]
			segment_index_ = 1
		end
		segment_set_[segment_index_].reset()
	end
	return r
end


return M

