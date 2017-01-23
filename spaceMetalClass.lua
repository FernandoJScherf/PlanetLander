SpaceMetal = SpaceRock:extend()

local metalColorTime = 0
local metalColorVar = 0

function SpaceMetal:new(xCenter, yCenter, radius)
  local red = math.random(35, 60)
  local blue = math.random(35, 60)
  local green = math.random(35, 60) + red + blue  
  SpaceMetal.super.new(self, xCenter, yCenter, red, green, blue, radius)
end

function SpaceMetal:update(dt) 
  --Change the color of the metal every frame:
  metalColorVar = math.sin(metalColorTime) * 5
  metalColorTime = metalColorTime + dt * 10
  self.red = self.red + metalColorVar
  self.green = self.green + metalColorVar
  self.blue = self.blue + metalColorVar
  
  SpaceMetal.super.update(self, dt)
end