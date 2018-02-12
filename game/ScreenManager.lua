ScreenManager = {}

local cur_screen = nil;

love_methods = {
   'update',
   'draw',
   'focus',
   'quit',
   
   'touchmoved',
   'touchpressed',
   'touchreleased',

   'mousemoved',
   'mousepressed',
   
   'keypressed',
}

function ScreenManager.changeTo (name, params)
   for i, method in ipairs(love_methods) do
      love[method] = nil
   end
   
   if cur_screen and cur_screen.finish then cur_screen.finish() end
   cur_screen = require (name)

   if cur_screen.load then cur_screen.load (params) end
   
   for i, method in ipairs(love_methods) do
      print(method)
      if cur_screen[method] then
         love[method] = cur_screen[method]
      end
   end

   if cur_screen.back then 
      function love.keypressed (key)
         if key == "escape" then cur_screen.back () end
      end
   end
end

return ScreenManager
