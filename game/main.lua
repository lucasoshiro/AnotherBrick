function love.load()
   love.window.setMode(400, 700)
   love.window.setTitle 'AnotherBrick'
   love.window.setIcon(love.image.newImageData "Assets/images/icon.png")
   W, H = love.graphics.getDimensions()
   ifFontLarge = love.graphics.newFont("Assets/Font/IndieFlower/IndieFlower.ttf", W/6)
   ifFontSmall = love.graphics.newFont("Assets/Font/IndieFlower/IndieFlower.ttf", W/11)
   ifFontVerySmall = love.graphics.newFont("Assets/Font/IndieFlower/IndieFlower.ttf", W/22)
   ifFontTiny = love.graphics.newFont("Assets/Font/IndieFlower/IndieFlower.ttf", W/25)
   sound = true

   ScreenManager = require 'ScreenManager'
   math.randomseed(os.time())
   math.random() -- descarta o primeiro valor aleatório
   ScreenManager.changeTo 'Menu_Screen'
end
