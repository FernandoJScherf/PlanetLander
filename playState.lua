--PLAY GAMESTATE CALLBACKS:
local circleRadius = 14
local ship ; local spaceDust = {} ; local spaceRock = {}

local extSpace = 40--screenWidth/4

local nSpaceRocks
entities = {}

function play:init()
  entities[1] = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  entities[1].xSpeed = 25
  entities[1].aSpeed = 0
  --ship = entities[1]
  
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
  
  nSpaceRocks = 10
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

function play:update(dt)
  local i = 1
  --CHECK FOR COLLISIONS!!!
  while i <= #entities do
    --ENTITIES AGAINST PLANET:
    if checkColl(entities[i].xCenter, entities[i].yCenter, entities[i].radius,
        centerScreenX, centerScreenY, circleRadius) then
      table.remove(entities, i)
      i = i - 1
    else
    --ENTITIES VS ENTITIES:
      for j = i + 1, #entities do
        if checkColl(entities[i].xCenter, entities[i].yCenter,
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
              
              --table.remove(entities, j)
              --table.remove(entities, i)
              
              --i = i - 1
            elseif entities[j]:is(SpaceDust) then--Against SpaceDust
              table.remove(entities, j)
              i = i - 1
            elseif entities[j]:is(Ship) then --Against Ship
              table.remove(entities, j)
              i = i - 1
            elseif entities[j]:is(Bullet) then
              if entities[i].radius >= 4 then 
              --The rocks should never be too small.
                local xSpeedI ; local ySpeedI
                local xSpeedJ ; local ySpeedJ
                --ELASTIC COLLISION MAN!!!!
                xSpeedI, ySpeedI, xSpeedJ, ySpeedJ = 
                elastic(entities[i], entities[j])
                
                local radius = entities[i].radius
                local sqrt2 = math.sqrt(2)
                local newRadius = radius/sqrt2 --So the new radius of the 
                --new two rocks left after the collision makes them have
                --half the area of the original rock.
                for k = 1, 2 do
                  table.insert(entities, 
                  SpaceRock(entities[i].xCenter + radius * k * 2,
                            entities[i].yCenter,
                            entities[i].red,
                            entities[i].green,
                            entities[i].blue,
                            newRadius))
                  --RESULTS OF THE ELASTIC COLLISION
                  entities[#entities].xSpeed = xSpeedI + math.random(-2,2)
                  entities[#entities].ySpeed = ySpeedI + math.random(-2,2)
                end
              end
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
   
  --This was not necessary: local limit = #entities
  for i = 1, #entities do
      --update current entity:
      entities[i]:update(dt)
  end
    
end

function play:draw()
  setDrawTarget()  
  
  --DRAW EVERYTHING
    --Draw Planet:
    local totalRadius
    for i = 16, 2, -4 do
      love.graphics.setColor(116 / i, 116 / i, 232 / i)
      totalRadius = circleRadius + i * 2
      love.graphics.circle(fillOrLine, centerScreenX , centerScreenY, 
        totalRadius)
    end
    love.graphics.setColor(78, 98, 136)
    love.graphics.circle(fillOrLine, centerScreenX , centerScreenY, 
      circleRadius)
    love.graphics.setColor(255,255,255)
    
  local limit = #entities
  for i = 1, limit do
    entities[i]:draw()
  end
    
  backToScreenAndUpscale()
end