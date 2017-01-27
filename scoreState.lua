--HIGH SCORE GAMESTATE CALLBACKS:
local music = love.audio.newSource("sounds/girl_from_mars.xm")
function score:enter(dt) 
  music:play()
end

function score:draw()
  setDrawTarget()  
  --DRAW EVERYTHING
      love.graphics.print("HIGH SCORES", 20, 20)
    --Print Atribution to the guy who made the song:
      love.graphics.print("Song: Girl From Mars by Drozerix (https://soundcloud.com/drozerix)",
                          fontSize/2, screenHeight - fontSize)
  backToScreenAndUpscale()
end

function score:keypressed(key)
  Gamestate.switch(menu)
  music:stop()
end