--HIGH SCORE GAMESTATE CALLBACKS:
--local music = love.audio.newSource("sounds/girl_from_mars.xm")
function score:enter(from, playerScore) 
  --music:play()
  local name = "Player"
  if playerScore then 
    highscore.add(name, math.ceil(playerScore))
    highscore.save()
  end
end

function score:draw()
  setDrawTarget()  
  --DRAW EVERYTHING
      love.graphics.printf("HIGH-SCORES", 0, centerScreenY / 8, screenWidth, "center")
    --Print Atribution to the guy who made the song:
      --love.graphics.print("Song: Girl From Mars by Drozerix (https://soundcloud.com/drozerix)",
                          --fontSize/2, screenHeight - fontSize)
                        
  for i, score, name in highscore() do
    local c = 255 - 255 / i
    love.graphics.printf({{c, c, 255},i .. " ... " .. name .. " ... " .. score .. " ... " .. i},
      0, i * 25 + centerScreenY / 4, screenWidth, "center")
  end
                        
  backToScreenAndUpscale()
end

function score:keypressed(key)
  Gamestate.switch(menu)
  --music:stop()
end