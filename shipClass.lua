Ship = Polygon:extend()

function Ship:new(xCenter, yCenter, red, green, blue)
  self.radius = 3 --Some margin for the player
  self.rotLeft = "a" ; self.rotRight = "d" ; self.accelerate = "w"
  self.shoot = "space"
  self.shipSpeed = 0
  self.speedMaxLanding = 150
  self.state = 1 --1) Flying. 2) Landed.
  self.angleC = 0
  self.rotation = 0
  self.collidable = true
  
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

function Ship:teleTransport(x, y)
  xDistanceToNewPos = x - self.xCenter
  yDistanceToNewPos = y - self.yCenter
  self.xCenter = x
  self.yCenter = y
  
  for i = 1, #self.vertices, 2 do
    self.vertices[i] = self.vertices[i] + xDistanceToNewPos
    self.vertices[i+1] = self.vertices[i+1] + yDistanceToNewPos
  end
end

function Ship:accel(accel, dt)
  local angle = self.rotation
  local xSpeedAdded = accel * math.cos(angle) * dt
  local ySpeedAdded = accel * math.sin(angle) * dt
  local angleDis = angle + math.pi

  propulDust(dt, waitTime, self.vertices[7], self.vertices[8], 
    angleDis, self.xSpeed, self.ySpeed)
  propulDust(dt, waitTime, self.vertices[11], self.vertices[12], 
    angleDis, self.xSpeed, self.ySpeed)

  self.xSpeed = self.xSpeed + xSpeedAdded
  self.ySpeed = self.ySpeed + ySpeedAdded
end

local timeToShoot = 0
function Ship:update(dt)
  
  local pi = math.pi
  local piDiv2 = pi / 2

  --Calculate Ship's Speed in pixels per second.
  self.shipSpeed = math.sqrt((self.xSpeed ^ 2) + (self.ySpeed ^ 2))
  
  --Calculate Ship's Rotation.
    --For SHIP, this is the Angle of line from FRONT vertice to ShipCenter:
    local x = self.vertices[3] - self.xCenter
    local y = self.vertices[4] - self.yCenter
    self.rotation = math.atan2(y, x)
  
  --SHIP CONTROL:
  local acceleration = 10
  local waitTime = 0.07
  if love.keyboard.isDown(self.rotRight) and self.state == 1 then --Only when flying.
    self.aSpeed = self.aSpeed + acceleration * dt
    propulDust(dt, waitTime, self.vertices[11], self.vertices[12], 
      self.rotation + piDiv2, self.xSpeed, self.ySpeed)
    --Dust will be out of one of the vertices of the ship. (That is rotating)
  end
  if love.keyboard.isDown(self.rotLeft) and self.state == 1 then --Only when flying.
    self.aSpeed = self.aSpeed - acceleration * dt
    propulDust(dt, waitTime, self.vertices[7], self.vertices[8], 
      self.rotation - piDiv2, self.xSpeed, self.ySpeed)
    --Dust will be out of one of the vertices of the ship. (That is rotating)
  end
  if love.keyboard.isDown(self.accelerate) and self.state == 1 then
     
    self:accel(150, dt) --Should always be bigger than pull of g on planet's surface.
  end
  if love.keyboard.isDown(self.shoot) and timeToShoot >= 0.5 then
    if self.state == 1 then
      self:accel(-3, dt)  -- Every shot makes the ship go slower.
    end
    
    local random = math.random(0, 50)
    table.insert(entities, Bullet(
        self.vertices[3],
        self.vertices[4],
        200 + random, 
        20 + random, 
        70 + random))
    
    timeToShoot = 0
    
    local angle = self.rotation - piDiv2
    local ent = entities[#entities]
    ent:rotate(1, angle) --Rotate vertices of BULLET depending on ship angle when it shoots.

    --Give velocity to bullet:
    local v  = 200 --pixels per second.
    angle = angle + piDiv2
    ent.xSpeed = v*math.cos(angle) + self.xSpeed
    ent.ySpeed = v*math.sin(angle) + self.ySpeed
    ent.aSpeed = 0
    
  else
    timeToShoot = timeToShoot + dt
  end
  
  local accelerate = false
  if self.state == 1 then --ONLY IF FLYING.
    Ship.super.update(self, dt)
    
    if not self.collidable and (not checkColl(self.xCenter, self.yCenter, self.radius,
      centerScreenX, centerScreenY, circleRadius) or 
      not love.keyboard.isDown(self.accelerate)) then
        self.collidable = true
    end
    
  elseif self.state == 2 then --IF IN LANDING STATE.
    
    --Angle of line from PlanetCenter to ShipCenter:
    y = self.yCenter - centerScreenY
    x = self.xCenter - centerScreenX
    self.angleC = math.atan2(y, x)
    local radius = self.radius + 3
    local totalRadius = circleRadius + radius
    local surfacePointPlanetX = totalRadius * math.cos(self.angleC) + centerScreenX
    local surfacePointPlanetY = totalRadius * math.sin(self.angleC) + centerScreenY
    
    self:teleTransport(surfacePointPlanetX, surfacePointPlanetY)

    self.aSpeed = 0
    self.xSpeed = 0
    self.ySpeed = 0
    
    self.state = 3 --TO ROTATING GAMESTATE.
    
  elseif self.state == 3 then--IF IN ROTATING STATE.
    local angleSSubC = self.rotation - self.angleC
    local maxDif = pi / 32
    --If there is too much difference betweeen angles.
    if math.abs(angleSSubC) > maxDif then  
      --Determine if ship should rotate clockwise or anti-clockwise:s
      if y >= 0 then
        if angleSSubC < 0 and math.abs(angleSSubC) < pi then
          self:rotate(dt, 3) --Clockwise
        else
          self:rotate(dt, -3) --Anti-Clockwise
        end
      else
        if angleSSubC > 0 and math.abs(angleSSubC) < pi then
          self:rotate(dt, -3) --Anti-Clockwise
        else
          self:rotate(dt, 3) --Clockwise
        end
      end
    else --If the ship is already in the correct angle.
      self.state = 4 --TO TAKINGOFF STATE.
    end
    
  elseif self.state == 4 then --IF IN TAKINGOFF STATE.
    if love.keyboard.isDown(self.accelerate) then   
      self.state = 1
      self.collidable = false
    end
  end
end