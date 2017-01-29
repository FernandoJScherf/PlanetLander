--Planet Lander. Fernando Jose Scherf. December 2016 - January 2017.

  upscalingFactor = 1
  screenWidth = 568--256*2--256 
  centerScreenX = screenWidth / 2
  screenHeight = screenWidth --144*2--144 
  centerScreenY = screenHeight / 2
  fillOrLine = "fill" --For the polygons and circles and stuff.

--The next two functions are needed to draw to the canvas and then
--back from the canvas to the screen, upscaled, in every gamestate:draw:
function setDrawTarget()
  --Set the draw target to the canvas
  love.graphics.setCanvas(canvas)
  --Is necesary to clear the screen because the canvas will still have what
  --was draw on it during the past frame:
  love.graphics.clear()
end

function backToScreenAndUpscale()
  --This sets the target back to the screen.
  --(Once you draw on the offscreen canvas, you have to draw the canvas
  --on the visible screen)
    love.graphics.setCanvas() 
  --DRAW UPSCALED CANVAS.
  local x = 0
  local y = 0  
  if love.window.getFullscreen() then
    x, y = love.graphics.getDimensions()
    x = x / 2 - centerScreenX
    y = y / 2 - centerScreenY
  end
  love.graphics.draw(canvas, x, y, 0, upscalingFactor, upscalingFactor) 
  love.graphics.rectangle("line", x, y, screenWidth, screenHeight)
   
end
  

--LOVE CALLBACKS:
function love.load()
  menu = {} --Menu gamestate
  play = {} --Game gamestate
  score = {} --High Score gamestate
  loadS = {} --Load gamestate. To generate the sound effects, which takes its time.
  pause = {} --Pause gamestate.
  preparingShip = {} --State that happens when player loses ships, but still has extras.
  allDead = {} --State that happens when planetPop == 0.
  
  Object = require "classic"
  Gamestate = require "gamestate"
  require "menuState"
  require "playState"
  require "scoreState"
  require "pointSuperClass"
  require "polygonSuperClass"
  require "shipClass"
  require "spaceDustClass"
  require "spaceRockClass"
  require "bulletClass"
  require "explotionClass"
  sfxr = require("sfxr")
  require "spaceMetalClass"
  require "pauseState"
  require "prepShipState"
  require "allDeadState"
  require "SICK"
  
  highscore.set("hs.txt", 15, "FJS", 68000)
  
  love.graphics.setDefaultFilter("nearest", "nearest", 1)
  love.graphics.setLineStyle("rough")
  
  --Load a new font and set it as the current one:
    fontSize = 16
    love.graphics.setFont(love.graphics.newFont("m5x7.ttf", fontSize))
  
  --Set windows size accordingly to upscalingFactor: 
    love.window.setMode(screenWidth * upscalingFactor,
                        screenHeight * upscalingFactor)
                      
  --Create Canvas so I can draw everything on it and then upscale it as 
  --I want to. Then set filter to nearest:
    canvas = love.graphics.newCanvas(screenWidth, screenHeight)
    --canvas:setFilter("nearest", "nearest")
  
  --  Register Gamestate Events and switch to the firtst one:
    Gamestate.registerEvents()
    Gamestate.switch(menu)
end

--Callback function triggered when a key is pressed:
function love.keypressed(key)
  if key == "q" and love.keyboard.isDown("lctrl") then
    love.event.quit()
  end
  if (key == "l" or key == "f") and love.keyboard.isDown("lctrl") then 
    if fillOrLine == "line" then
      fillOrLine = "fill"
    else
      fillOrLine = "line"
    end
  end
end