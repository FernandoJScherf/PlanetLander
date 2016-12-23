--PLAY GAMESTATE CALLBACKS:
local circleRadius = 9
local circleCenterX = love.graphics.getWidth()/2
local circleCenterY = love.graphics.getHeight()/2

function play:init()
  ship = Ship(math.random(20, 60), math.random(10, 50))
end

function play:update(dt)
  ship:update(dt)
end

function play:draw(dt)
  setDrawTarget()  
  
  --DRAW EVERYTHING
    love.graphics.print("You are playing now!!!")
    love.graphics.circle("fill", circleCenterX, circleCenterY, circleRadius)
    
    ship:draw()
    
  backToScreenAndUpscale()
end