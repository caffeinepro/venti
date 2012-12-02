local M = {}

function M.load()
  local pure = function(x) return math.sin(2*math.pi*x) end
  local triangle = function (x) return -0.25+0.5*(x - math.floor(x)) end
  local sawtooth = function (x) return math.abs(triangle(x))*2-1 end
  local distortion = function (x) return math.atan(math.sin(2*math.pi*x)*2)/math.pi end
  local clip = function (x) return 0.5*math.min(1, math.min(-1, 3*math.sin(2*math.pi*x))) end
  local square = function (x) if (x - math.floor(x) > 0.5) then return 0.2 else return -0.2 end end
  local decay = function (x) if (x < 0.5) then return math.min(0.5, x*10) else return math.min(5-5*x, 0.5*10^(0.5-x)) end end
  
  noteSources = {}
  for k=-24,24 do
    local data = M.generateNoteData(k, 0.3, pure, decay)
    noteSources[k] = love.audio.newSource(data)
  end
  
  simulNotes = 1
  
  phrases = { "55551111", "44551111", "33451111", "23451111", "22551111", "445544551111", "223344551111", "3344551111" }
  currentChord = {}
  currentPhrase = "111155551111"
  currentPhrasePos = -1
end


-- given parameters, returns a SoundData object
function M.generateNoteData(noteidx, duration, wave, envelope)  -- customize with closures that define waveform and envelope
  -- note idx is set up so that middle C (261.626 Hz according to Wikipedia) is 0
  -- each half-step is +1 or -1, so all the white keys are 0, 2, 4, 5, 7, 9, 11
  -- each octave is 12, so mod 12 corresponds to the note
  -- an equally tempered scale each note is 2^(1/12) higher than the previous
  -- or in other words the frequency is F*2^(k/12) where k is the note index 
  -- and F is the frequency at middle C
  local middlec = 261.626
  local freq = middlec * math.pow(2, noteidx/12)  -- frequency in Hz
  
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
    local value = envelope((k-1)/nsamp)*wave(k*freq/samprate)
    -- base = 0.8*math.sin(k*freq*2*math.pi/samprate) -- base tone
    result:setSample(k-1, value)
  end

  return result
end


function M.update(dt)
  local now = love.timer.getMicroTime()
  if not lastTime then
    lastTime = now
  end  
  
  local rate = 3          -- notes per second
  local interval = 1/rate -- interval (seconds) between notes
  local noteno = math.floor(now / interval)  -- note 'counter'
  local lastnoteno = math.floor(lastTime / interval) -- what was it last time
  
  if lastnoteno ~= noteno then  -- our note counter has advanced, time to play another note
    if string.len(currentPhrase) > 0 then 
      currentPhrasePos = currentPhrasePos + 1
      local ipos = 1+math.floor(currentPhrasePos/4)
      if ipos > string.len(currentPhrase) then
        local phraseno = math.random(1, #phrases)
        currentPhrase = phrases[phraseno]
        currentPhrasePos = 0
        ipos = 1
      end
      
      -- play the note at this position
      local note = string.sub(currentPhrase, ipos, ipos)
      currentChord = M.chordLookup(note)
    end
    
    if #currentChord > 0 then -- empty list indicates play nothing
      local nnotes = math.random(simulNotes, simulNotes)
      for k=1, nnotes do
        local notepick = math.random(1, #currentChord)  -- which of the available notes
        local noteidx = currentChord[notepick]          -- the keyboard number of the note we picked
        local thesource = noteSources[noteidx]
        if not thesource:isStopped() then
          thesource:rewind()
        else
          thesource:play()
        end
      end
    end
  end
  
  lastTime = now
end

function M.genChord(k1, k2, k3)
  local result = {}
  for j=-5,24 do
    local jm12 = (j+120) % 12  -- j mod 12
    if (jm12 == k1) or (jm12 == k2) or (jm12 == k3) then
      result[1+#result] = j
    end
  end
  return result
end

function M.chordLookup(key)
  local C = 0
  local D = 2
  local E = 4
  local F = 5
  local G = 7
  local A = 9
  local B = 11	
  
  local resultChord = {}
  if key == '1' then  
    resultChord = M.genChord(C, E, G)  -- aka I
  elseif key == '2' then
    resultChord = M.genChord(D, F, A)  -- aka ii
  elseif key == '3' then
    resultChord = M.genChord(E, G, B)  -- aka iii
  elseif key == '4' then
    resultChord = M.genChord(F, A, C)  -- aka IV
  elseif key == '5' then
    resultChord = M.genChord(G, B, D)  -- aka V
  end
  return resultChord
end

return M

