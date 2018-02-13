local suitLib = require 'suit'
local suit = nil
local title = love.graphics.newText(ifFontLarge, "Another Brick")

local titley = H/20

local ey = 5  * H/20
local my = 7  * H/20
local hy = 9  * H/20
local iy = 11 * H/20

local buttonh = H/17
local buttonw = (2*W)/3
local buttonx = W/6

local music = nil
local chk = nil

local modeButtons = {
   easy   = {y = 5  * H/20},
   medium = {y = 7  * H/20},
   hard   = {y = 9  * H/20},
   insane = {y = 11 * H/20},
}

Menu_Screen = {
   load = function(params)
      love.graphics.setBackgroundColor(19, 25, 38, 0)
      music = {}
      music.background = love.audio.newSource "Assets/sounds/midnight.mp3"
      music.background:setLooping(true)
      if sound then music.background:play() end
      music.background:setVolume(0.5)
      suit = suitLib.new()
      chk = {checked = sound, text = "Sounds"}
   end,

   back = function()
      love.event.quit ()
   end,

   draw = function ()
      love.graphics.setColor (150, 255, 230, 255)
      love.graphics.setFont(ifFontLarge)

      love.graphics.draw (title, (W - title:getWidth())/2, titley)

      love.graphics.setFont(ifFontSmall)
      suit:draw()
   end,

   update = function(dt)
      for mode, button in pairs(modeButtons) do
         if suit:Button(mode, buttonx, button.y, buttonw, buttonh).hit then
            ScreenManager.changeTo("Game_Screen", mode)
            return
         end
      end

      if suit:Checkbox(chk, W/4, H - (2*H)/10, W/2, buttonh).hit then
         sound = not sound
         if sound then music.background:play ()
         else music.background:pause () end
      end

      if suit:Button("Credits", buttonx, H - (2*H)/17, buttonw, buttonh).hit then
         ScreenManager.changeTo("Credits_Screen")
         return
      end
   end,

   finish = function()
      music.background:stop ()
      music = nil
      suit = nil
   end
}

return Menu_Screen
