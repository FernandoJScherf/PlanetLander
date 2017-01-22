--PLAY GAMESTATE CALLBACKS:
local extSpace = 40--screenWidth/4
local showInfo = false
local circleColor = {116, 116, 116}
circleRadius = 20
planetMass = 100000
local contSpaceRock = 0
local circleColorVar = 0
local circleColorTime = 0
local planet = 10 --Represent levels.
maxRadius = 30 --Maximum radius for Space Rocks.
entities = {}

local loaded = false --If sound files finished loading.

local waves--Waves of asteroids per level.
local wavesCont = 1 --Wave counter.

local timeWaves = 30 --Time between waves of asteroids.
local timeWavesCont = 0 --Time counter.

sources = {} --Table for sound effects that are being played.
local sourceShipDest ; local sourceRockExplosion = {}
--[[global sourcePropulsor ; sourceLaser]]

--LOAD STATE
---------------------------------------------------------------
local function placeNewDust()
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
end

function loadS:init()
  --GENERATE THE SOUND EFFECTS THAT WILL BE USED THROUGH THE GAME:
  local function sfsToSource(f, volume)
    local sound = sfxr.newSound()
    sound:loadBinary(f)
    sound.volume.sound = volume
    local soundData = sound:generateSoundData()
    return love.audio.newSource(soundData)
  end
  sourceShipDest = sfsToSource("sounds/AwesomeShipDestruction.sfs", 0.25)
  sourcePropulsor = sfsToSource("sounds/AwesomePropulsor.sfs", 0.1)
  sourceRockExplosion = sfsToSource("sounds/AwesomeExplosion.sfs", 0.3)
  sourceLaser = sfsToSource("sounds/AwesomeLaser.sfs", 0.3)
  sourceLaserVPlanet = sfsToSource("sounds/AwesomeLaserAgainstPlanet.sfs", 0.3)
  sourceElimination = sfsToSource("sounds/AwesomeCleaning.sfs", 0.3)

  --love.audio.setPosition(centerScreenX, centerScreenY, 0)
  love.audio.setDistanceModel("exponentclamped")
end

function loadS:enter()
    entities[1] = Ship(-extSpace * 0.75, centerScreenY * 1.5,
      circleColor[1] + circleColorVar,
      circleColor[2] + circleColorVar, circleColor[3] + circleColorVar)
    entities[1]:rotate(1, -math.pi / 2 )
    entities[1].aSpeed = 0
    placeNewDust()
end

function loadS:update(dt)
  --Change the color of the text in draw:
  circleColorVar = math.sin(circleColorTime) * 50
  circleColorTime = circleColorTime + dt * 6

  --Accelerate ship and update entities:

    if loaded then entities[1]:accel(70, dt) end
    for i = 1, #entities do
      entities[i].gravAffected = false
      entities[i]:update(dt)

    end
end

--IF planet changed to 2 and beyond, print "well Done first".
function loadS:draw()
  love.graphics.setColor(circleColor[1] + circleColorVar,
    circleColor[2] + circleColorVar, circleColor[3] + circleColorVar)
  
  love.graphics.printf("Get Ready for planet " .. planet .. " !",
    0, centerScreenY * 0.75, screenWidth, "center")
  
  love.graphics.setColor(255, 255, 255)
  loaded = true
  
  --Draw Entities:
    for i = 1, #entities do
      entities[i]:draw() 
    end

end

function loadS:keyreleased(key)
  if loaded then 
    --Get the table empty to use in next gamestate.
    for i = 1, #entities do
      entities[i] = nil
    end
    
    circleColorTime = 0
    
    Gamestate.switch(play)
  end
end


--PLAY STATE:
---------------------------------------------------------------
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

