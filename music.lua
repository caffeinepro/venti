local M = {}

local pure = function(x) return math.sin(2*math.pi*x) end
local triangle = function (x) return -0.25+0.5*(x - math.floor(x)) end
local sawtooth = function (x) return math.abs(triangle(x))*2-1 end
local distortion = function (x) return math.atan(math.sin(2*math.pi*x)*2)/math.pi end
local clip = function (x) return 0.5*math.min(1, math.min(-1, 3*math.sin(2*math.pi*x))) end
local square = function (x) if (x - math.floor(x) > 0.5) then return 0.2 else return -0.2 end end
local decay = function (x) if (x < 0.5) then return math.min(0.5, x*10) else return math.min(5-5*x, 0.5*10^(0.5-x)) end end
local constant = function (x) return 1 end

local function arpeggio(instrument, chord)
	if instrument.arpeggio_state_ == nil then
		instrument.arpeggio_state_ = 1
	end
	
	r = instrument.arpeggio_state_
	
	instrument.arpeggio_state_ = instrument.arpeggio_state_ + 1
	if instrument.arpeggio_state_ > 3 then
		instrument.arpeggio_state_ = 1
	end
	return r
end

local function random_note(instrument, chord) return math.random(1, #chord) end

local bar_rate_ = 160.0 / (120.0 * 4.0)
local instruments_ = {
--	{ range = {-18, -6}, wave = triangle, envelope = constant, duration = 1/24, simul = 1, p_pause = 0.0, volume = 0.6, mode = arpeggio },
--	{ range = {0, 12}, wave = triangle, envelope = constant, duration = 1/16, simul = 2, p_pause = 0.05, volume = 0.5, mode = random_note },
--	{ range = {0, 24}, wave = square, envelope = decay, duration = 1/1, simul = 1, p_pause = 0.5, volume = 0.8, mode = random_note },
}

-- { instrument => { key => löve SoundData } }
local note_data_ = {}
local phrase_pos_ = 0

function M.load()
	io.write("Precomputing music samples...")
	io.flush()
	
	note_data_ = {}
	for i, instrument in ipairs(instruments_) do
		note_data_[i] = {}
		for k = -24, 24 do
			local data = M.generateNoteData(k, instrument.duration / bar_rate_, instrument.wave, instrument.envelope, instrument.volume) 
			note_data_[i][k] = love.audio.newSource(data)
		end
	end
	
	phrases = { 'GC', 'FGC', 'eGC', 'DFGC', 'DGC', 'FGFGC', 'DeFGC', 'eFGC' }
	--phrases = { 'CCCCFFCCGGFFCCGG' }
	--phrases = { 'C' }
	currentChord = {}
	phrase_ = 'CGC' --"111155551111"
	phrase_position_ = 0
	
	io.write("done.\n")
	io.flush()
end


-- given parameters, returns a SoundData object
function M.generateNoteData(noteidx, duration, wave, envelope, volume)	-- customize with closures that define waveform and envelope
	-- note idx is set up so that middle C (261.626 Hz according to Wikipedia) is 0
	-- each half-step is +1 or -1, so all the white keys are 0, 2, 4, 5, 7, 9, 11
	-- each octave is 12, so mod 12 corresponds to the note
	-- an equally tempered scale each note is 2^(1/12) higher than the previous
	-- or in other words the frequency is F*2^(k/12) where k is the note index 
	-- and F is the frequency at middle C
	local middlec = 261.626
	local freq = middlec * math.pow(2, noteidx/12)	-- frequency in Hz
	local samprate = 44100
	local nsamp = math.floor(samprate*duration)  -- number of samples
	local result = love.sound.newSoundData(nsamp, samprate, 16, 1)
	
	if not wave then
		wave = function (x) return math.sin(x*2*math.pi) end
	end
	
	if not envelope then
		envelope = function (x) return math.min(1, x*10, 10-x*10) end
	end
	
	for k=1,nsamp do
		local value = volume * envelope((k-1)/nsamp)*wave(k*freq/samprate)
		-- base = 0.8*math.sin(k*freq*2*math.pi/samprate) -- base tone
		result:setSample(k-1, value)
	end
	
	return result
end

local bar_end_ = 0
function M.update(dt)
	local now = love.timer.getMicroTime()
	
	if now > bar_end_ then
		phrase_position_ = phrase_position_ + 1
		if phrase_position_ > string.len(phrase_) then
			phrase_ = phrases[math.random(1, #phrases)]
			phrase_position_ = 1
		end
		--print(string.sub(phrase_, phrase_position_, phrase_position_))
		bar_end_ = now + 1.0 / bar_rate_
	end
	
	local chord_key = string.sub(phrase_, phrase_position_, phrase_position_)
	
	for i, instrument in ipairs(instruments_) do
		if instrument.note_end_ == nil then
			instrument.note_end_ = 0 -- now + instrument.duration / bar_rate_
		end
		
		if instrument.note_end_ <= now then
			if math.random() > instrument.p_pause then
				local chord = M.chordLookup(chord_key, instrument.range[1], instrument.range[2])
				local nnotes = math.random(1, instrument.simul)
				for k = 1, nnotes do
					local notepick = instrument:mode(chord)
					--math.random(1, #chord)
					local source = note_data_[i][chord[notepick]]
					
					if source:isStopped() then
						source:play()
					else
						source:rewind()
					end
				end -- k <- nnotes
			end -- if not pause
			
			instrument.note_end_ = now + instrument.duration / bar_rate_
		end -- if note end
	end -- instrument
end

-- Return all notes in a certain range that are octaves to any of the given
-- notes
function M.genChord(notes, s, e)
	local result = {}
	
	-- note: for performance reasons, use a count instead of
	-- table.insert, see:
	-- http://trac.caspring.org/wiki/LuaPerformance
	local c = 1
	for _, v in ipairs(notes) do
		for i = v - 12 * math.floor((v - s) / 12), e, 12 do
			result[c] = i
			c = c + 1
		end
	end
	
	return result
end

-- Return all notes matching the given key (i,ii,iii,iv,v)
function M.chordLookup(key, s, e)
	local C = 0
	local D = 2
	local E = 4
	local F = 5
	local G = 7
	local A = 9
	local B = 11
	
	if not key then return {} end
	return M.genChord(({
		C = {C, E, G},
		D = {D, F, A},
		e = {E, G, B},
		F = {F, A, C},
		G = {G, B, D}
	})[key], s, e)
end

return M

-- vim: set ts=4 sw=4 tw=78 noexpandtab :
