--PLAY GAMESTATE CALLBACKS:
local circleRadius = 14
local ship ; local spaceDust = {} ; local spaceRock = {}
local nSpaceDusts = math.floor( screenWidth / 4 )
local nSpaceRocks
local entities = {}

function play:init()
  entities[1] = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  entities[1].xSpeed = 15
  entities[1].aSpeed = 2
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

function checkCollision(x1, y1, r1, x2, y2, r2)
  
end

function play:update(dt)
  --Change for while, probably
  local i = 1
  while i <= #entities do
    --Check for collision
    if  entities[i].radius then --They all should have radius......
      --Anything Against Planet:
      local entity = entities[i]
        local dX = math.abs(entity.xCenter - centerScreenX)
        local dY = math.abs(entity.yCenter - centerScreenY)
        local dRadius = entity.radius - entity.radius/3 + circleRadius
      if dRadius >= dX and dRadius >= dY then
          table.remove(entities, i)
          i = i - 1
        --end
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