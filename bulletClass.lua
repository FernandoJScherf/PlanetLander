Bullet = Polygon:extend()

function Bullet:new(xCenter, yCenter, red, green, blue)
  self.radius = 2
  
  local vertices = {   0 ,  2 ,
                      -2 ,  0 ,
                       0 , -14,
                       2 ,  0 }
  Bullet.super.new(self, xCenter, yCenter, vertices, red, green, blue)
end