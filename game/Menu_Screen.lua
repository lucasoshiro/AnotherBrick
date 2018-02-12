Menu_Screen = {}
local suitLib = require 'suit'
local suit = nil
local title = love.graphics.newText (ifFontLarge, "Another Brick")

local my = H/2 + H/17 + H/32
local hy = H/2 + 2*(H/17 + H/32)

local music = nil
local chk = nil

function Menu_Screen.load (params)
   --love.graphics.setBackgroundColor(30, 58, 94, 0)
   love.graphics.setBackgroundColor(19, 25, 38, 0)
   music = {}
   music.background = love.audio.newSource("Assets/sounds/midnight.mp3")
   music.background:setLooping(true)
   if sound then music.background:play() end
   music.background:setVolume(0.5)
   suit = suitLib.new()
   chk = {checked = sound, text = "Sounds"}
end

function Menu_Screen.back ()
   love.event.quit ()
end

function Menu_Screen.draw ()
   love.graphics.setColor (150, 255, 230, 255)
   love.graphics.setFont(ifFontLarge)

   love.graphics.draw (title, (W - title:getWidth())/2, H/2 - (H*2)/7)

   love.graphics.setFont(ifFontSmall)
   suit:draw()
end

function  Menu_Screen.update (dt)
   if suit:Button("easy", W/6, H/2, (2*W)/3, H/17).hit then
      ScreenManager.changeTo("Game_Screen", "easy")
      return
   end
   if suit:Button("medium", W/6, my, (2*W)/3, H/17).hit then
      ScreenManager.changeTo("Game_Screen", "medium")
      return
   end
   if suit:Button("hard", W/6, hy, (2*W)/3, H/17).hit then
      ScreenManager.changeTo("Game_Screen", "hard")
      return
   end

   if suit:Checkbox(chk, W/4, H - (2*H)/10, W/2, H/17).hit then
      sound = not sound
      if sound then music.background:play ()
      else music.background:pause () end
   end

   if suit:Button("Credits", W/4, H - (2*H)/17, W/2, H/17).hit then
      ScreenManager.changeTo("Credits_Screen")
      return
   end
end

function Menu_Screen.finish ()
   music.background:stop ()
   music = nil
   suit = nil
end

return Menu_Screen
