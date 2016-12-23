function love.conf(t)
  --change the default window size
  t.window.width = 256 
  t.window.height = 144 
  --don't load the next modules
  t.modules.joystick = false
  t.modules.physics = false
  t.modules.video = false  
end