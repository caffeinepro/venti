
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
local wall_tiles_x_ = math.floor(viewport.size()[X] / wall_tilesize_)
local passage_update_function_ = nil
local slime_factor_ = 1.0

local function passages_cave()
	slime_factor_ = 1.0
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

local passages_initial_nmax = math.floor(wall_tiles_x_ * 2.5)
local passages_initial_n = passages_initial_nmax
local function passages_initial()
	local top, bottom = 1, wall_tiles_y_ - 1
	passages_ = { { s = top, e = bottom } }
	slime_factor_ = 0.2 * (1.0 - passages_initial_n / passages_initial_nmax)
		
	passages_initial_n = passages_initial_n - 1
	if passages_initial_n == 0 then
		passage_update_function_ = passages_cave
	elseif passages_initial_n < 0 then
	end
end
	
--local physics_w_ = love.physics.newWorld(canvas_size[X], canvas_size[Y], true) 


local function generate_wall_row(x)
	--update_passages()
	passage_update_function_()
	
	love.graphics.setCanvas(viewport.canvas())
	local function make_block(i)
		local o = object.create_block(
			{ wall_tilesize_, wall_tilesize_ },
			{ x, i * wall_tilesize_ }
		)
		o:draw()
	end
	
	local function make_destructible(i)
		local o = object.create_slime(
			{ wall_tilesize_, wall_tilesize_ },
			{ x, i * wall_tilesize_ }
		)
		o:draw()
	end
	
	local i = 0
	for _, p in ipairs(passages_) do
		for j = i, p.s - 1 do make_block(j) end
		
		for j = p.s, p.e do
			local rely = j / wall_tiles_y_
			local prob = slime_factor_ * 2 * (rely - 0.5) * (rely - 0.5) -- probability is highest at top and bottom
			if math.random() < prob then
				make_destructible(j)
			end
		end
		
		i = p.e + 1
	end
	for j = i, wall_tiles_y_ do make_block(j) end
	love.graphics.setCanvas()
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
end

function M.update(dt)
end

passage_update_function_ = passages_initial

return M

