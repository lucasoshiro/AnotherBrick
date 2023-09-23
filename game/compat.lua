-- Compat functions for older love versions

return {
   setColor = function (r, g, b, a)
      a = a or 255
      return love.graphics.setColor(r / 255, g / 255, b / 255, a / 255)
   end,

   setBackgroundColor = function(r, g, b, a)
      a = a or 255
      return love.graphics.setBackgroundColor(r / 255, g / 255, b / 255, a / 255)
   end
}
