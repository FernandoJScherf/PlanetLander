local wasRed
local r, g, b, time, sin
local localScore
function allDead:enter(from, playerScore)
  r, g, b, time, sin = 0, 0, 0, 0, 0
  self.from = from -- record previous state
  wasRed = false
  localScore = playerScore
end


function allDead:update(dt)
  sin = math.sin(time * 2) / 2 + 0.5
  r = 255
  g = sin * 155 + 100
  b = g
  time = time + dt
end

function allDead:draw()
  local W, H = love.graphics.getWidth(), love.graphics.getHeight()
  -- draw previous screen
  self.from:draw()
  -- overlay with pause message
  love.graphics.printf({{r, g, b}, 'Every alien family on this planet is dead.\n You are fired.'},
    0, H/2 - 15, W, 'center')
  
  if not wasRed then
    local cos = math.cos(time) * 127 + 127
    love.graphics.setColor(255, 10, 10, cos)
    love.graphics.rectangle('fill', 0,0, screenWidth, screenHeight)
    love.graphics.setColor(255, 255, 255)
    if cos <= 1 then wasRed = true end
  end
end

function allDead:keypressed(key)
  planet = 1 --Reset Planet.
  --Free sources from memory:
  for k,v in pairs(sourceSFXR) do
    sourceSFXR[k] = nil
  end
  for i = 1, #entities do --Empty table:
    entities[i] = nil
  end
  extraShips = 0
  Gamestate.switch(score, localScore)
end