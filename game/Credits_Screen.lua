local title = love.graphics.newText(ifFontLarge, "Another Brick")
local compat = require 'compat'
local credits = [[
All in all it's just another brick breaker :)

Made by: 
Matheus Tavares Bernardino
Felipe Caetano Silva
Lucas Seiki Oshiro

Special thanks:
Matthias Richter - Suit library
SoundJay - background music
Martin Felis - love-android-sdl2
qubodup - Start Gamedev
Kimberly Geswein - IndieFlower font

]]

Credits_Screen = {
   load = function()
      love.graphics.setBackgroundColor(19, 25, 38, 0)
   end,

   draw = function()
      love.graphics.setColor(150, 255, 230, 255)
      love.graphics.setFont(ifFontLarge)
      love.graphics.draw(title, (W - title:getWidth())/2, H / 100)

      love.graphics.setColor(166, 167, 170, 255)
      love.graphics.setFont(ifFontVerySmall)
      love.graphics.printf(credits, 1*W/10, H/5, 8 * W / 10)
   end,

   back = function ()
      ScreenManager.changeTo 'Menu_Screen'
   end
}

return Credits_Screen