local function placeNewRocks(quantity, radius)
  limit = quantity + #entities
  for i = 1 + #entities, limit  do
    local color = math.random(30, 220)
    
    --There are 4 sectors, all of them out of the screen, where
    local sector = math.random(1,4) --an asteroid can appear.
    local x ; local y ; local xS ; local yS
    local searchingPosition = true
    
    while searchingPosition do
      if sector == 1 then
        x = math.random(-extSpace, 0)
        y = math.random(0, screenHeight)
        --Give it an inicial speed, going (more or less) towards planet:
        xS = math.random(0, 10)
        yS = math.random(-5, 5)
      elseif sector == 2 then
        x = math.random(0, screenWidth)
        y = math.random(-extSpace, 0)
        
        xS = math.random(-5, 5)
        yS = math.random(0, 10)
      elseif sector == 3 then
        x = math.random(screenWidth, screenWidth + extSpace)
        y = math.random(0, screenHeight)
        
        xS = math.random(-10, 0)
        yS = math.random(-5, 5)
      else
        x = math.random(0, screenWidth)
        y = math.random(screenHeight, screenHeight + extSpace)
        
        xS = math.random(-5, 5)
        yS = math.random(-10, 0)
      end
      
      --Check if we are not placing a new rock on top of another one:
      for i = 1, #entities do
        if entities[i]:is(SpaceRock) and
          checkColl(x, y, maxRadius, 
            entities[i].xCenter, 
              entities[i].yCenter, 
                entities[i].radius) then
          searchingPosition = true
          break
        end
        searchingPosition = false
      end
    end
    
    entities[i] = SpaceRock(x, y, color + 30, color, color, radius)
                
    entities[i].xSpeed = xS
    entities[i].ySpeed = yS
  end
end

--[[function play:leave()
  sourceLaser = nil
  sourcePropulsor = nil --This one in particular was global
  --because it also needed to exist in shipClass.lua.
  --So I destroy it when I don't need it anymore.
  maxRadius = nil --Also needed to exist in spaceRock. Not anymore.
  circleRadius = nil
end]]

function play:enter()
  entities[1] = Ship(centerScreenX + 100, centerScreenY + 70,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))
  --entities[1].xSpeed = 25
  entities[1].aSpeed = 0
  entities[1]:rotate(1, math.pi / 2 + 0.2)
  
  --Insert Space Dust:
  placeNewDust()
  
  --Calculate Difficulty of the current planet:
  --By the way, a "planet" is a "level".
  placeNewRocks(planet, 10)  --Asteroids at the biggining of planet.
  --Number of waves of asteroids depends on the number of planet.
  --waves = math.floor( ((planet - 1) / 2) + 2 )
  local logPlanet = math.log10(planet)
  waves = math.floor(logPlanet * 4 + 2)
  --Times between waves of asteroids depends on the number of planet:
  timeWaves = logPlanet * 16 + 18
  
  --Every level, the color of the planet should be different:
  local pos = planet + 2
  local shouldbethreeanyway = #circleColor
  while pos > shouldbethreeanyway do
    pos = pos - #circleColor
  end
  circleColor[pos] = circleColor[pos] * (planet + 1)
  while circleColor[pos] > 255 do
    circleColor[pos] = circleColor[pos] - 255
  end
  --And the mass and radius:
  circleRadius = math.random(10, 30)
  --The mass is proportional to the radius:
  planetMass = circleRadius * 4000  
  print(circleRadius .. " " .. planetMass)
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

