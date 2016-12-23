-- Main in 20/12/16 16:07 hs
function love.load()
  Object = require "classic"
  GameState = require "gamestate"
  
  
  time = 0
  upscalingFactor = 2
  screenWidth = love.graphics.getWidth() -- Should be 256
  screenHeight = love.graphics.getHeight() -- Should be 144
  
  --Load a new font and set it as the current one:
    fontSize = 16
    love.graphics.setFont(love.graphics.newFont("m5x7.ttf", fontSize))
  
  --Set windows size accordingly to upscalingFactor: 
    love.window.setMode(screenWidth * upscalingFactor,
                        screenHeight * upscalingFactor)
                      
  --Create Canvas so I can draw everything on it and then upscale it as 
  --I want to. Then set filter to nearest:
    canvas = love.graphics.newCanvas(256, 144)
    canvas:setFilter("nearest", "nearest")
end

function love.update(dt)
  time = dt + time          --time in seconds since the start of the program.
end

function love.draw()
  --Set the draw target to the canvas
  love.graphics.setCanvas(canvas)
  --Is necesary to clear the screen because the canvas will still have what
  --was draw on it during the past frame:
  love.graphics.clear()
  
  --DRAW EVERYTHING
    --Print time on screen:
      love.graphics.print(time)  
      love.graphics.print("Static text", 20, 20)
    --Print Atribution to the guy who made the font:
      love.graphics.print("Font m5x7: Daniel Linssen (managore.itch.io)",
                          fontSize/2, screenHeight - fontSize)
  --This sets the target back to the screen.
  --(Once you draw on the offscreen canvas, you have to draw the canvas
  --on the visible screen)
    love.graphics.setCanvas() 
  --DRAW UPSCALED CANVAS.
    love.graphics.draw(canvas, 0, 0, 0, upscalingFactor, upscalingFactor)
end

--Callback function triggered when a key is pressed:
function love.keypressed(key)
 if key == "escape" then
    love.event.quit()
 end
end