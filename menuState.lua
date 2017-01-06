--MENU GAMESTATE CALLBACKS:
  local time = 0
function menu:update(dt)
  time = dt + time          --time in seconds since the start of the program.
end

function menu:draw()
  setDrawTarget()  
  --DRAW EVERYTHING
    --Print time on screen:
      love.graphics.print(time)  
      love.graphics.print("This is the menu. Press any key.", 20, 20)
    --Print Atribution to the guy who made the font:
      love.graphics.print("Font m5x7: Daniel Linssen (managore.itch.io)",
                          fontSize/2, screenHeight - fontSize)
  backToScreenAndUpscale()
end

function menu:keyreleased(key)
  if key == "h" then
    Gamestate.switch(score)
  else
    Gamestate.switch(play)
  end
end
