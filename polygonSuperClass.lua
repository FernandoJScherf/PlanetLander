Polygon = Object:extend()

--This is the constructor of our base class.
function Polygon:new(xCenter, yCenter, vertices)--Center of the Polygon.
  self.xCenter = xCenter
  self.yCenter = yCenter
  self.vertices = vertices
  self.xSpeed = 20 -- pps pixel per second
  self.ySpeed = 20 -- pps pixel per second
  self.aSpeed = 3.14 --The amount that the angle will change per second.
  --Is in Radians. 0.1 = aprox 5,72958 degrees.
  
end

function Polygon:update(dt)
  --Update new vertices:
    xSpeedTimesDT = self.xSpeed * dt
    ySpeedTimesDT = self.ySpeed * dt
    for i = 1, #self.vertices, 2 do
      --Rotation
        local aSpeedTimesDT = self.aSpeed * dt
        local xMinusOx = self.vertices[i]   - self.xCenter
        local yMinusOy = self.vertices[i+1] - self.yCenter 
      --x' = (x - Ox).cos(ang) - (y - Oy).sin(ang) + Ox
        self.vertices[i]  = xMinusOx*math.cos(aSpeedTimesDT) - 
                            yMinusOy*math.sin(aSpeedTimesDT) +
                            self.xCenter                            
      --y' = (x - Ox).sin(ang) - (y - Oy).cos(ang)
        self.vertices[i+1]= xMinusOx*math.sin(aSpeedTimesDT) + 
                            yMinusOy*math.cos(aSpeedTimesDT) +
                            self.yCenter 
      --Translation of the vertices
        self.vertices[i]    =   self.vertices[i]    +   xSpeedTimesDT
        self.vertices[i+1]  =   self.vertices[i+1]  +   ySpeedTimesDT
    end
    --Traslation of the Center of the Polygon
      self.xCenter = self.xCenter + xSpeedTimesDT
      self.yCenter = self.yCenter + ySpeedTimesDT
end

function Polygon:draw()
  love.graphics.polygon("line", self.vertices)
  love.graphics.print(self.xCenter, 100, 100)
  love.graphics.print(self.yCenter, 100, 120)
end