--MENU GAMESTATE CALLBACKS:
local time = 0
local opt = {}
local atr = {}
local oldFont
local font
function menu:enter()
  opt = {"(1) Start", "(2) High-Scores", "(3) On/Off Fullscreen", "(9) Exit"}
  atr = {
    "   Attributions:",
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
  local scaler = 4
  local pos
  local limit = 3
  local colMult = 255 / limit

  --Print Options:
  for i = 1, #opt do
    love.graphics.printf(opt[i], 0, 115 + 20 * i, screenWidth, "center")
  end
  
  --Print Controls:
  love.graphics.printf("Controls:", 0, 230, screenWidth, "center")
  
  local function printRect(s1, s2, x, y)
    local width = 40
    x = x - width / 2
    love.graphics.rectangle("line", x, y, width, width)
    love.graphics.printf(s1, x, y + width / 2 - 8, width, "center")
    love.graphics.printf(s2, x - 20, y - width / 2, width + 40, "center")
  end
  
  love.graphics.setFont(newFont)
  
  --Print Title:
  for i = 1, limit do
    pos = math.sin(time + i) * 20
    love.graphics.printf({{colMult * i, colMult * i, 255}, "PLANET LANDER"} ,
      0, 40 + pos, screenWidth / scaler, "center", 0, scaler, scaler)
  end
  
  local qScreen = centerScreenX * 0.75
  printRect("W/UP", "Accelerate", qScreen, 270)
  printRect("A/LEFT", "Rotate", qScreen - 45, 320)
  printRect("D/RIGHT", "Rotate", qScreen + 45, 320)
  printRect("Z/M", "Shoot", centerScreenX * 1.25, 295)
  
  --Print Atributions:
  for i = 1, #atr do
    love.graphics.printf(atr[i], 0, 390 + 8 * i, screenWidth, "left")
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
  elseif key == "9" then    love.event.quit()
  end
end
