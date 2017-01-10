SpaceRock = Polygon:extend()

function SpaceRock:new(xCenter, yCenter, red, green, blue, radius)
  local vertices = {}
  self.radius = radius
  
  local points = 3 + math.floor( self.radius / 2 )
  local radDiv2 = self.radius / 2
  local i = 1
  local pi = math.pi
  local angleIncr = pi / (points/2)
  -- initial angle, maximum angle, angle increment :
  for angle = 0, (pi * 2) - angleIncr, angleIncr do
    local x = self.radius + math.random(0,radDiv2) --total radius, including 
    vertices[i] = x * math.sin(angle)
    local y = self.radius + math.random(0,radDiv2) --a random addition.
    vertices[i+1] = y * math.cos(angle)
    i = i + 2
  end
  
  SpaceRock.super.new(self, xCenter, yCenter, vertices, red, green, blue)
end