function insertAndPlaySE(sourceToClone, x, y)
  --If we have too many sound effects in the source table.
  --eliminate the oldest one:
  local maxSounds = 12
  if #sources >= maxSounds then
    sources[1]:stop()
    table.remove(sources, 1)
  end
  --Insert clone of source sound effect to table and play it:
  table.insert(sources, sourceToClone:clone())
  
  x = x - centerScreenX
  y = y - centerScreenY
  
  --Divide to attenuate effect of the distance model:
  sources[#sources]:setPosition(x / 12, y / 12, 0) --Stereo, babe.
  sources[#sources]:play()
end


local function explosiveSoundRock(ent)
  sourceRockExplosion:setPitch(math.random(25, 50) / 50)
  sourceRockExplosion:setVolume(ent.radius / maxRadius)        
  insertAndPlaySE(sourceRockExplosion, ent.xCenter, ent.yCenter)
end

--PLAY:UPDATE--------------------------------
local shipCollidedPlanet
local waitTime = 0
function play:update(dt)
  local i = 1 
  shipCollidedPlanet = false
  --CHECK FOR COLLISIONS!!!
  while i <= #entities do
    --ENTITIES AGAINST PLANET: 
    --Don't check collision for: explosions.
    if checkColl(entities[i].xCenter, entities[i].yCenter, entities[i].radius,
      centerScreenX, centerScreenY, circleRadius) then
      
      --Special Conditions for the ship's collision
      if entities[i]:is(Ship) then
        if entities[i].collidable then
          --If the ship meets certain conditions, it lands
          --Otherwise, it is DESTROYED.
          
          if entities[i].shipSpeed > entities[i].speedMaxLanding then

            insertAndPlaySE(sourceShipDest, entities[i].xCenter, 
              entities[i].yCenter)

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
        sourceLaserVPlanet:setPitch(math.random(25, 50) / 50)
        insertAndPlaySE(sourceLaserVPlanet, entities[i].xCenter,
          entities[i].yCenter)
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
      
        if entities[i]:is(SpaceRock) then
          
          explosiveSoundRock(entities[i])

        end
      
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
              --Play Ship's Destruction Sound Effect:
              insertAndPlaySE(sourceShipDest, entities[j].xCenter, 
                entities[j].yCenter)
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
              explosiveSoundRock(entities[i])
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
  
  --Change the color of the planet and atmosphere every frame:
  circleColorVar = math.sin(circleColorTime) * 10
  circleColorTime = circleColorTime + dt
  
  
  contSpaceRock = 0
  for i = 1, #entities do
    if entities[i]:is(SpaceRock) then contSpaceRock = contSpaceRock + 1 end
  end
  --If the final wave of asteroids hasn't been reached:
  if wavesCont < waves then
    --If all asteroids were eliminated or the time for next wave is up:
    if contSpaceRock == 0 or timeWavesCont >= timeWaves then
      placeNewRocks(planet, 10)
      timeWavesCont = 0
      wavesCont = wavesCont + 1 --Next wave.
    end
    timeWavesCont = timeWavesCont + dt
  --If we reached the final wave and there are no asteroids left:
  elseif contSpaceRock == 0 then 
    for i = 1, #entities do
      entities[i].beUpdated = false --Everything will stop moving
    end
    --Get the table empty to use in next gamestate.
    --Also, lets make it pretty!
    local entMax = #entities
    if entMax >= 1 then
      --Every 0.01 of a second, destroy an object.
      if waitTime >= 0.01 then
        sourceElimination:setPitch(math.random(25, 50) / 50)
        insertAndPlaySE(sourceElimination, entities[entMax].xCenter,
          entities[entMax].yCenter)
        entities[entMax] = nil 
        waitTime = 0
        
      else
        waitTime = waitTime + dt
      end
    else
      wavesCont = 1             --Reset values for next planet.
      timeWavesCont = 0         --Reset values for next planet.
      planet = planet + 1       --Add 1 to planet.
      Gamestate.switch(loadS)   --To Get ready screen and next planet.
    end
  end
end

function play:draw()
  setDrawTarget()  
  
  --DRAW EVERYTHING
  --Draw Atmosphere:
  local totalRadius
  local margen = 2--Add a margen so collisions occur inside visible circle.
  for i = circleRadius, 2, -4 do
    --local div = 116 / i + circleColorVar
    --love.graphics.setColor(div, div, div + div)
    
    local r = circleColor[1] / i + circleColorVar
    local g = circleColor[2] / i + circleColorVar
    local b = circleColor[3] / i + circleColorVar
    love.graphics.setColor(r, g, b)
    
    
    totalRadius = circleRadius + i * 2 + margen
    love.graphics.circle(fillOrLine, centerScreenX , centerScreenY, 
      totalRadius)
  end
    
  local limit = #entities
  for i = 1, limit do
    entities[i]:draw()
  end
  
  --Draw Planet:
  love.graphics.setColor(circleColor[1] / 2 + circleColorVar, 
    circleColor[2] / 2 + circleColorVar, circleColor[3] / 2 + circleColorVar)
  love.graphics.circle(fillOrLine, centerScreenX , centerScreenY, 
    circleRadius + margen) 
  love.graphics.setColor(255,255,255)
  
  if showInfo then
    --I NEED INFORMATION MY BOY.
    local contExplotion = 0
    local contBullet = 0
    local contShip = 0
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
    love.graphics.print("shipCollidedPlanet: " .. 
      tostring(shipCollidedPlanet), 0, 90)
    
    love.graphics.print("state: " .. state, sX + 10, sY)
    love.graphics.print("angleC: " .. angleC, sX + 10, sY + 10)
    love.graphics.print("rotation: " .. rotation, sX + 10, sY + 20)
    love.graphics.print(math.abs(rotation - angleC) .. " > " .. 
      math.pi / 32, sX + 10, sY + 30)
    love.graphics.print("timeWavesCont: " .. timeWavesCont .. " >= " .. 
      "timeWaves: " .. timeWaves, 0, screenHeight - 40)
    love.graphics.print("wavesCont: " .. wavesCont .. " <= " .. 
      "waves: " .. waves, 0, screenHeight - 20)
  end
  
  backToScreenAndUpscale()
  
end

function play:keypressed(key)
  if key == "i" then-- and love.keyboard.isDown("i") then
    showInfo = not showInfo
  end
end