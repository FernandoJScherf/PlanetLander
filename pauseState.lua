--Based on the example of http://hump.readthedocs.io/en/latest/gamestate.html :
function pause:enter(from)
  self.from = from -- record previous state
end
local r, g, b, time, sin = 0, 0, 0, 0, 0
function pause:update(dt)
  sin = math.sin(time) 
  r = sin * 155 + 100
  g = r
  b = sin *  55 + 200
  time = time + dt * 3
end

function pause:draw()
  local W, H = love.graphics.getWidth(), love.graphics.getHeight()
  -- draw previous screen
  self.from:draw()
  -- overlay with pause message
  love.graphics.printf({{r, g, b}, 'PAUSE!'}, 0, H/2 - (7 + sin * 7), W, 'center')
end

function pause:keypressed(key)
  if key == "p" then
    Gamestate.pop() -- return to previous state
  end
end