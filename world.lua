
-- generate_objects()

require 'constants'
viewport = require 'viewport'
object = require 'object'

local M = {}

local passages_ = {}
local max_passages_ = 3
local min_passage_height_ = 4
local p_passage_grow_base_ = 0.6
local p_passage_split_base_ = 0.3
local p_passage_shrink_ = 0.2
local p_passage_move_ = 0.2
local passage_split_height_ = 2 * min_passage_height_ + 1
local wall_tilesize_ = 32
local wall_tiles_y_ = math.floor(viewport.size()[Y] / wall_tilesize_)

local function update_passages()
	local passages_new = {}
	local top, bottom = 1, wall_tiles_y_ - 1
	
	local function keep(v) table.insert(passages_new, v) end
	
	local function split(v)
		local e1 = math.floor(v.s + (v.e - v.s - 1) / 2)
		table.insert(passages_new, { s = v.s, e = e1 })
		table.insert(passages_new, { s = e1 + 2, e = v.e })
	end
	
	local function shrink(v)
		if math.random() > 0.5 then
			table.insert(passages_new, { s = v.s, e = v.e - 1 })
		else
			table.insert(passages_new, { s = v.s + 1, e = v.e - 1 })
		end
	end
	
	local function move(v)
		if math.random() > 0.5 then
			if v.s > top then
				table.insert(passages_new, { s = v.s - 1, e = v.e - 1 })
			else
				keep(v)
			end
		else
			if v.e < bottom then
				table.insert(passages_new, { s = v.s + 1, e = v.e + 1 })
			else
				keep(v)
			end
		end
	end
	
	local function grow(v)
		if math.random() > 0.5 then
			if v.s > top then
				table.insert(passages_new, { s = v.s - 1, e = v.e })
			else
				keep(v)
			end
		else
			if v.e < bottom then
				table.insert(passages_new, { s = v.s, e = v.e + 1 })
			else
				keep(v)
			end
		end
	end
	
	-- sanitize current ("old") passages
	-- ensure there is at least 1 passage
	if #passages_ < 1 then
		local h = math.floor(min_passage_height_ * 1.8)
		local s = math.floor((wall_tiles_y_ - h) / 2)
		local e = s + h
		table.insert(passages_, { s = s, e = e })
	end
	
	local p_grow = p_passage_grow_base_ / #passages_
	local p_split = p_passage_split_base_ / #passages_
	local p_shrink = p_passage_shrink_ / (max_passages_ - #passages_ + 1)
	local p_move = p_passage_move_
	
	for _, v in ipairs(passages_) do
		if
			#passages_ < max_passages_
			and (v.e - v.s) >= passage_split_height_
			and math.random() < p_split
		then
			split(v)
		elseif
			(v.e - v.s) > min_passage_height_
			and math.random() < p_shrink
		then
			shrink(v)
		elseif math.random() < p_move then move(v)
		elseif math.random() < p_grow then grow(v)
		else keep(v) end
	end
	
	-- care for passage merges
	local passages_new2 = {}
	local prev = { e = -1 }
	for _, v in ipairs(passages_new) do
		if v.s <= prev.e then
			prev.e = v.e
		else
			table.insert(passages_new2, v)
		end
		
		prev = v
	end
	passages_ = passages_new2
end

local objects_to_draw_ = {}
--local physics_w_ = love.physics.newWorld(canvas_size[X], canvas_size[Y], true) 


local function generate_wall_row(x)
	update_passages()
	
	local function make_block(i)
		local o = object.create_block(
			{ wall_tilesize_, wall_tilesize_ },
			{ x, i * wall_tilesize_ }
		)
		table.insert(objects_to_draw_, o)
	end
	
	local i = 0
	for _, p in ipairs(passages_) do
		for j = i, p.s - 1 do make_block(j) end
		i = p.e + 1
	end
	for j = i, wall_tiles_y_ do make_block(j) end
end

function M.fill(l, r)
	local x = l
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

