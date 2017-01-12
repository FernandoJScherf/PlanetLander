Explotion = Point:extend()

function Explotion:new(xCenter, yCenter, red, green, blue, radiusMax)
  self.radius = 1
  self.radiusVar = 3
  self.radiusMax = radiusMax + radiusMax / 2--Maximum radius of the explosion.
  self.expansionVelocity = 50 --Velocity of radius expansion.
  self.red = red
  self.green = green
  self.blue = blue
  self.isExpanding = true
  
  --[[if radiusMax > self.radiusVar + radiusMax / 2 then
    local pi = math.pi
    local increments = pi / 4 --Max is 2*pi, these are 8 increments
    for amp = 1, radiusMax, 2 do
      for angle = 0, pi * 2, increments do
        local random = math.random()
        local x = math.cos(angle + random) * amp
        local y = math.sin(angle + random) * amp
        
        random = math.random(-20, 20)
        table.insert(entities, SpaceDust(x + xCenter, y + yCenter,
                      200 + random, 110 + random, 10 + random))
      end
    end
  end]]
  
  Explotion.super.new(self, xCenter, yCenter, red, green, blue)
end

function Explotion:update(dt)
  if self.isExpanding then
    self.radiusVar = self.radiusVar + math.sin( self.expansionVelocity * dt )
    if self.radiusVar > self.radiusMax then
      self.isExpanding = false
    end
  else
    self.radiusVar = self.radiusVar - (self.expansionVelocity/4) * dt
    if self.radiusVar <= 0 then
      self.isExpanding = true
    end
  end
  
  random = math.random(-20, 20)
  self.red = self.red + random
  self.green = self.green + random
  self.blue = self.blue + random
  
  Explotion.super.update(self, dt)
end

function Explotion:draw()
  love.graphics.setColor(self.red, self.green, self.blue)
  love.graphics.circle(fillOrLine, self.xCenter, self.yCenter, self.radiusVar)
  love.graphics.setColor(255,255,255)
end