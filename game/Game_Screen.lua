local suitLib = require 'suit'

local BrickCol = 10
local BrickRow = 9
local heartPic = love.graphics.newImage "Assets/images/heart.png"
local inc = {1, 5, 10}
local hardnessColor = {
   {R = 166, G = 167, B = 170},
   {R = 96,  G = 136, B = 158},
   {R = 40,  G = 76,  B = 115}
}
local hasCursor = love.mouse.hasCursor()

local BrickH
local suit, tid, mouseMoved, mode, level, newLevel, music, numBricks
local breaks, score, life

--------------------------------------------------------------------------------
--                              RANDOM FUNCTIONS                              --
--------------------------------------------------------------------------------

-- Devolve BrickCol + 1 posições que separam os tijolos em [0, W], sendo que o
-- índice 1 é 0 e o último índice é W.
function randomPositions()
   local positions = {}
   local aux = {}

   positions = {[1] = 0, [BrickCol + 1] = W}
   aux = {[0] = 1, [W] = BrickCol + 1}
   
   for k = 2, BrickCol do
      local x = math.floor(math.floor(math.random() * 19 + 1) * W / 20)
      while aux[x] do
         x = math.floor(math.floor(math.random() * 19 + 1) * W / 20)
      end

      positions[k] = x
      aux[x] = k
   end
   table.sort(positions)
   return positions
end

function randomHardness()
   local k = math.random()
   
   if mode == "easy" then
      if k < 4/5 then return 1
      else            return 2
      end

   elseif mode == "medium" then
      if     k < 6/10 then return 1
      elseif k < 9/10 then return 2
      else                 return 3
      end

   elseif mode == "hard" then
      if     k < 1/10 then return 1
      elseif k < 5/10 then return 2
      else                 return 3
      end

   elseif mode == "insane" then
      if     k < 1/100 then return 1
      elseif k < 1/50  then return 2
      else                  return 3
      end
   end
end

function randomPowerup()
   local k = math.random()

   if     k < 3 / (4 * BrickCol * BrickRow) then return 2
   elseif k < 1/40                          then return 3
   elseif k < 1/20                          then return 1
   end
   
   return -1
end

--------------------------------------------------------------------------------
--                               AUX FUNCTIONS                                --
--------------------------------------------------------------------------------

function detectFixtures(a, b)
   if a == objects.ball.fixture     then return a, b
   elseif b == objects.ball.fixture then return b, a
   end
end

--------------------------------------------------------------------------------
--                               DRAW FUNCTIONS                               --
--------------------------------------------------------------------------------

function drawBricks()
   for i = 2, BrickRow do
      for j = 2, BrickCol - 1 do
         local brick = objects.bricks[i][j]
         
         if (brick ~= nil) then
            local objHard = brick.hardness
            
            love.graphics.setColor(hardnessColor[objHard].R,
                                   hardnessColor[objHard].G,
                                   hardnessColor[objHard].B,
                                   255)

            if brick.powerup == 1  then love.graphics.setColor(255, 0, 0, 255)
            elseif brick.life == 1 then love.graphics.setColor(0, 255, 0, 255)
            elseif brick.nitro > 0 then love.graphics.setColor(100 + math.sin(gameTime * 8) * 100,
                                                               235, 255, 255)
            end

            love.graphics.polygon("fill",
                                  brick.body:getWorldPoints(brick.shape:getPoints()))
         end
      end
   end
end

function drawLine()
   love.graphics.setColor(166, 167, 170, 100)
   local a = 0
   local b = 8
   local dist = 8
   local dashs = W / dist
   for i = 1, dashs do
      love.graphics.line (a, (3*H)/5, b, (3*H)/5)
      a = a + 2 * dist
      b = a + dist
   end
end

function drawBreakScore()
   for i, brk in ipairs(breaks.elements) do
      love.graphics.setFont(ifFontTiny)
      love.graphics.setColor(252, 210, 9, brk.time * 6)
      love.graphics.print('+' .. brk.points, brk.x, brk.y - 40 + brk.time)
   end
end

