-- Compat functions for older love versions

function setColor(r, g, b, a)
   return love.graphics.setColor(r / 255, g / 255, b / 255, a / 255)
end

function setBackgroundColor(r, g, b, a)
   return love.graphics.setBackgroundColor(r / 255, g / 255, b / 255, a / 255)
end
