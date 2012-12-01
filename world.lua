
-- generate_objects()

require 'constants'
viewport = require 'viewport'
object = require 'object'

local M = {}

local wall_tilesize_ = 20
local wall_tiles_y_ = math.floor(viewport.size()[Y] / wall_tilesize_)
local wall_tile_density_ = .5
local wall_min_passage_size_ = 3
local wall_passage_start_ = math.floor(wall_tiles_y_ / 2)
local wall_passage_end_ = wall_passage_start_ + wall_min_passage_size_
local wall_x_ = 0

local objects_to_draw_ = {}

for k,v in ipairs(viewport.size()) do print(k,v) end

local all_objects_ = {}

local function generate_wall_row(x)
	print("row", x)
	local row = {}
	
	local i = math.floor(x / wall_tilesize_) % wall_tiles_y_
	
				row[i] = object.create_block(
					{wall_tilesize_, wall_tilesize_},
					{x, i * wall_tilesize_}
				)
				--table.insert(all_objects_, row[i])
				table.insert(objects_to_draw_, row[i])
	for i = 1, wall_tiles_y_ do
--[[	
		if i < wall_passage_start_ or i > wall_passage_end_ then
			if math.random() < wall_tile_density_ then
				row[i] = object.create_block(
					{wall_tilesize_, wall_tilesize_},
					{x, (i - 1) * wall_tilesize_}
				)
				--table.insert(all_objects_, row[i])
				table.insert(objects_to_draw_, row[i])
			end
		end
		]]--
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

function M.fill(l, r)
	print("fill", l, r)
	local x = l
	local delta = 0
	while x < r do
		generate_wall_row(x)
		x = x + wall_tilesize_
	end
	return x
end

function M.canvas_reset()
	wall_x_ = viewport.size()[X]
end

function M.draw()
	love.graphics.setCanvas(viewport.canvas())
	for _, v in ipairs(objects_to_draw_) do
		--print(_)
		v:draw()
	end
	objects_to_draw_ = {}
end

function M.update(dt)
	--generate_wall_rows()
end

return M