function drawBorders()
   love.graphics.setColor(72, 160, 14, 0)

   for i, border in ipairs({ceil, leftWall, rightWall}) do
      love.graphics.polygon("fill",
                            objects[border].body
                               :getWorldPoints(objects[border].shape
                                                  :getPoints()))
   end
end

function drawBall()
   love.graphics.setColor((1 - objects.ball.nitro / 500) * 119
         + (objects.ball.nitro / 500) * (100 + math.sin(gameTime * 8) * 100),
      170 + 65 * objects.ball.nitro / 500,
      112 + 143 * objects.ball.nitro / 500,
      255)

   love.graphics.circle("fill",
                        objects.ball.body:getX(),
                        objects.ball.body:getY(),
                        objects.ball.shape:getRadius())
end

function drawPaddle()
   love.graphics.setColor(objects.paddle.timer / 500 * 49 + 206,
                          (1 - objects.paddle.timer / 500) * 206,
                          (1 - objects.paddle.timer / 500) * 206)
   
   love.graphics.circle("fill",
                        objects.paddle.body:getX(),
                        objects.paddle.body:getY(),
                        objects.paddle.shape:getRadius())
end

--------------------------------------------------------------------------------
--                              UPDATE FUNCTIONS                              --
--------------------------------------------------------------------------------

function updateSuit()
   local btColor = {
      normal  = {bg = {27, 162, 130, 180},  fg = {255, 255, 255}},
      hovered = {bg = {27, 162, 130, 120},  fg = {255, 255, 255}},
      active  = {bg = {255, 255, 255, 180}, fg = {255, 255, 255}}
   }

   local radi = math.sqrt(W*W+H*H)/40
   if suit:Button("||",
                  {
                     cornerRadius = radi,
                     color = btColor,
                     font = love.graphics.newFont (W*0.035)
                  },
                  W - W/8, H/30, 2*radi, 2*radi).hit then
      
      if not newLevel then gameIsPaused = not gameIsPaused end
   end
end

function updateMouse()
   if not hasCursor then return end
   if not mouseMoved then
      objects.paddle.body:setLinearVelocity(0, 0)
   end
   mouseMoved = false
end

function updatePaddlePowerups()
   if (objects.paddle.timer > 0) then
      objects.paddle.timer = objects.paddle.timer - 1
      if (objects.paddle.timer == 0) then
         objects.paddle.shape = love.physics.newCircleShape(W / 10)
         objects.paddle.fixture:getShape():setRadius(W / 10)
      end
   end

   if objects.ball.nitro > 0 then
      objects.ball.nitro = objects.ball.nitro - 1
      if objects.ball.nitro <= 0 then
         local diag = math.sqrt (W*W + H*H)
         limitBallVelocity(0.8 * diag, 0.8 * diag)
      end
   end
end

function updateBreaks()
   for i, x in ipairs(breaks.elements) do
      x.time = x.time - 1
      if x.time < 0 then breaks.remove(i) end
   end
end

function updateLife()
   if objects.ball.body:getY() > H then
      life.count = life.count - 1
      if life.count < 0 then
         onGameOver()
      else
         objects.ball.body:setPosition(W/3, H/2)
         local px,py = objects.paddle.body:getPosition()
         objects.ball.body:setLinearVelocity(px - W/3, py - H/2)
      end
   end
end

--------------------------------------------------------------------------------
--                               AUX FUNCTIONS                                --
--------------------------------------------------------------------------------

-- Limita a velocidade da bola entre minV e maxV. Para não limitar um desses
-- valores, substitua-o por nil.
function limitBallVelocity(minV, maxV)
   local vx, vy = objects.ball.fixture:getBody():getLinearVelocity()
   local v = math.sqrt(vx * vx + vy * vy)

   if minV and v < minV then
      local k = minV / v
      objects.ball.fixture:getBody():setLinearVelocity(k * vx, k * vy)
   elseif maxV and v > maxV then
      local k = maxV / v
      objects.ball.fixture:getBody():setLinearVelocity(k * vx, k * vy)
   end
end

