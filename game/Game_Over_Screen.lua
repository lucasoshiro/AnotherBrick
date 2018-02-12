Game_Over_Screen = {}

local suitLib = require 'suit'
local gameStats = nil

function Game_Over_Screen.load (params)
    gameStats = params
    love.graphics.setBackgroundColor(19, 25, 38, 0)
    suit = suitLib.new()
end

function Game_Over_Screen.draw ()
  love.graphics.setColor (255, 255, 255, 255)
  love.graphics.setFont (ifFontLarge)
  love.graphics.printf ("Game Over!", 0, H/2 - H/3, W, "center")
  love.graphics.setFont (ifFontSmall)
  love.graphics.printf ("You scored ".. gameStats.score, 0, H/2 - H/6, W, "center")
  love.graphics.printf ("And got to level " .. gameStats.level, 0, H/2 - H/8, W, "center")
  suit:draw()
end

function  Game_Over_Screen.update (dt)
  if suit:Button("Return to menu", W/6, H/2, (2*W)/3, H/17).hit then
      ScreenManager.changeTo ("Menu_Screen")
      return
  end
  if suit:Button("Play again", W/6,  H/2 + H/17 + H/32, (2*W)/3, H/17).hit then
      ScreenManager.changeTo ("Game_Screen", gameStats.mode)
      return
  end
end

function Game_Over_Screen.finish ()
    suit = nil
end


return Game_Over_Screen
