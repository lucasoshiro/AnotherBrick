local suitLib = require 'suit'

local title = love.graphics.newText(ifFontLarge, "Options")

local titley, buttonh, buttonw, buttonx

local compat = require 'compat'

local soundCheckBoxes = {
   fx    = {checked = playfx,
            text = "Sound FX",
            y = 5 * H/20,
            onclick = function()
               playfx = not playfx
            end
   },
   
   -- music = {checked = playmusic,
   --          text = "Music",
   --          y = 7 * H/20,
   --          onclick = function()
   --             playmusic = not playmusic
   --          end
   -- }
}

local screenSizeButtons = {
   small      = {y = 11 * H/20, ww = 400, wh = 700},
   medium     = {y = 13 * H/20, ww = 640, wh = 800},
   large      = {y = 15 * H/20, ww = 880, wh = 930},
   -- fullscreen = {y = 17 * H/20}
}

local returnButton = {
   y = 18 * H/20
}

local function setSizes()
   titley = H/20

   buttonh = H/17
   buttonw = (2*W)/3
   buttonx = W/6
end

Config_Screen = {
   load = function(params)
      setSizes()
      compat.setBackgroundColor(19, 25, 38, 0)
      suit = suitLib.new()
   end,
   
   back = function()
      ScreenManager.changeTo "Menu_Screen"
   end,

   draw = function()
      compat.setColor (150, 255, 230, 255)
      love.graphics.setFont(ifFontLarge)

      love.graphics.draw (title, (W - title:getWidth())/2, titley)

      love.graphics.setFont(ifFontSmall)
      suit:draw()
   end,

   update = function()
      for soundType, chbox in pairs(soundCheckBoxes) do
         if suit:Checkbox(chbox, W/4, chbox.y, W/2, buttonh).hit then
            chbox.onclick()
         end
      end

      if osName ~= 'Android' and osName ~= 'iOS' then
         for size, button in pairs(screenSizeButtons) do
            if suit:Button(size, buttonx, button.y, buttonw, buttonh).hit then
               resizeWindow(button.wh, button.ww)
               setSizes()
            end
         end
      end

      if suit:Button(size, buttonx, returnButton.y, buttonw, buttonh).hit then
         ScreenManager.changeTo "Menu_Screen"
      end
   end,
}

return Config_Screen