--------------------------------------------------------------------------------
--                             END OF GAME EVENTS                             --
--------------------------------------------------------------------------------
function onGameOver()
   ScreenManager.changeTo("Game_Over_Screen",
                          {
                             mode = mode,
                             score = score.count,
                             level = level,
   })
end

function onWin()
   level = level + 1
   world:destroy()
   initWorld()
end

--------------------------------------------------------------------------------
--                              INIT FUNCTIONS                                --
--------------------------------------------------------------------------------

function initVars()
   suit       = nil
   tid        = nil
   mouseMoved = nil
   mode       = nil
   level      = nil
   newLevel   = nil
   music      = nil

   BrickH = H/(BrickRow*3)
   
   breaks = {
      elements = {},
      count = 0,
      
      insert = function(x)
         breaks.elements[#breaks.elements + 1] = x
      end,

      remove = function(i)
         table.remove(breaks.elements, i)
      end,
   }

   score = {
      count = 0,
      draw = function()
         love.graphics.setColor(252, 210, 9)
         love.graphics.setFont(ifFontSmall)
         love.graphics.print('Score', H/200 + W/22, H/200)
         love.graphics.print(score.count, H/200 + W/22, H/200 + W/11)
      end,
      
      increment = function(hardness)
         score.count = score.count + inc[hardness]
      end,
   }

   life = {
      count = 3,
      draw = function()
         love.graphics.setColor(119, 170, 112)
         for i = 1, life.count do
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.draw(heartPic,
                               H/200 + i * W/22,
                               H / 200 + W / 200 + 5 * W/22,
                               0,
                               W / (25 * 400),
                               W / (25 * 400))
         end
      end
   }

   world = love.physics.newWorld(0, 0, true)
   world:setCallbacks(beginContact, endContact)
   numBricks = (BrickCol - 2)*(BrickRow - 1)

   breaks.count = 0
   breaks.elements = {}
end

function initObjects()
   objects = {
      ceil = {
         body  = love.physics.newBody(world, W / 2, borderWidth / 2),
         shape = love.physics.newRectangleShape(W, borderWidth),
      },

      leftWall = {
         body  = love.physics.newBody(world, borderWidth / 2, H / 2),
         shape = love.physics.newRectangleShape(borderWidth, H),
      },

      rightWall = {
         body  = love.physics.newBody(world, W - borderWidth / 2, H / 2),
         shape = love.physics.newRectangleShape(borderWidth, H),
      },

      ball = {
         body  = love.physics.newBody(world, W/3, H/2, "dynamic"),
         shape = love.physics.newCircleShape(W / 30),
         nitro = 0,
      },

      paddle = {
         body  = love.physics.newBody(world, W/2, H - W/10, "dynamic"),
         shape = love.physics.newCircleShape(W / 10),
         timer = -1,
      }
   }

   for objname, object in pairs(objects) do
      object.fixture = love.physics.newFixture(object.body, object.shape)
   end

   objects.ball.body:setLinearVelocity(0,0)
end

function initBricks()
   objects.bricks = {}
   for i = 2, BrickRow do
      objects.bricks[i] = {}

      local positions = randomPositions()

      for j = 2, BrickCol - 1  do
         brickW = positions[j + 1] - positions[j]
         brickX = math.floor((positions[j + 1] + positions[j]) / 2)

         local powerupType = randomPowerup()

         objects.bricks[i][j] = {
            body     = love.physics.newBody(world, brickX, i*BrickH - BrickH/2),
            shape    = love.physics.newRectangleShape(brickW - 2, BrickH - 2),
            powerup  = (powerupType == 1) and 1   or 0,
            life     = (powerupType == 2) and 1   or 0,
            nitro    = (powerupType == 3) and 500 or 0,
            hardness = (powerupType > 0)  and 1   or randomHardness()
         }
         
         objects.bricks[i][j].fixture =
            love.physics.newFixture(objects.bricks[i][j].body,
                                    objects.bricks[i][j].shape)
         
      end
   end
end

function initWorld()
   initObjects()
   initBricks()
   newLevel = true
end

--------------------------------------------------------------------------------
--                            COLLISION FUNCTIONS                             --
--------------------------------------------------------------------------------

function brickContact(i, j)
   local brick = objects.bricks[i][j]
   
   if playfx then music.explosion:play() end
   
   score.increment(brick.hardness)
   life.count = life.count + brick.life
   
   breaks.insert {
      x      = brick.fixture:getBody():getX(),
      y      = brick.fixture:getBody():getY(),
      time   = 40,
      points = inc[brick.hardness]
   }

   if brick.hardness == 1 then
      brick.body:destroy()

      if (brick.powerup == 1) then
         objects.paddle.shape = love.physics.newCircleShape(W / 5)
         objects.paddle.fixture:getShape():setRadius(W / 5)
         objects.paddle.timer = 500
      end

      if (brick.nitro > 0) then
         objects.ball.nitro = brick.nitro
      end

      numBricks = numBricks - 1
      objects.bricks[i][j] = nil
   else
      brick.hardness = brick.hardness - 1;
   end
end

--------------------------------------------------------------------------------
--                            COLLISION CALLBACKS                             --
--------------------------------------------------------------------------------

function beginContact(a, b, coll)
   local ballFixture, otherFixture = detectFixtures(a, b)

   if ballFixture and otherFixture then
      coll:setRestitution(1.0)
      otherFixture:getBody():setLinearVelocity(0, 0)
      love.system.vibrate(0.02)

      for i = 2, BrickRow do
         for j = 2, BrickCol - 1 do
            local brick = objects.bricks[i][j]
            
            if brick and brick.fixture == otherFixture then
               brickContact(i, j)
            end
         end
      end
   end

   objects.paddle.oldPos = {
      x = objects.paddle.fixture:getBody():getX(),
      y = objects.paddle.fixture:getBody():getY()
   }
end

function endContact(a, b, coll)
   local ballFixture, otherFixture = detectFixtures(a, b)

   if ballFixture and otherFixture then
      coll:setRestitution(1.0)
      otherFixture:getBody():setLinearVelocity(0, 0)
      
      if otherFixture == objects.leftWall.fixture
      or otherFixture == objects.rightWall.fixture then
         local vx,vy = ballFixture:getBody():getLinearVelocity()
         if math.abs (vy) <= 0.15*W then
            ballFixture:getBody():setLinearVelocity(vx, (vy / math.abs(vy) * 0.15*W))
         end
      end

      local diag = math.sqrt(W*W + H*H)
      if objects.ball.nitro > 0 then limitBallVelocity(diag*1.3,   diag*1.3)
      elseif mode == "easy"     then limitBallVelocity(diag*0.372, diag*1.365)
      elseif mode == "medium"   then limitBallVelocity(diag*0.496, diag*1.488)
      elseif mode == "hard"     then limitBallVelocity(diag*0.744, diag*1.861)
      elseif mode == "insane"   then limitBallVelocity(diag*1.3,   nil)
      end
   end
end

--------------------------------------------------------------------------------
--                              INPUT FUNCTIONS                               --
--------------------------------------------------------------------------------

function move(x, y, dx, dy)
   if gameIsPaused or newLevel then return end
   local ajustedx = false
   local ajustedy = false
   local paddleRadius = objects.paddle.shape:getRadius()

   if y - paddleRadius <= (3*H)/5 then objects.paddle.body:setY((3*H)/5 + paddleRadius + 1); ajustedy = true
   elseif y >= H - borderWidth - 1 then objects.paddle.body:setY(H - borderWidth - 1); ajustedy = true
   elseif x <= borderWidth + 1 then objects.paddle.body:setX(borderWidth + 1); ajustedx = true
   elseif x >= W - borderWidth - 1 then objects.paddle.body:setX(W - borderWidth - 1); ajustedx = true
   end

   if not (ajustedx and ajustedy) then
      if ajustedx then objects.paddle.body:setY(y)
      elseif ajustedy then objects.paddle.body:setX(x)
      else objects.paddle.body:setPosition(x, y)
      end
   end
   objects.paddle.body:setLinearVelocity(dx/lastdt, dy/lastdt)
end

--------------------------------------------------------------------------------
--                               LOVE CALLBACKS                               --
--------------------------------------------------------------------------------

Game_Screen = {
   load = function(params)
      initVars()
      suit = suitLib.new()
      love.physics.setMeter(64)
      mode = params

      gameTime = 0
      score.count = 0
      level = 1
      gameIsPaused = false
      life.count = 3
      
      -- Music
      music = {
         background = love.audio.newSource "Assets/sounds/heart.mp3"
      }

      music.background:setLooping(true)
      if playmusic then music.background:play() end
      music.background:setVolume(0.5)

      -- Bomb Sound
      music.explosion = love.audio.newSource "Assets/sounds/puo.wav"

      borderWidth = 1

      initWorld()
      love.graphics.setBackgroundColor(19, 25, 38, 0)
      lastdt = 1
   end,

   back = function()
      ScreenManager.changeTo "Menu_Screen"
   end,

   draw = function()
      drawBricks()
      drawLine()
      drawBorders()
      drawBall()
      drawPaddle()
      drawBreakScore()
      
      score.draw()
      life.draw()
      suit:draw()

      if newLevel then
         love.graphics.setColor(255, 255, 255, 255)
         love.graphics.setFont(ifFontLarge)
         love.graphics.printf("Level " .. level, 0, H/2, W, "center")
         return
      end

      if gameIsPaused then
         love.graphics.setColor(255, 255, 255, 255)
         love.graphics.setFont(ifFontSmall)
         love.graphics.printf("Paused", 0, H/2, W, "center")
      end
   end,

   update = function(dt)
      if objects.paddle.oldPos then
         objects.paddle.fixture:getBody():setPosition(objects.paddle.oldPos.x,
                                                      objects.paddle.oldPos.y)
         objects.paddle.oldPos = nil
      end

      updateSuit()
      updateMouse()

      if gameIsPaused or newLevel then return end

      lastdt = dt
      gameTime = gameTime + dt
      world:update(dt)

      if #(love.touch.getTouches()) and #(love.touch.getTouches()) > 0 then
         objects.paddle.fixture:getBody():setLinearVelocity(0, 0)
      end

      updatePaddlePowerups()
      updateLife()

      if numBricks == 0 then onWin() end
      
      updateBreaks()
   end,

   touchpressed = function(id, x, y, dx, dy, pressure)
      if newLevel then
         newLevel = not newLevel
         local px,py = objects.paddle.body:getPosition ()
         objects.ball.body:setLinearVelocity(px - W/3, py - H/2)
      end
      if gameIsPaused then return end
      
      objects.paddle.body:setLinearVelocity(0, 0)
      
      local paddleRadius = objects.paddle.shape:getRadius()
      local paddleX, paddleY = objects.paddle.body:getPosition()
      local k = 2
      if x <= paddleX + k * paddleRadius and
         x >= paddleX - k * paddleRadius and
         y <= paddleY + k * paddleRadius and
         y >= paddleY - k * paddleRadius
      then
         tid = id
      end
   end,

   touchmoved = function(id, x, y, dx, dy, pressure)
      if id == tid then move(x, y, dx, dy)
      else objects.paddle.body:setLinearVelocity(0, 0)
      end
   end,

   mousepressed = function(x, y, button)
      if newLevel then
         newLevel = not newLevel
         local px,py = objects.paddle.body:getPosition ()
         objects.ball.body:setLinearVelocity(px - W/3, py - H/2)
      end
      if gameIsPaused then return end
   end,

   mousemoved = function(x, y, dx, dy, istouch)
      mouseMoved = true
      move(x, y, dx, dy)
   end,

   touchreleased = function(id, x, y, dx, dy, pressure)
      objects.paddle.body:setLinearVelocity(0, 0)
      if id == tid then tid = nil end
   end,

   finish = function()
      music.background:stop()
      music.explosion:stop()
      music = nil
      suit = nil
      world:destroy()
      world = nil
   end,

   focus = function(focus)
      if not focus then gameIsPaused = true end
   end,
}

return Game_Screen
