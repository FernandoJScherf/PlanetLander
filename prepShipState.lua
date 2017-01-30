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
  if time >= 3 then
    --Add cool SFX:
    insertAndPlaySE(sourceSFXR.NextShip, centerScreenX, centerScreenY)
    Gamestate.pop()
  end
  
  time = time + dt
end

function preparingShip:draw()
  -- draw previous screen
  self.from:draw()
  
  setDrawTarget()
  local cos = math.cos(time) * 127 + 127
  love.graphics.setColor(255, 255, 255, cos)
  love.graphics.rectangle('fill', 0,0, screenWidth, screenHeight)
  love.graphics.setColor(255, 255, 255)
  backToScreenAndUpscale()
end

function preparingShip:leave()
  table.insert(entities, Ship(centerScreenX, centerScreenY, self.circleR, self.circleG, self.circleB))
  local entShip = entities[#entities]
  entShip:rotate(1, math.pi)
  entShip:teleTransport(entShip.xCenter, entShip.yCenter - (circleRadius + 2 + entShip.radius))
end