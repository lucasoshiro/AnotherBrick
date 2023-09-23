local suitLib = require 'suit'
local gameStats = nil
local compat = require 'compat'

Game_Over_Screen = {
   load = function(params)
      gameStats = params
      compat.setBackgroundColor(19, 25, 38, 0)
      suit = suitLib.new()
   end,

   draw = function()
      compat.setColor(255, 255, 255, 255)
      love.graphics.setFont(ifFontLarge)
      love.graphics.printf("Game Over!", 0, H/2 - H/3, W, "center")
      love.graphics.setFont(ifFontSmall)
      love.graphics.printf("You scored ".. gameStats.score, 0, H/2 - H/6, W, "center")
      love.graphics.printf("And got to level " .. gameStats.level, 0, H/2 - H/8, W, "center")
      suit:draw()
   end,

   update = function(dt)
      if suit:Button("Return to menu", W/6, H/2, (2*W)/3, H/17).hit then
         ScreenManager.changeTo("Menu_Screen")
         return
      end
      if suit:Button("Play again", W/6,  H/2 + H/17 + H/32, (2*W)/3, H/17).hit then
         ScreenManager.changeTo("Game_Screen", gameStats.mode)
         return
      end
   end,

   finish = function ()
      suit = nil
   end,
}

return Game_Over_Screen
