Ship = Polygon:extend()

function Ship:new(xCenter, yCenter, red, green, blue)
  self.radius = 3
  self.rotLeft = "a" ; self.rotRight = "d" ; self.accelerate = "w"
  self.shoot = "space"
  
  local vertices = {  -4 ,  2 ,
                       0 ,  6 ,
                       4 ,  2 ,
                       4 , -6 ,
                       0 , -2 ,
                      -4 , -6 }
  Ship.super.new(self, xCenter, yCenter, vertices, red, green, blue)
end

local counter = 0
function propulDust(dt, waitTime, x, y)
  if counter <= waitTime then --Seconds between creation of dust.
    counter = counter + dt
  else 
    random = math.random(0, 100)
    table.insert(entities, SpaceDust(x + 4, y - 4,
                  127 + random, 16 + random, 16 + random
                  ))
    counter = 0
  end
end

function Ship:update(dt)
  --SHIP CONTROL:
  local acceleration = 10
  if love.keyboard.isDown(self.rotRight) then
    self.aSpeed = self.aSpeed + acceleration * dt
    propulDust(dt, 0.1, self.xCenter, self.yCenter)
  end
  if love.keyboard.isDown(self.rotLeft) then
    self.aSpeed = self.aSpeed - acceleration * dt
    print (self.rotRight .. " pressed." .. dt)
  end
  
  Ship.super.update(self, dt)
end