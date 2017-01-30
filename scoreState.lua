--HIGH SCORE GAMESTATE CALLBACKS:

local text
local playerHasHighScore
local playerScoreSave
local time = 0
local awesomePlay = false
function score:enter(from, playerScore) 
  if playerScore then 
    --Does the player gets to put his name on the table?
    playerHasHighScore = false
    for i, score, name in highscore() do
      if playerScore > score then
        playerHasHighScore = true
        text = ""
        playerScoreSave = playerScore
        time = 0
        if i == 1 then --If the player score is bigger than the first position.
          awesomePlay = true
        else
          awesomePlay = false
        end
        break
      end
    end
  end
end

function love.update(dt)
  time = time + dt
end

function love.textinput(t)
  if playerHasHighScore and time > 0.3 then
    text = text .. t
  end
end

function score:draw()
  setDrawTarget()  
  
  --DRAW EVERYTHING
  love.graphics.printf("HIGH-SCORES", 0, centerScreenY / 8, screenWidth / 3, "center", 0, 3, 3)
 
  local xtraX
  for i, score, name in highscore() do
    xtraX = math.sin(time * i) * 3
    
    local c = 255 - 255 / i
    love.graphics.printf({{c, c, 255},i .. " ... " .. name .. " ... " .. score .. " ... " .. i},
      0 + xtraX, i * 25 + centerScreenY / 4, screenWidth, "center")
  end
  
  if playerHasHighScore then
    --Draw where the player can enter his name:
    local width = 200
    local height = 20
    local x = centerScreenX - width / 2
    local y = centerScreenY + 190
    love.graphics.printf("Enter your name!", 0, y, screenWidth, "center")
    love.graphics.rectangle("line", x, y + 20, width, height)
    love.graphics.printf(text, 0, y + 22, screenWidth, "center")
    
    if awesomePlay then
      for i = 1, 3 do
      local pos = math.sin(time + i) * 20
      love.graphics.printf({{10, 255 / i, 10},"YOU ARE THE BEST!!!"},
        xtraX, centerScreenY - 50 + pos, screenWidth / 4, "center", 0, 4, 4)
      end
    end
  end
                        
  backToScreenAndUpscale()
end

function score:keypressed(key)
  if key == "backspace" and playerHasHighScore then
    text = "" 
  elseif key == "return" and playerHasHighScore then
    playerHasHighScore = false
    highscore.add(text, math.ceil(playerScoreSave))
    highscore.save()
  elseif not playerHasHighScore then
    Gamestate.switch(menu)
  end
end