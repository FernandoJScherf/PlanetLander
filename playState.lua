--PLAY GAMESTATE CALLBACKS:

local ship ; local spaceDust = {} ; local spaceRock = {}

local extSpace = 40--screenWidth/4

local nSpaceRocks
entities = {}

function play:init()
  entities[1] = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  --entities[1].xSpeed = 25
  entities[1].aSpeed = 0
  --ship = entities[1]
  --[[entities[2] = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  entities[2].xSpeed = 25
  entities[2].aSpeed = 0
  entities[2].freeze = true]]
  
  local nSpaceDusts = math.floor( screenWidth / 4 )
  local limit = nSpaceDusts + #entities
  for i = 1 + #entities, limit  do
    local color = math.random(80, 240)
    entities[i] = SpaceDust(math.random(-extSpace, screenWidth + extSpace),
                  math.random(-extSpace, screenHeight + extSpace), color - 50,
                  color - 50, color + 10)
    
    entities[i].xSpeed = math.random( -25, 25) 
    entities[i].ySpeed = math.random( -25, 25) 
  end
  
  nSpaceRocks = 2
  limit = nSpaceRocks + #entities
  for i = 1 + #entities, limit  do
    local color = math.random(30, 220)
    local x ; local y
    
    entities[i] = SpaceRock(math.random(-extSpace, screenWidth + extSpace),
                  math.random(-extSpace, screenWidth + extSpace),
                  color + 30, color, color, 10)
                
    entities[i].xSpeed = math.random( -6, 6) 
    entities[i].ySpeed = math.random( -6, 6) 
  end
  
end

function checkColl(x1, y1, r1, x2, y2, r2)
  local entity = entities[i]
  local dX = math.abs(x2 - x1)
  local dY = math.abs(y2 - y1)
  local dRadius = (r1 + r2)
  if dRadius >= dX and dRadius >= dY then
    return true
  else
    return false
  end 
end

function elastic(ent1, ent2)
  local xV1 = ent1.xSpeed; local yV1 = ent1.ySpeed
  local xV2 = ent2.xSpeed; local yV2 = ent2.ySpeed
  local m1 = ent1.radius ; local m2 = ent2.radius
  local m1Pm2 = m1 + m2
  
  local xV1New = (xV1 * (m1 - m2) + 2 * m2 * xV2) / m1Pm2 --The elastic
  local xV2New = (xV2 * (m2 - m1) + 2 * m1 * xV1) / m1Pm2 --formulas 
  local yV1New = (yV1 * (m1 - m2) + 2 * m2 * yV2) / m1Pm2 --separated in 
  local yV2New = (yV2 * (m2 - m1) + 2 * m1 * yV1) / m1Pm2 --components x,y.
  
  return  xV1New, yV1New, xV2New, yV2New
end

