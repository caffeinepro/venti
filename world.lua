
-- generate_objects()

require 'constants'
viewport = require 'viewport'
object = require 'object'

local M = {}

local wall_tilesize_ = 50
local wall_tiles_y_ = math.floor(viewport.size()[Y] / wall_tilesize_)
local wall_tile_density_ = .5
local wall_min_passage_size_ = 3
local wall_passage_start_ = math.floor(wall_tiles_y_ / 2)
local wall_passage_end_ = wall_passage_start_ + wall_min_passage_size_
local wall_x_ = 0

local objects_to_draw_ = {}

for k,v in ipairs(viewport.size()) do print(k,v) end

local wall_x_threshold_ = viewport.size()[X] * 1.5

local all_objects_ = {}

local function generate_wall_row(x)
	local row = {}
	for i = 1, wall_tiles_y_ do
		if i < wall_passage_start_ or i > wall_passage_end_ then
			if math.random() < wall_tile_density_ then
				row[i] = object.create_block(
					{wall_tilesize_, wall_tilesize_},
					{x, (i - 1) * wall_tilesize_}
				)
				--table.insert(all_objects_, row[i])
				row[i]:draw()
				table.insert(objects_to_draw_, row[i])
			end
		end
	end
	
	if row[1] == nil then
		row[1] = object.create_block(
			{wall_tilesize_, wall_tilesize_},
			{x, 1 * wall_tilesize_}
		)
		table.insert(objects_to_draw_, row[1])
	end
	if row[wall_tiles_y_] == nil then
		row[wall_tiles_y_] = object.create_block(
			{wall_tilesize_, wall_tilesize_},
			{x, wall_tiles_y_ * wall_tilesize_}
		)
		table.insert(objects_to_draw_, row[wall_tiles_y_])
	end
end

local function generate_wall_rows()
	while
		wall_x_ < viewport.viewport_to_canvas({wall_x_threshold_, 0})[X]
		and wall_x_ < viewport.canvas_size()[X]
	do
		generate_wall_row(wall_x_)
		wall_x_ = wall_x_ + wall_tilesize_
	end
end

function M.draw()
	for _, v in ipairs(objects_to_draw_) do
		v:draw()
	end
end

function M.update(dt)
	-- TODO: shift all objects to the left (distance depending on dt)
	-- TODO: if necessary, generate new objects
	generate_wall_rows()
end

return M

