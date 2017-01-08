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


function propulDust(dt, waitTime, x, y, angle, xSpeedObject, ySpeedObject)
  --if counter <= waitTime then --Seconds between creation of dust.

  --else 
    random = math.random(0, 100)
    table.insert(entities, SpaceDust(x, y,
                  127 + random, 16 + random, 16 + random))
    
    --Give velocity to dust:
    local v  = 40 --pixels per second.
    local ent = entities[#entities]
    ent.xSpeed = v*math.cos(angle) + xSpeedObject
    ent.ySpeed = v*math.sin(angle) + ySpeedObject
  --end
end

function Ship:update(dt)

  Ship.super.update(self, dt)
  
  --SHIP CONTROL:
  local pi = math.pi
  local pi2 = pi*2
  local acceleration = 10
  local waitTime = 0.07
  if love.keyboard.isDown(self.rotRight) then
    self.aSpeed = self.aSpeed + acceleration * dt
    propulDust(dt, waitTime, self.vertices[11], self.vertices[12], 
      self.rotation + pi, self.xSpeed, self.ySpeed)
    --Dust will be out of one of the vertices of the ship. (That is rotating)
  end
  if love.keyboard.isDown(self.rotLeft) then
    self.aSpeed = self.aSpeed - acceleration * dt
    propulDust(dt, waitTime, self.vertices[7], self.vertices[8], 
      self.rotation + pi2, self.xSpeed, self.ySpeed)
    --Dust will be out of one of the vertices of the ship. (That is rotating)
  end
  if love.keyboard.isDown(self.accelerate) then
     
    local speedAddedPerSecond = 3 --pixels per second
    local angle = self.rotation + pi/2
    local xSpeedAdded = speedAddedPerSecond * math.cos(angle)
    local ySpeedAdded = speedAddedPerSecond * math.sin(angle)
    local angleDis = angle + pi
    
    propulDust(dt, waitTime, self.vertices[7], self.vertices[8], 
      angleDis, self.xSpeed, self.ySpeed)
    propulDust(dt, waitTime, self.vertices[11], self.vertices[12], 
      angleDis, self.xSpeed, self.ySpeed)
    
    self.xSpeed = self.xSpeed + xSpeedAdded
    self.ySpeed = self.ySpeed + ySpeedAdded
  end
end