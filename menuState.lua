--MENU GAMESTATE CALLBACKS:
local time = 0
local opt = {}
local atr = {}
local oldFont
local font
function menu:enter()
  opt = {"(1) Start", "(2) High-Scores", "(3) On/Off Fullscreen",
    "(4) Increment Screen Scale", "(5) Decrement Screen Scale", "(9) Exit"}
  atr = {
    " > A Game by Fernando Jose Scherf:",
    "   (https://fernando-j-scherf.itch.io/)",
    " > Powered by the LOVE framework:",
    "   (https://love2d.org)",
    " > Fonts m5x7 and m3x6: Daniel Linssen", 
    "   (managore.itch.io)",
    " > hump - Helper Utilities for a Multitude of Problems: Matthias Richter",
    "   (https://github.com/vrld)",
    " > Classic - A tiny class module for Lua: rxi",
    "   (https://github.com/rxi/)",
    " > sfxr - A sound effect synthesizer/generator: Tomas Pettersson",
    "   (http://www.drpetter.se/)",
    " > sfxr.lua - A port of the sfxr sound effect synthesizer to Lua: nucular",
    "   (http://nucular.github.io/)",
    " > Special thanks to Daniël Haazen for his awesome 'How to (make games with) LOVE' tutorials:",
    "   (http://sheepolution.com)"
  }
  oldFont = love.graphics.getFont()
  newFont = love.graphics.newFont("m3x6.ttf", 16)
end

function menu:update(dt)
  --pos = math.sin(time) * 20--(math.sin(time) + 1) * 127
  time = time + dt * 2
  if time >= math.pi * 2 then time = 0 end
end

function menu:draw()
  setDrawTarget()  
  --DRAW EVERYTHING
  local scaler = 2
  local pos
  local limit = 3
  local colMult = 255 / limit

  --Print Options:
  for i = 1, #opt do
    love.graphics.printf(opt[i], 0, 105 + 16 * i, screenWidth, "center")
  end
  
  --Print Controls:
  love.graphics.printf("Controls:", 0, 225, screenWidth / scaler, "center", 0, scaler, scaler)
  
  love.graphics.setFont(newFont)
  
  scaler = 4
  --Print Title:
  for i = 1, limit do
    pos = math.sin(time + i) * 20
    love.graphics.printf({{colMult * i, colMult * i, 255}, "PLANET LANDER"} ,
      0, 30 + pos, screenWidth / scaler, "center", 0, scaler, scaler)
  end
  
  local function printRect(s1, s2, x, y)
    local width = 40
    x = x - width / 2
    love.graphics.rectangle("line", x, y, width, width)
    love.graphics.printf(s1, x, y + width / 2 - 8, width, "center")
    love.graphics.printf(s2, x - 20, y - width / 2, width + 40, "center")
  end
  
  local qScreen = centerScreenX * 0.75
  printRect("W/UP", "Accelerate", qScreen, 280)
  printRect("A/LEFT", "Rotate", qScreen - 45, 340)
  printRect("D/RIGHT", "Rotate", qScreen + 45, 340)
  printRect("Z/M", "Shoot", centerScreenX * 1.25, 305)
  
  love.graphics.printf("Ctrl + Q: Close game", 120, 390, screenWidth, "left")
  love.graphics.printf("P: Pause", 0, 390, screenWidth, "center")
  love.graphics.printf("Ctrl + L: Change graphic style", 0, 390, screenWidth - 120, "right")
  
  --Print Atributions:
  for i = 1, #atr do
    love.graphics.printf(atr[i], 0, 412 + 8 * i, screenWidth, "left")
  end

  love.graphics.setFont(oldFont)
  backToScreenAndUpscale()
end

function menu:keypressed(key)
  if key == "1" then        Gamestate.switch(loadS)
  elseif key == "2" then    Gamestate.switch(score)
  elseif key == "3" then    
    love.window.setFullscreen(not love.window.getFullscreen())
    if not love.window.getFullscreen() then 
        --Set windows size accordingly to upscalingFactor: 
        love.window.setMode(screenWidth * upscalingFactor,
                            screenHeight * upscalingFactor)
    end
  elseif key == "4" then
    upscalingFactor = upscalingFactor + 1
    love.window.setMode(screenWidth * upscalingFactor,
                        screenHeight * upscalingFactor)
  elseif key == "5" then
    if upscalingFactor > 1 then
      upscalingFactor = upscalingFactor - 1
      love.window.setMode(screenWidth * upscalingFactor,
                          screenHeight * upscalingFactor)
    end
  elseif key == "9" then    love.event.quit()
  end
end
