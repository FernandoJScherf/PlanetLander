--PLAY GAMESTATE CALLBACKS:
local circleRadius = 9

function play:init()
  ship = Ship(centerScreenX + 50, centerScreenY - 100,
         math.random(0, 255), math.random(0, 255), math.random(0, 255))
  ship2 = Ship(centerScreenX - 60, centerScreenY + 90,
         math.random(0, 255), math.random(0, 255), math.random(0, 255))
  ship3 = Ship(centerScreenX - 55, centerScreenY - 70,
         math.random(0, 255), math.random(0, 255), math.random(0, 255))
  ship4 = Ship(centerScreenX + 70, centerScreenY + 80,
         math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

function play:update(dt)
  ship:update(dt)
  ship2:update(dt)
  ship3:update(dt)
  ship4:update(dt)
end

function play:draw(dt)
  setDrawTarget()  
  
  --DRAW EVERYTHING
    love.graphics.print("You are playing now!!!")
    love.graphics.circle("fill", centerScreenX , centerScreenY, circleRadius)
    
    ship:draw()
    ship2:draw()
    ship3:draw()
    ship4:draw()
    
  backToScreenAndUpscale()
end