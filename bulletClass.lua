Bullet = Polygon:extend()

function Bullet:new(xCenter, yCenter, red, green, blue)
  self.radius = 1
  
  local vertices = {   0 ,  1 ,
                      -2 ,  0 ,
                       0 , -14,
                       1 ,  0 }
  Bullet.super.new(self, xCenter, yCenter, vertices, red, green, blue)
end