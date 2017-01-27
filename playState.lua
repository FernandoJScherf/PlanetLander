--PLAY GAMESTATE CALLBACKS:
local extSpace = 40--screenWidth/4
local showInfo = false
local circleColor = {116, 116, 156}
circleRadius = 20
planetMass = 100000
local contSpaceRock = 0
local circleColorVar = 0
local circleColorTime = 0
local playerScore = 0
local planet = 1 --Represent levels.
local planetPop --Planet's Population.
local planetPopStart --Population at the start of the level.
local extraShips = 0 --Extra lives.
local buildingShip = 0 --After 100% of metlas were collected, this aumentates
                            --rapidly. Velocity depends on alien population
                            --building the ship.
local messageToPrint = {false, false, false} --String, x, y
maxRadius = 30 --Maximum radius for Space Rocks.
entities = {}

local loaded = false --If sound files finished loading, true.

local waves--Waves of asteroids per level.
local wavesCont = 1 --Wave counter.

local timeWaves = 30 --Time between waves of asteroids.
local timeWavesCont = 0 --Time counter.

sourceSFXR = {} --Table for the sources generated using sfxr.lua
sources = {} --Table for sound effects that are being played.
--[[global sourceSFXR.Propulsor ; sourceSFXR.Laser]]

local function percentage(a, b)
a = a / b * 100
return a
end

local function searchShip()
  local ship = nil
  for i = 1, #entities do         --Search for ship in table, first.
    if entities[i]:is(Ship) then 
      ship = entities[i] 
      break
    end
  end
  return ship
end
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

function loadS:enter()
  --Load sources if they are still not loaded. If sources are not loaded, we can also conclude
  --That the game is being excuted for the first time after the menu state:
  if not sourceSFXR.ShipDest then
    playerScore = 0 --So playerScore is put to 0.
    
    --GENERATE THE SOUND EFFECTS THAT WILL BE USED THROUGH THE GAME:
    local function sfsToSource(f, volume)
      local sound = sfxr.newSound()
      sound:loadBinary(f)
      sound.volume.sound = volume
      local soundData = sound:generateSoundData()
      return love.audio.newSource(soundData)
    end
    
    sourceSFXR.ShipDest = sfsToSource("sounds/AwesomeShipDestruction.sfs", 0.40)
    sourceSFXR.Propulsor = sfsToSource("sounds/AwesomePropulsor.sfs", 0.25)
    sourceSFXR.RockExplosion = sfsToSource("sounds/AwesomeExplosion.sfs", 0.45)
    sourceSFXR.Laser = sfsToSource("sounds/AwesomeLaser.sfs", 0.45)
    sourceSFXR.LaserVPlanet = sfsToSource("sounds/AwesomeLaserAgainstPlanet.sfs", 0.45)
    sourceSFXR.Elimination = sfsToSource("sounds/AwesomeCleaning.sfs", 0.45)
    sourceSFXR.Building = sfsToSource("sounds/AwesomeBuildingShip.sfs", 0.05)
    sourceSFXR.ExtraShip = sfsToSource("sounds/AwesomeExtraShip.sfs", 0.05)
    sourceSFXR.ReCharging = sfsToSource("sounds/AwesomeEnergyCharging.sfs", 0.1)
    sourceSFXR.TimeToLand = sfsToSource("sounds/AwesomeTimeToLand.sfs", 0.035)
    sourceSFXR.NextShip = sfsToSource("sounds/AwesomeNextShip.sfs", 0.06)
    sourceSFXR.ShipOut = sfsToSource("sounds/AwesomeShipOut.sfs", 0.06)

    love.audio.setDistanceModel("exponentclamped")
  end

  --First I verifie if entities[1] even exists (Not nil)
  if entities[1] and entities[1]:is(Ship) then        --Which we made sure was a ship before
    --Save certain characterisctics we need from the ship before "reseting":
    local saveMetals = entities[1].metals
    local saveR = entities[1].red
    local saveG = entities[1].green
    local saveB = entities[1].blue
    
    --"Reset" Ship, but with those characteristics:
    entities[1] = Ship(-extSpace * 0.75, centerScreenY * 1.5, saveR, saveG, saveB)
    entities[1].metals = saveMetals
    
  else
    entities[1] = Ship(-extSpace * 0.75, centerScreenY * 1.5,
      math.random(127, 255),
      math.random(127, 255),
      math.random(127, 255))
  end
  
  entities[1]:rotate(1, -math.pi / 2 )
  entities[1].aSpeed = 0
  entities[1].inputActive = false --The player shouldn't be able to controll the ship now.
  placeNewDust()
    
  --Calculate Planet Population, proportional to level, with some random addition:
  planetPop = math.ceil((501 * planet) * (1 + math.random() / 4))
  planetPopStart = planetPop --To keep track of the original population, when some is lost.
