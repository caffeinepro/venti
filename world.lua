
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
local wall_passage_move_ = .3

local objects_to_draw_ = {}

for k,v in ipairs(viewport.size()) do print(k,v) end

local all_objects_ = {}

local function generate_wall_row(x)
	local row = {}
	
	local i = math.floor(x / wall_tilesize_) % wall_tiles_y_
	
	-- move passage?
	if math.random() < wall_passage_move_ then
		local inc = math.random() > .5
		if (not inc) and wall_passage_start_ > 0 then
			wall_passage_start_ = wall_passage_start_ - 1
			wall_passage_end_ = wall_passage_end_ - 1
		elseif (wall_passage_end_) < wall_tiles_y_ - 1 then
			wall_passage_start_ = wall_passage_start_ + 1
			wall_passage_end_ = wall_passage_end_ + 1
		end
	end
	
	
	for i = 0, wall_tiles_y_-1 do
		if i < wall_passage_start_ or i > wall_passage_end_ then
			if math.random() < wall_tile_density_ then
				row[i] = object.create_block(
					{wall_tilesize_, wall_tilesize_},
					{x, i * wall_tilesize_}
				)
				--table.insert(all_objects_, row[i])
				table.insert(objects_to_draw_, row[i])
			end
		end
	end
	
	if row[0] == nil then
		row[0] = object.create_block(
			{wall_tilesize_, wall_tilesize_},
			{x, 0 * wall_tilesize_}
		)
		table.insert(objects_to_draw_, row[0])
	end
	if row[wall_tiles_y_ - 1] == nil then
		row[wall_tiles_y_ - 1] = object.create_block(
			{wall_tilesize_, wall_tilesize_},
			{x, (wall_tiles_y_ - 1) * wall_tilesize_}
		)
		table.insert(objects_to_draw_, row[wall_tiles_y_ - 1])
	end
end

function M.fill(l, r)
	local x = l
	local delta = 0
	while x < r do
		generate_wall_row(x)
		x = x + wall_tilesize_
	end
	return x
end

function M.draw()
	love.graphics.setCanvas(viewport.canvas())
	for _, v in ipairs(objects_to_draw_) do
		v:draw()
	end
	objects_to_draw_ = {}
end

function M.update(dt)
end

return M