function insertFullExplotion(xCenter, yCenter, radiusMax, xSpeed, ySpeed)
  table.insert(entities, 
    Explotion(xCenter, 
              yCenter,
              220, 110, 10,
              radiusMax))
          
    entities[#entities].xSpeed = xSpeed
    entities[#entities].ySpeed = ySpeed
  
  --INSERT COOL SPACE DUST:
  if radiusMax > 4 then --Only when the object colliding is big enough.
    local pi = math.pi
    local increments = pi / 4 --Max is 2*pi, these are 8 increments
    for amp = 1, radiusMax * 2
    , 2 do
      for angle = 0, pi * 2, increments do
        local random = math.random()
        local x = math.cos(angle + random) * amp
        local y = math.sin(angle + random) * amp
        
        random = math.random(-20, 20)
        table.insert(entities, SpaceDust(x + xCenter, y + yCenter,
                      200 + random, 110 + random, 10 + random))
                  
        entities[#entities].xSpeed = xSpeed + x
        entities[#entities].ySpeed = ySpeed + y
      end
    end
  end
end

local shipCollidedPlanet
function play:update(dt)
  local i = 1 
  shipCollidedPlanet = false
  --CHECK FOR COLLISIONS!!!
  while i <= #entities do
    --ENTITIES AGAINST PLANET: 
    --Don't check collision for: explotions.
    if checkColl(entities[i].xCenter, entities[i].yCenter, entities[i].radius,
      centerScreenX, centerScreenY, circleRadius) then
      
      --Special Conditions for the ship's collision
      if entities[i]:is(Ship) then
        if entities[i].collidable then
          --If the ship meets certain conditions, it lands
          --Otherwise, it is DESTROYED.
          
          if entities[i].shipSpeed > entities[i].speedMaxLanding then
            --REMOVE POINTS HERE.
            insertFullExplotion(
                    entities[i].xCenter, 
                    entities[i].yCenter,
                    entities[i].radius + 5, --Bigger radius to make it cooler.
                    0, 
                    0)     
            table.remove(entities, i)
            i = i - 1
          else --If ship is colliding, "softly".
            shipCollidedPlanet = true
            --entities[i].freeze = true
            if entities[i].state == 1 then
              entities[i].state = 2
            end
          end
        end
      elseif entities[i]:is(Bullet) then
      --REMOVE POINTS HERE.
        insertFullExplotion(
                entities[i].xCenter, 
                entities[i].yCenter,
                entities[i].radius + 5, --Bigger radius to make it cooler.
                0, 
                0)     
        table.remove(entities, i)
        i = i - 1
        
      --If the entity colliding is not of the type explotion
      --Create an explotion!
    elseif not entities[i]:is(Explotion) then
      --REMOVES POINTS HERE IF ITS AN SPACE ROCK.
        insertFullExplotion(
                entities[i].xCenter, 
                entities[i].yCenter,
                entities[i].radius,
                0, 
                0)
        table.remove(entities, i)
        i = i - 1
        
      elseif entities[i]:is(Explotion) then
        table.remove(entities, i)
        i = i - 1
      end      
      
    else
    --ENTITIES VS ENTITIES:
      for j = i + 1, #entities do
        
        if  checkColl(entities[i].xCenter, entities[i].yCenter,
            entities[i].radius, entities[j].xCenter, entities[j].yCenter,
            entities[j].radius) then
            
          --So SpaceRock type is always in entities[i] if there is in fact 
          --an SpaceRock in the comparison:
          if entities[j]:is(SpaceRock) and 
              entities[i]:is(SpaceRock) == false then
            local entSave = entities[i]
            entities[i] = entities[j]
            entities[j] = entSave
          end
          if entities[i]:is(SpaceRock) then --If there is an Space Rock.
            if entities[j]:is(SpaceRock) then--Against another spaceRock.
                                            
              local xSpeedI ; local ySpeedI
              local xSpeedJ ; local ySpeedJ
              --ELASTIC COLLISION MAN!!!!
              xSpeedI, ySpeedI, xSpeedJ, ySpeedJ = 
              elastic(entities[i], entities[j])
              
              entities[i].xSpeed = xSpeedI
              entities[i].ySpeed = ySpeedI
              entities[j].xSpeed = xSpeedJ
              entities[j].ySpeed = ySpeedJ
              
            elseif entities[j]:is(SpaceDust) then--Against SpaceDust.
              table.remove(entities, j)
              i = i - 1
            elseif entities[j]:is(Ship) then --Against Ship.
            --Explotion!
              insertFullExplotion(
                entities[j].xCenter, 
                entities[j].yCenter,
                entities[j].radius + 5,
                entities[i].xSpeed, --In this case, the collision is completely
                entities[i].ySpeed) --Inelastic :D
              
              table.remove(entities, j)
              i = i - 1
            elseif entities[j]:is(Bullet) then --Against Bullet.
              local xSpeedI ; local ySpeedI
              local xSpeedJ ; local ySpeedJ
              --ELASTIC COLLISION MAN!!!!
              xSpeedI, ySpeedI, xSpeedJ, ySpeedJ = 
              elastic(entities[i], entities[j])
              if entities[i].radius >= 4 then 
              --The rocks should never be too small.   
                local radius = entities[i].radius
                local sqrt2 = math.sqrt(2)
                local newRadius = radius/sqrt2 --So the new radius of the 
                --new two rocks left after the collision makes them have
                --half the area of the original rock.

                local angle = math.atan2(ySpeedI, xSpeedI) - math.pi / 2
                for k = 1, 2 do
                  local p1X = radius * math.cos(angle)
                  local p1Y = radius * math.sin(angle)

                  table.insert(entities, 
                  SpaceRock(entities[i].xCenter + p1X,
                            entities[i].yCenter + p1Y,
                            entities[i].red,
                            entities[i].green,
                            entities[i].blue,
                            newRadius))
                        
                  --RESULTS OF THE ELASTIC COLLISION
                  entities[#entities].xSpeed = xSpeedI + math.random(-2,2)
                  entities[#entities].ySpeed = ySpeedI + math.random(-2,2)
                  angle = angle + math.pi
                end
                  
              end
              --Explotion.
              insertFullExplotion(
                entities[i].xCenter, 
                entities[i].yCenter,
                entities[i].radius,
                xSpeedI, 
                ySpeedI)
                      
              table.remove(entities, j)
              table.remove(entities, i)
              i = i - 1
            end
          end
          break --If there is a collission.
        end
      end
    end
    i = i + 1
  end
   
  i = 1
  
  while i <= #entities do
    --update current entity:
    entities[i]:update(dt)
    --If an explotion was created, it must be destroyed after.
    if entities[i]:is(Explotion) and entities[i].radiusVar <= 0 then
      table.remove(entities, i)
      i = i - 1
    end  
    --If something gets out of bounds, destroy it.
    if  entities[i].xCenter > screenWidth + extSpace or
        entities[i].xCenter < -extSpace or
        entities[i].yCenter > screenHeight + extSpace or
        entities[i].yCenter < -extSpace then
      
      table.remove(entities, i)
      i = i - 1
    end  
    
    i = i + 1
  end

end

function play:draw()
  setDrawTarget()  
  
  --DRAW EVERYTHING
  --Draw Atmosphere:
  local totalRadius
  local margen = 2--Add a margen so collisions occur inside visible circle.
  for i = circleRadius, 2, -4 do
    local div = 116 / i
    love.graphics.setColor(div, div, div + div)
    totalRadius = circleRadius + i * 2 + margen
    love.graphics.circle(fillOrLine, centerScreenX , centerScreenY, 
      totalRadius)
  end
    
  local limit = #entities
  for i = 1, limit do
    entities[i]:draw()
  end
  
  --Draw Planet:
  love.graphics.setColor(78, 98, 136)
  love.graphics.circle(fillOrLine, centerScreenX , centerScreenY, 
    circleRadius + margen) 
  love.graphics.setColor(255,255,255)
    
  --I NEED INFORMATION MY BOY.
  local contExplotion = 0
  local contBullet = 0
  local contShip = 0
  local contSpaceRock = 0
  local contSpaceDust = 0
  local shipSpeed = 0
  local speedMaxLanding = 0
  local state = 0
  local rotation = 0
  local angleC = 0
  local sX = 0
  local sY = 0
  
  for i = 1, #entities do
    if entities[i]:is(Explotion) then
      contExplotion = contExplotion + 1
    elseif entities[i]:is(Bullet) then
      contBullet = contBullet + 1
    elseif entities[i]:is(Ship) then
      contShip = contShip + 1
      shipSpeed = entities[i].shipSpeed
      speedMaxLanding = entities[i].speedMaxLanding
      state = entities[i].state
      angleC = entities[i].angleC
      sX = entities[i].xCenter
      sY = entities[i].yCenter
      rotation = entities[i].rotation
    elseif entities[i]:is(SpaceRock) then
      contSpaceRock = contSpaceRock + 1
    elseif entities[i]:is(SpaceDust) then
      contSpaceDust = contSpaceDust + 1
    end
  end
  
  --Testeststststs prints!
  love.graphics.print("contSpaceDust: " .. contSpaceDust, 0, 10)
  love.graphics.print("contSpaceRock: " .. contSpaceRock, 0, 20)
  love.graphics.print("contShip: " .. contShip, 0, 30)
  love.graphics.print("contBullet: " .. contBullet, 0, 40)
  love.graphics.print("contExplotion: " .. contExplotion, 0, 50)
  love.graphics.print("shipSpeed: " .. 
    (string.format("%.2f", shipSpeed)) .. "pps", 0, 60)
  love.graphics.print("speedMaxLanding: " .. speedMaxLanding .. "pps", 0, 70)
  love.graphics.print("shipCollidedPlanet: " .. tostring(shipCollidedPlanet), 0, 90)
  
  love.graphics.print("state: " .. state, sX + 10, sY)
  love.graphics.print("angleC: " .. angleC, sX + 10, sY + 10)
  love.graphics.print("rotation: " .. rotation, sX + 10, sY + 20)
  love.graphics.print(math.abs(rotation - angleC) .. " > " .. math.pi / 32  , sX + 10, sY + 30)
  
  backToScreenAndUpscale()
end