end

function loadS:update(dt)
  --Change the color of the text in draw:
  circleColorVar = math.sin(circleColorTime) * 50
  circleColorTime = circleColorTime + dt * 6

  --Accelerate ship and update entities:
  if loaded then
    entities[1]:accel(70, dt) 
  end
  for i = 1, #entities do
    entities[i].gravAffected = false
    entities[i]:update(dt)
  end
end

function loadS:draw()
  love.graphics.setColor(circleColor[1] + circleColorVar,
    circleColor[2] + circleColorVar, circleColor[3] + circleColorVar)
  
  love.graphics.printf("Get Ready for Planet " .. planet .. " !",
    0, centerScreenY - 35, screenWidth, "center")
  love.graphics.printf("Population: " .. planetPop .. " Happy Alien Families.",
    0, centerScreenY - 20, screenWidth, "center")
  
  love.graphics.setColor(255, 255, 255)
  loaded = true
  
  --Draw Entities:
    for i = 1, #entities do
      entities[i]:draw() 
    end

end

function loadS:keypressed(key)
  if loaded then 
    --Get the table empty to use in next gamestate. (Except for ship, that is in entities[1]
    for i = 2, #entities do
      entities[i] = nil
    end
    
    circleColorTime = 0
    loaded = false --For next time game begins from menu and loading must be done again.
    
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

local sectorCounter = planet
local sector = 1
local function placeNewRocks(quantity, radius)
  limit = quantity + #entities
  for i = 1 + #entities, limit  do
    local color = math.random(60, 220)
    
    --There are 4 sectors, all of them out of the screen, where
    if sectorCounter >= planet then
      sector = math.random(1,4) --Choose in which sector an asteroid can appear.
      sectorCounter = 0
    else
      sectorCounter =  sectorCounter + 1
    end
    
    
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
    
    radius = radius * (1 + math.random() / 12)
    entities[i] = SpaceRock(x, y, color + 30, color, color, radius)
                
    entities[i].xSpeed = xS
    entities[i].ySpeed = yS
  end
end

--[[function play:leave()
  sourceSFXR.Laser = nil
  sourceSFXR.Propulsor = nil --This one in particular was global
  --because it also needed to exist in shipClass.lua.
  --So I destroy it when I don't need it anymore.
  maxRadius = nil --Also needed to exist in spaceRock. Not anymore.
  circleRadius = nil
end]]

function play:enter()
  --Every level, the color of the planet should be different:
  --[[local pos = planet + 2
  local shouldbethreeanyway = #circleColor
  while pos > shouldbethreeanyway do
    pos = pos - #circleColor
  end
  circleColor[pos] = circleColor[pos] * (planet + 1)
  while circleColor[pos] > 255 do
    circleColor[pos] = circleColor[pos] - 255
  end]]

  for i = 1, #circleColor do
    circleColor[i] = math.random(127, 255)
  end
  
  --And the mass and radius:
  circleRadius = 35--math.random(15, 35)
  --The mass is proportional to the Area:
  planetMass = (circleRadius  ^ 2) * 150  --Area = radio ^ 2 * pi
  --print(circleRadius .. " " .. planetMass)
  --[[entities[1] = Ship(centerScreenX + 100, centerScreenY + 70,
         math.random(0, 100), math.random(0, 100), math.random(150, 170))]]
  --entities[1].xSpeed = 25
  --Ship was created in LoadS:enter(). JUST MOVE IT!
  entities[1]:teleTransport(centerScreenX, centerScreenY - circleRadius - 2 - entities[1].radius)
  entities[1].energy = entities[1].energyMax
  entities[1].xSpeed = 0
  entities[1].ySpeed = 0
  entities[1].aSpeed = 0
  entities[1]:rotate(1, -math.pi / 2 )
  entities[1].gravAffected = true --This was made false in loadS:update
  entities[1].inputActive = true --This was made false in loadS:enter
  
  --Insert Space Dust:
  placeNewDust()
  
  --Calculate Difficulty of the current planet:
  --By the way, a "planet" is a "level".
  placeNewRocks(planet, 13)  --Asteroids at the biggining of planet.
  --Number of waves of asteroids depends on the number of planet.
  --waves = math.floor( ((planet - 1) / 2) + 2 )
  local logPlanet = math.log10(planet)
  waves = math.floor(logPlanet * 4 + 2)
  --Times between waves of asteroids depends on the number of planet:
  timeWaves = logPlanet * 16 + 18
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
    for amp = 1, radiusMax * 2, 2 do
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
  sourceSFXR.RockExplosion:setPitch(math.random(25, 50) / 50)
  sourceSFXR.RockExplosion:setVolume(ent.radius / maxRadius)        
  insertAndPlaySE(sourceSFXR.RockExplosion, ent.xCenter, ent.yCenter)
end

local function xenocide(howMany)
  if searchShip() or buildingShip > 0 then --If the player is still in the game.
    if planetPop > 0 then
      local planetPopBefore = planetPop
      howMany = howMany * (1 + math.random() / 4)--howmany + howMany * math.random() / 4
      if planetPop > howMany then
        planetPop = planetPop - howMany
      else
        planetPop = 0
      end
      playerScore = playerScore - planetPopBefore + planetPop
    end
  end
end

--play:update
local shipCollidedPlanet
local waitTime = 0
local hasLanded = false
local pointsForSurvivorsCount = 0
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

            insertAndPlaySE(sourceSFXR.ShipDest, entities[i].xCenter, 
              entities[i].yCenter)

            --REMOVE POINTS HERE:
            xenocide(312) --You killed some aliens during the crashing.
            
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
        sourceSFXR.LaserVPlanet:setPitch(math.random(25, 50) / 50)
        insertAndPlaySE(sourceSFXR.LaserVPlanet, entities[i].xCenter,
          entities[i].yCenter)
      --REMOVE POINTS HERE:
        xenocide(144) --You killed some aliens hooting at them!
      
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
      
        --Special conditions for Asteroids (And metals):
        if entities[i]:is(SpaceRock) then
          
          --PLANET COLLECTS METAL!
          --if entities[i]:is(SpaceMetal) then
            --search for ship:
            --[[for o = 1, #entities do
              if entities[o]:is(Ship) then
                entities[o]:collectMetal()
                break
              end
            end]]
            --local ship = searchShip()
            --if ship then ship:collectMetal() end --It doesn't collects metal anymore.
            
          if not entities[i]:is(SpaceMetal) then
            
            explosiveSoundRock(entities[i])
            --REMOVES POINTS HERE:
            --The rock kills many people, a number depending on it's radius:
            xenocide(entities[i].radius ^ 3) 
          end
        end
      
        --if not entities[i]:is(SpaceMetal) then
          insertFullExplotion(
                  entities[i].xCenter, 
                  entities[i].yCenter,
                  entities[i].radius,
                  0, 
                  0)
        --end
        
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
              
              --To avoid bug of the rocks "sticking" to each other if one
              --happens to appear inside of the other:
              local entI = entities[i]; local entJ = entities[j]
              local xI = entI.xCenter;  local yI = entI.yCenter
              local xJ = entJ.xCenter;  local yJ = entJ.yCenter
              local time = 0
              while checkColl(xI, yI, entI.radius, xJ, yJ, entJ.radius)
                and time < 0.5 do
                xI = xI + xSpeedI * dt
                yI = yI + ySpeedI * dt
                xJ = xJ + xSpeedJ * dt
                yJ = yJ + ySpeedJ * dt
                time = time + dt
              end
              entI:teleTransport(xI, yI)
              entJ:teleTransport(xJ, yJ)
              
            elseif entities[j]:is(SpaceDust) then--Against SpaceDust.
              table.remove(entities, j)
              i = i - 1
            elseif entities[j]:is(Ship) then --Against Ship.
              if entities[i]:is(SpaceMetal) then --SHIP COLLECTS METAL!
                
                entities[j]:collectMetal() --Add one to metal counter an play sfx.
                
                table.remove(entities, i)
              else
                --Play Ship's Destruction Sound Effect:
                insertAndPlaySE(sourceSFXR.ShipDest, entities[j].xCenter, 
                  entities[j].yCenter)
                --Explotion!
                insertFullExplotion(
                  entities[j].xCenter, 
                  entities[j].yCenter,
                  entities[j].radius + 5,
                  entities[i].xSpeed, --In this case, the collision is completely
                  entities[i].ySpeed) --Inelastic :D
                
                table.remove(entities, j)
              end
              i = i - 1
            elseif entities[j]:is(Bullet) then --Against Bullet.              
              local xSpeedI ; local ySpeedI
              local xSpeedJ ; local ySpeedJ
              --ELASTIC COLLISION MAN!!!!
              xSpeedI, ySpeedI, xSpeedJ, ySpeedJ = 
              elastic(entities[i], entities[j])
              --The rocks should never be too small:
              if entities[i].radius >= 4 then 
                
                --ADD SCORE, depending on the asteroid's radius:
                playerScore = 2000 / entities[i].radius + 100 + playerScore
                
                local pi = math.pi
                local radius = entities[i].radius --of rock
                local xCenter = entities[i].xCenter
                local yCenter = entities[i].yCenter
                
                if math.random(1, 4) == 1 then --1/4 chance.
                  --Insert SpaceMetal:
                  local k = #entities --save top table place at this point.
                  local radiusExpan = radius * 3 --Radius of the asteroid, but bigger.
                  
                  --The quantity of the metals depends on the radius of the rock.
                  --The sum of the areas of all the metals must be
                  --equal to the area of the original space rock:
                  --(The radius of the little metals is 3. 3 ^ 2 = 9
                  local nSpaceMetals = math.ceil((radius ^ 2) / 9)
                  local i = 1
                  while i <= nSpaceMetals do
                    
                    local angle = math.random() * 2 * pi
                    local rad = math.random() * radiusExpan
                    local x = math.cos(angle) * rad + xCenter
                    local y = math.sin(angle) * rad + yCenter
                    --Check if we are not about to place a metal on top of
                    --other metal:
                    local resultColl = false
                    for o = k + 1, #entities do
                      resultColl = checkColl(x, y, 2, 
                        entities[o].xCenter, entities[o].yCenter, entities[o].radius)
                      if resultColl then break end
                    end
                    if resultColl == false then
                      table.insert(entities, SpaceMetal(x, y, 3)) --Insert to table 
                        --in the possition that we now know is correct.
                        
                      --RESULTS OF THE ELASTIC COLLISION
                      entities[#entities].xSpeed = xSpeedI/3 + math.random(-2,2)
                      entities[#entities].ySpeed = ySpeedI/3 + math.random(-2,2)
                        
                      i = i + 1 --advance to next spacemetal.
                    end
                  end
                  
                else
                  --Insert two smaller SpaceRocks:
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
      
      --Special sound for ship getting out of bounds:
      if entities[i]:is(Ship) then
        insertAndPlaySE(sourceSFXR.ShipOut, centerScreenX, centerScreenY)
      end
      table.remove(entities, i)
      i = i - 1
    end  
    
    i = i + 1
  end
  
  --Change the color of the planet and atmosphere every frame:
  circleColorVar = math.sin(circleColorTime) * 10
  circleColorTime = circleColorTime + dt
  
  local ship = searchShip()
  local planetFinishedMult = 1
  contSpaceRock = 0
  for i = 1, #entities do
    if entities[i]:is(SpaceRock) and not entities[i]:is(SpaceMetal) then
      contSpaceRock = contSpaceRock + 1 
    end
  end
  --If the final wave of asteroids hasn't been reached:
  if wavesCont < waves then
    --If all asteroids were eliminated or the time for next wave is up:
    if contSpaceRock == 0 or timeWavesCont >= timeWaves then
      placeNewRocks(planet, 13)
      timeWavesCont = 0
      wavesCont = wavesCont + 1 --Next wave.
    end
    timeWavesCont = timeWavesCont + dt
  --If we reached the final wave and there are no asteroids left:
  elseif contSpaceRock == 0 then 
    planetFinishedMult = 10
    if ship then  
      --After landing to fix the ship and make new one if possible:
      if buildingShip == 0 and ship.energy >= ship.energyMax and
        pointsForSurvivorsCount >= planetPop then 
        for i = 1, #entities do
          entities[i].beUpdated = false --Everything will stop moving
        end
        --Get the table empty to use in next gamestate.
        --Also, lets make it pretty!
        local entMax = #entities
        if entMax >= 2 then --1 is reserved for the ship.
          --Every 0.005 of a second, destroy an object.
          if waitTime >= 0.01 then
            sourceSFXR.Elimination:setPitch(math.random(25, 50) / 50)
            insertAndPlaySE(sourceSFXR.Elimination, entities[entMax].xCenter,
              entities[entMax].yCenter)
            
            --Don't Eliminate the SHIP!:
            if entities[entMax]:is(Ship) then
              entities[1] = entities[entMax]  --THE SHIP IS SAVED IN FIRST POSITION.
              ship = entities[1]              --This is important in LoadS:enter()
            end
            entities[entMax] = nil 
            waitTime = 0
            
          else
            waitTime = waitTime + dt
          end
        else
          wavesCont = 1                   --Reset values for next planet.
          timeWavesCont = 0               --Reset values for next planet.
          pointsForSurvivorsCount = 0     --Reset values for next planet.
          planet = planet + 1             --Add 1 to planet.
          Gamestate.switch(loadS)         --To Get ready screen and next planet.
        end
      else
        local sin = math.sin(waitTime) * 10
        if ship.state == 1 and math.abs(sin) >= 9.8 then --Ship in flying state.
          --insertAndPlaySE(sourceSFXR.TimeToLand, centerScreenX, centerScreenY)
          if not sourceSFXR.TimeToLand:isPlaying() then
            sourceSFXR.TimeToLand:play()
          end
        end
        messageToPrint = {"Time to Land!",
          0, centerScreenY - circleRadius * 4 + sin}
        waitTime = waitTime + dt * 3
      end
    end
  end
  
  if ship then --If ship exist in table (Was not destroyed)
    --Check if 100% of metals were collected, and build next ship:  
    if ship.metals >= ship.metalsMax then
      if ship.state == 4 then --If ship has landed
        hasLanded = true
        ship.metals = 0
      end
    end
  
    --Increase energy of the ship if it has landed:
    if ship.state == 4 and ship.energy < ship.energyMax then
      insertAndPlaySE(sourceSFXR.ReCharging, ship.xCenter, ship.yCenter)
      ship.energy = ship.energy + ((planetPop + 500) / 250) * dt * planetFinishedMult * 2
      if ship.energy > ship.energyMax then ship.energy = ship.energyMax end
    end
    
  --Gain points for planet's survivors, when the level is over:
    if ship.state == 4 and 
      planetFinishedMult > 1 and            --Only when the level is over,
        pointsForSurvivorsCount < planetPop then --the multiplicator is bigger.
      local dtMult = 250 * dt
      playerScore = playerScore + dtMult
      pointsForSurvivorsCount = pointsForSurvivorsCount + dtMult
      local cloned = sourceSFXR.ReCharging:clone()
      cloned:setPitch(3)
      cloned:setVolume(0.55)
      insertAndPlaySE(cloned, centerScreenX, centerScreenY)
      messageToPrint[1] = {{0, 255, 127},string.format("+%d!  ", planetPop)}
      messageToPrint[2] = 0
      messageToPrint[3] = 32
      messageToPrint[4] = "right"
    end
    
  --If ship is not in table (Was destroyed):
  else
    if extraShips >= 1 then
      Gamestate.push(preparingShip, circleColor) --Wait for the extra ship with a cool effect.
      --Then insert new ship (In that same state) 
      --[[
      table.insert(entities, Ship(centerScreenX, centerScreenY,
        circleColor[1], circleColor[2], circleColor[3]))
      local entShip = entities[#entities]
      entShip:rotate(1, math.pi)
      entShip:teleTransport(entShip.xCenter, entShip.yCenter - circleRadius - 2 - entShip.radius)]]
    end
    if extraShips >= 1 then extraShips = extraShips - 1 end
    --In play:keyreleased if player presses a key, goes to the scorestate, if there are no lives left.
  end
  
  --Increase energy of the ship if it has landed:
  if hasLanded then
    --Velocity of construction depends on planet Population:
    buildingShip = buildingShip + ((planetPop + 500) / 250) * dt * planetFinishedMult
    if buildingShip % 5 < 0.1 then
      insertAndPlaySE(sourceSFXR.Building, centerScreenX, centerScreenY)
    end
    if buildingShip >= 100 then
      buildingShip = 0
      extraShips = extraShips + 1
      insertAndPlaySE(sourceSFXR.ExtraShip, centerScreenX, centerScreenY)
      hasLanded = false
    end
  end
end

function play:draw()
  setDrawTarget()  
  
  --DRAW EVERYTHING
  --Draw Atmosphere:
  local totalRadius
  local margen = 2--Add a margen so collisions occur inside visible circle.
  
  --Make planet more red while its population decreases:
  local perc = percentage(planetPop, planetPopStart) / 125 + 0.2
  
  for i = circleRadius, 2, -4 do    
    local r = circleColor[1] / i + circleColorVar
    local g = (circleColor[2] * perc) / i + circleColorVar
    local b = (circleColor[3] * perc) / i + circleColorVar
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
  love.graphics.setColor(
    circleColor[1] / 2 + circleColorVar, 
    (circleColor[2] * perc) / 2 + circleColorVar,
    (circleColor[3] * perc) / 2 + circleColorVar)
  love.graphics.circle(fillOrLine, centerScreenX , centerScreenY, 
    circleRadius + margen) 
  love.graphics.setColor(255,255,255)
  
  if not showInfo then
    --GUI:
    local ship
    for i = 1, #entities do
      if entities[i]:is(Ship) then 
        ship = entities[i]
        break
      end
      ship = nil
    end
    if ship then
      --Make it more red the closer it gets to energy 0.
      local perc = percentage(ship.energy, ship.energyMax)
      local coloredText = {{255, perc * 2.55, perc * 2.55}, string.format("%.1f %%", perc)}
      love.graphics.print(coloredText, ship.xCenter + ship.radius + 5, ship.yCenter)
 
      perc = percentage(ship.metals, ship.metalsMax)
      coloredText = {{255, 255, 255}, string.format("Metals: %.1f %%", perc)}
      love.graphics.print(coloredText, 4, 5)
      
      coloredText = {{255, 255, 255}, string.format("Population: %d", planetPop)}
      love.graphics.print(coloredText, 4, 20)
      
      love.graphics.printf("Extra Ships: " .. extraShips,
        0, 5, screenWidth, "center")
      
    end
    
    local greenBlue = 255
    if playerScore < 0 then
      greenBlue = 0
    end
    love.graphics.printf({{255, greenBlue, greenBlue}, string.format("Score: %d", playerScore)},
      0, 20, screenWidth - 4, "right")
    
    if buildingShip > 0 then
      love.graphics.printf(string.format("Building Extra Ship: %.1f %%", buildingShip),
        0, 20, screenWidth, "center")
    end
    
    if messageToPrint[1] then
      love.graphics.printf(messageToPrint[1], messageToPrint[2], messageToPrint[3], 
        screenWidth, messageToPrint[4] or "center")
      messageToPrint[1] = false
    end
      
  else
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
    love.graphics.print("contExplosion: " .. contExplotion, 0, 50)
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
  if key == "i" and love.keyboard.isDown("lctrl") then
    showInfo = not showInfo
  elseif key == "p" then
    Gamestate.push(pause)  
  end
  
  --If ship has been destroyed and there are no lives left:
  if extraShips < 1 and buildingShip == 0 and not searchShip() then
    --Free sources from memory:
    for k,v in pairs(sourceSFXR) do
      sourceSFXR[k] = nil
    end

    extraShips = 0
    for i = 1, #entities do --Empty table:
      entities[i] = nil
    end
    planet = 1 --Reset Planet.
    Gamestate.switch(score)
  end
end

--function play:keyreleased(key)
  --[[--If ship has been destroyed and there are no lives left:
  if extraShips < 0 then
    --Free sources from memory:
    for k,v in pairs(sourceSFXR) do
      sourceSFXR[k] = nil
    end

    extraShips = 0
    for i = 1, #entities do --Empty table:
      entities[i] = nil
    end
    planet = 1 --Reset Planet.
    Gamestate.switch(score)
  end]]
--end