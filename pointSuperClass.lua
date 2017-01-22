Point = Object:extend()

--This is the constructor of our base class.
function Point:new(xCenter, yCenter)
  self.xCenter = xCenter 
  self.yCenter = yCenter 
  
  self.g = 0
  
  self.xSpeed = 0 -- pps pixel per second
  self.ySpeed = 0 -- pps pixel per second
  
  self.gravAffected = true
end

function Point:update(dt)
  --TRANSLATION CONSIDERING GRAVITY TOWARDS CENTER.
    local Xi = self.xCenter
    local Yi = self.yCenter
    local Px = centerScreenX
    local Py = centerScreenY
    --local M = 100000--100000      --Mass of the planet.
    
    --1)
    local g = 0
    if self.gravAffected then
      g = planetMass / ((Xi - Px) ^ 2 + (Yi - Py) ^ 2)
    end 
    
    --angle =  math.atan((Yi - Py) / (Xi - Px)) --modulo?
    local angle = math.atan2((Py - Yi), (Px - Xi))
    local gX = g * math.cos(angle)
    local gY = g * math.sin(angle)
    self.g = g
    --2)
    self.xSpeed = gX * dt + self.xSpeed
    self.ySpeed = gY * dt + self.ySpeed
    
    --3)
    self.xCenter = self.xSpeed * dt + self.xCenter
    self.yCenter = self.ySpeed * dt + self.yCenter
end