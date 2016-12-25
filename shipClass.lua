Ship = Polygon:extend()

function Ship:new(xCenter, yCenter, red, green, blue)
  local vertices = {xCenter - 4 , yCenter + 2,
                    xCenter     , yCenter + 6,
                    xCenter + 4 , yCenter + 2,
                    xCenter + 4 , yCenter - 6,
                    xCenter     , yCenter - 2,
                    xCenter - 4 , yCenter - 6}
  Ship.super.new(self, xCenter, yCenter, vertices, red, green, blue)
end