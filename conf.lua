function love.conf(t)
  --change the default window size
  t.window.width = 256 
  t.window.height = 144 
  
  t.window.title = "Planet Lander"
  --t.window.borderless = true
  
  --don't load the next modules
    t.modules.image = false             -- Enable the image module (boolean)
    t.modules.joystick = false           -- Enable the joystick module (boolean)

    t.modules.math = false              -- Enable the math module (boolean)
    t.modules.mouse = false           -- Enable the mouse module (boolean)
    t.modules.physics = false            -- Enable the physics module (boolean)

    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = false             -- Enable the video module (boolean)

    t.modules.thread = false             -- Enable the thread module (boolean)
end