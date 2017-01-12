SpaceDust = Polygon:extend()

function SpaceDust:new(xCenter, yCenter, red, green, blue)
  self.radius = 2
  
  local vertices = --[[{  -1 - math.random(0, 1),  0 ,
                       1 + math.random(0, 1),  0 ,
                       0 ,  1 + math.random(0, 1),
                       0 , -1 - math.random(0, 1)}--]]
  {  -1 ,  0 ,  1 ,  0 ,  0 ,  1 ,  0 , -1 }
  SpaceDust.super.new(self, xCenter, yCenter, vertices, red, green, blue)
end