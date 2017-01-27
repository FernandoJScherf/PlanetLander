--After ship is destroyed, if you have extra ships, this state happens.
local time
function preparingShip:enter(from, circleColor)
  self.from = from -- record previous state
  self.circleR = circleColor[1]
  self.circleG = circleColor[2]
  self.circleB = circleColor[3]
  time = 0
end

function preparingShip:update(dt)
  --Time will "go slower":
  self.from:update(dt / 5)
  time = time + dt
  
  if time >= 3 then
    Gamestate.pop()
  end
end

function preparingShip:draw()
  -- draw previous screen
  self.from:draw()
end

function preparingShip:leave()
  table.insert(entities, Ship(centerScreenX, centerScreenY, self.circleR, self.circleG, self.circleB))
  local entShip = entities[#entities]
  entShip:rotate(1, math.pi)
  entShip:teleTransport(entShip.xCenter, entShip.yCenter - circleRadius - 2 - entities[1].radius)
end