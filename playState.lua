--PLAY GAMESTATE CALLBACKS:
local circleRadius = 14
local ship ; local spaceDust = {} ; local spaceRock = {}

local nSpaceRocks
entities = {}

function play:init()
  entities[1] = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  entities[1].xSpeed = 25
  entities[1].aSpeed = 2
  --ship = entities[1]
  
  local extSpace = screenWidth/4
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
  
  nSpaceRocks = 100
  limit = nSpaceRocks + #entities
  for i = 1 + #entities, limit  do
    local color = math.random(30, 220)
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
  local dRadius = (r1 + r2) - (r1 + r2)/4 --Some margin for the player
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
            
          --[[if entities[i]:is(SpaceRock) then
            table.remove(entities, j)
            --table.remove(entities, i)
            i = i - 1
          end]]
          local ent1 = Polygon(0,0,{0,0},0,0,0) ; local ent1Pos
          local ent2 = Polygon(0,0,{0,0},0,0,0) ; local ent2Pos
          --So SpaceRock type is always in ent1 if there is in fact 
          --an SpaceRock in the comparison:
          if entities[i]:is(SpaceRock) then 
            ent1 = entities[i] ; ent1Pos = i
            ent2 = entities[j] ; ent2Pos = j
          elseif entities[j]:is(SpaceRock) then
            ent1 = entities[j] ; ent1Pos = j
            ent2 = entities[i] ; ent2Pos = i
          end
          if ent1:is(SpaceRock) then --If there is an Space Rock.
            if ent2:is(SpaceRock) then--Against another spaceRock.
              table.remove(entities, j)
              table.remove(entities, i)
              i = i - 1
            elseif ent2:is(SpaceDust) then--Against SpaceDust
              table.remove(entities, ent2Pos)
              i = i - 1
            elseif ent2:is(Ship) then --Against Ship
              table.remove(entities, ent2Pos)
              i = i - 1
            end
          end
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