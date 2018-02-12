ScreenManager = {}

local cur_screen = nil;

function ScreenManager.changeTo (name, params)
    love.update = nil
    love.draw = nil
    love.focus = nil
    love.quit = nil
    love.touchmoved = nil
    love.touchpressed = nil
    love.touchreleased = nil
    love.keypressed = nil
    if cur_screen and cur_screen.finish then cur_screen.finish() end
    cur_screen = require (name)
    if cur_screen.load then cur_screen.load (params) end
    if cur_screen.quit then love.quit = cur_screen.quit end
    if cur_screen.focus then love.focus = cur_screen.focus end
    if cur_screen.update then love.update = cur_screen.update end
    if cur_screen.draw then love.draw = cur_screen.draw end
    if cur_screen.touchmoved then love.touchmoved = cur_screen.touchmoved end
    if cur_screen.touchpressed then love.touchpressed = cur_screen.touchpressed end
    if cur_screen.touchreleased then love.touchreleased = cur_screen.touchreleased end
    if cur_screen.back then 
        function love.keypressed (key)
            if key == "escape" then cur_screen.back () end
        end
    end
end

return ScreenManager
