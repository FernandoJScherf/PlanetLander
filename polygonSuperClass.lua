Polygon = Object:extend()

--This is the constructor of our base class.
function Polygon:new(xCenter, yCenter, vertices, red, green, blue)
  self.xCenter = xCenter --Center of the Polygon.
  self.yCenter = yCenter --Center of the Polygon.
  
  --The vertices are coordinates relative to the center, so I have to 
  --add the center point to them:
  for i = 1, #vertices, 2 do
    vertices[i]   = vertices[i]   + xCenter
    vertices[i+1] = vertices[i+1] + yCenter
  end
  
  self.vertices = vertices
  self.xSpeed = math.random(-30, 30) -- pps pixel per second
  self.ySpeed = 0 -- pps pixel per second
  self.aSpeed = math.random(-3, 3) --math.pi() --The amount that the angle will change per second.
  self.rotation = 0
  --Is in Radians. 0.1 = aprox 5,72958 degrees.
  
  self.red = red
  self.green = green
  self.blue = blue
end

function Polygon:update(dt)
  --Update new vertices:\
  --TRANSLATION (of the Center of the polygon)
    local Xi = self.xCenter
    local Yi = self.yCenter
    local Px = centerScreenX
    local Py = centerScreenY
    local M = 100000--100000      --Mass of the planet.
    
    --1)
    local g = M / ((Xi - Px) ^ 2 + (Yi - Py) ^ 2)
    
    --angle =  math.atan((Yi - Py) / (Xi - Px)) --modulo?
    local angle = math.atan2((Py - Yi), (Px - Xi))
    local gX = g * math.cos(angle)
    local gY = g * math.sin(angle)
    --2)
    self.xSpeed = gX * dt + self.xSpeed
    self.ySpeed = gY * dt + self.ySpeed
    
    --3)
    self.xCenter = self.xSpeed * dt + self.xCenter
    self.yCenter = self.ySpeed * dt + self.yCenter
    
    local aSpeedTimesDT = self.aSpeed * dt
    for i = 1, #self.vertices, 2 do
      --Translation of vertices
      self.vertices[i] = self.xSpeed * dt + self.vertices[i]
      self.vertices[i+1] = self.ySpeed * dt + self.vertices[i+1]
      
      --ROTATION
        local xMinusOx = self.vertices[i] - self.xCenter
        local yMinusOy = self.vertices[i+1] - self.yCenter 
      --x'= (x - Ox).cos(ang) - (y - Oy).sin(ang) + Ox
        self.vertices[i] = xMinusOx * math.cos(aSpeedTimesDT) - 
                       yMinusOy*math.sin(aSpeedTimesDT) +
                       self.xCenter                            
      --y'= (x - Ox).sin(ang) - (y - Oy).cos(ang)
        self.vertices[i+1] = xMinusOx * math.sin(aSpeedTimesDT) + 
                       yMinusOy*math.cos(aSpeedTimesDT) +
                       self.yCenter 
        
        --self.vertices[i]    =   x  +   xSpeedTimesDT
        --self.vertices[i+1]  =   y  +   ySpeedTimesDT
    end
    --Save new angle of total rotation:
    self.rotation = self.rotation + aSpeedTimesDT
    local pi2 = math.pi * 2
    if self.rotation >= pi2 then
      self.rotation = self.rotation - pi2
    elseif self.rotation <= -pi2 then
      self.rotation = self.rotation + pi2
    end
    --Traslation of the Center of the Polygon
      --self.xCenter = self.xCenter + xSpeedTimesDT
      --self.yCenter = self.yCenter + ySpeedTimesDT
end

function Polygon:draw()
  love.graphics.setColor(self.red, self.green, self.blue)
  love.graphics.polygon(fillOrLine, self.vertices)
  love.graphics.points(self.xCenter, self.yCenter)
  love.graphics.setColor(255, 255, 255)
  --love.graphics.print(string.format("%.2f", self.rotation), self.xCenter, self.yCenter)
  --[[love.graphics.print("gX" .. gX, 10, 140)
  love.graphics.print("self.xSpeed" .. self.xSpeed, 10, 150)
  love.graphics.print("gY" .. gX, 10, 180)
  love.graphics.print("self.ySpeed" .. self.ySpeed, 10, 190)
  love.graphics.print("angle: " .. angle, 10, 210)]]--
end