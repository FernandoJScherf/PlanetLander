Ship = Polygon:extend()

function Ship:new(xCenter, yCenter, red, green, blue)
  self.radius = 2 --Some margin for the player
  self.rotLeft = "a" ; self.rotRight = "d" ; self.accelerate = "w"
  self.shoot = "space"
  self.shipSpeed = 0
  self.speedMaxLanding = 50
  
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
    local random = math.random(0, 100)
    table.insert(entities, SpaceDust(x, y,
                  127 + random, 16 + random, 16 + random))
    
    --Give velocity to dust:
    local v  = 40 --pixels per second.
    local ent = entities[#entities]
    ent.xSpeed = v*math.cos(angle) + xSpeedObject
    ent.ySpeed = v*math.sin(angle) + ySpeedObject
  --end
end

local timeToShoot = 0
function Ship:update(dt)

  Ship.super.update(self, dt)
  
  --Calculate Ship's Speed in pixels per second.
  self.shipSpeed = math.sqrt((self.xSpeed ^ 2) + (self.ySpeed ^ 2))
  
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
  if love.keyboard.isDown(self.shoot) and timeToShoot >= 0.5 then
    local random = math.random(0, 50)
    table.insert(entities, Bullet(
        self.vertices[3],
        self.vertices[4],
        200 + random, 
        20 + random, 
        70 + random))
    
    timeToShoot = 0
    
    local angle = self.rotation
    local ent = entities[#entities]
    -- Rotate vertices depending on ship angle when it shoots.
    for i = 1, #ent.vertices, 2 do
      local xMinusOx = ent.vertices[i] - ent.xCenter
      local yMinusOy = ent.vertices[i+1] - ent.yCenter 
      --x'= (x - Ox).cos(ang) - (y - Oy).sin(ang) + Ox
      ent.vertices[i] = xMinusOx * math.cos(angle) - 
                     yMinusOy*math.sin(angle) + ent.xCenter
      ent.vertices[i+1] = xMinusOx * math.sin(angle) + 
                       yMinusOy*math.cos(angle) + ent.yCenter 
    end

    --Give velocity to bullet:
    local v  = 200 --pixels per second.
    angle = angle + math.pi/2
    ent.xSpeed = v*math.cos(angle) + self.xSpeed
    ent.ySpeed = v*math.sin(angle) + self.ySpeed
    ent.aSpeed = 0
    
  else
    timeToShoot = timeToShoot + dt
  end
end