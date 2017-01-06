--PLAY GAMESTATE CALLBACKS:
local circleRadius = 14
local ship ; local spaceDust = {} ; local spaceRock = {}
local nSpaceDusts = math.floor( screenWidth / 4 )
local nSpaceRocks
entities = {}

function play:init()
  entities[1] = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  entities[1].xSpeed = 15
  entities[1].aSpeed = 2
  ship = entities[1]
  entities[2] = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  entities[2].xSpeed = 00
  entities[2].aSpeed = 2
  
  local extSpace = screenWidth/4
  local limit = nSpaceDusts + #entities
  for i = 1 + #entities, limit  do
    local color = math.random(100, 200)
    entities[i] = SpaceDust(math.random(-extSpace, screenWidth + extSpace),
                  math.random(-extSpace, screenHeight + extSpace), color - 50,
                  color - 50, color + 10)
    
    entities[i].xSpeed = math.random( -25, 25) 
    entities[i].ySpeed = math.random( -25, 25) 
  end
  
  nSpaceRocks = 10
  limit = nSpaceRocks + #entities
  for i = 1 + #entities, limit  do
    local color = math.random(100, 200)
    local x ; local y
    
    entities[i] = SpaceRock(math.random(-extSpace, screenWidth + extSpace),
                  math.random(-extSpace, screenWidth + extSpace),
                  color + 30, color, color, 10)
  end
  
end

function checkColl(x1, y1, r1, x2, y2, r2)
  local entity = entities[i]
  local dX = math.abs(x2 - x1)
  local dY = math.abs(y2 - y1)
  local dRadius = r1 + r2
  if dRadius >= dX and dRadius >= dY then
    return true
  else
    return false
  end 
end

function play:update(dt)
  local i = 1
  --CHECK FOR COLLISIONS!!!
  while i <= #entities do
    --Anything Against Planet:
    if checkColl(entities[i].xCenter, entities[i].yCenter, entities[i].radius,
        centerScreenX, centerScreenY, circleRadius) then
      table.remove(entities, i)
      i = i - 1
    else
    --Entities vs entities:
      for j = i + 1, #entities do
        if checkColl(entities[i].xCenter, entities[i].yCenter,
            entities[i].radius, entities[j].xCenter, entities[j].yCenter,
            entities[j].radius) then
          table.remove(entities, j)
          --table.remove(entities, i)
          i = i - 1
          break
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