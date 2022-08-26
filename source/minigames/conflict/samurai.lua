import "minigames/minigame"
import "elements/AnimatedSprite"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Samurai').extends()

local backgroundImage = gfx.image.new("images/Conflict_Minigame/temple")
local background = gfx.sprite.new(backgroundImage)

--init samurai imagetables
--idles
local idle_stow = gfx.imagetable.new("images/Conflict_Minigame/Samurai/idle_stow")
local idle_up = gfx.imagetable.new("images/Conflict_Minigame/Samurai/idle_up")
local idle_down = gfx.imagetable.new("images/Conflict_Minigame/Samurai/idle_down")
--walkingforward
local walking_stow = gfx.imagetable.new("images/Conflict_Minigame/Samurai/walking_stow")
local walking_up = gfx.imagetable.new("images/Conflict_Minigame/Samurai/walking_up")
local walking_down = gfx.imagetable.new("images/Conflict_Minigame/Samurai/walking_down")
--walkingback
local back_stow = gfx.imagetable.new("images/Conflict_Minigame/Samurai/back_stow")
local back_up = gfx.imagetable.new("images/Conflict_Minigame/Samurai/back_up")
local back_down = gfx.imagetable.new("images/Conflict_Minigame/Samurai/back_down")
--attacking
local attack_up = gfx.imagetable.new("images/Conflict_Minigame/Samurai/attack_up")
local attack_down = gfx.imagetable.new("images/Conflict_Minigame/Samurai/attack_down")
--stowing/drawing
local stowing = gfx.imagetable.new("images/Conflict_Minigame/Samurai/stowing")
local drawing = gfx.imagetable.new("images/Conflict_Minigame/Samurai/drawing")
--dash
local dash = gfx.imagetable.new("images/Conflict_Minigame/Samurai/dash")
--blocking
local block_up = gfx.imagetable.new("images/Conflict_Minigame/Samurai/block_up")
local block_down = gfx.imagetable.new("images/Conflict_Minigame/Samurai/block_down")

local offset = 64
local floor = 50


function Samurai:init()

    --SPRITES
    self.samurai = AnimatedSprite(idle_stow)
    self.samurai:add()
    self.samurai:setZIndex(2)
    self.samurai:moveTo(centerX + offset, 240 - floor)

    --BOOLEANS: used to determine status
    self.moving = false
    self.attacking = false
    self.blocking = false
    self.dashing = false

    --MOVEMENT: speed, velocity and accel/deccel
    self.velocity = 0
    self.maxVelocity = 2
    self.startVelocity = 1
    self.acceleration = 0.3
    self.dashTimer = pd.timer.new(0)

    --PLAYER INPUT
    --CRANK
    self.stowed = pd.isCrankDocked()
    self.crank = pd.getCrankPosition()
    --INPUT HANDLER: 
    self.conflictInputHandler = {
        --ATTACKING, dependent on stance, up or down
        upButtonDown = function()
            local substance = string.sub(self.stance, #self.stance - 1, #self.stance)
            if substance == "wn" and self.blocking == false then
                if self.attacking == false then
                    self.attacking = true
                    self.moving = false
                    self.stance = "attacking down"
                    self.samurai:setAnimation(attack_down, 75, 1)
                end
            elseif substance == "up" and self.blocking == false then
                if self.attacking == false then
                    self.attacking = true
                    self.moving = false
                    self.stance = "attacking up"
                    self.samurai:setAnimation(attack_up, 75, 1)
                end
            else
                self.attacking = false
            end
        end,
        --BLOCKING: dependent on stance, up or down
        downButtonDown = function()
            if self.stowed == false then
                local substance = string.sub(self.stance, #self.stance - 1, #self.stance)
                if substance == "wn" then
                    if self.blocking == false then
                        self.blocking = true
                        self.moving = false
                        self.stance = "blocking down"
                        self.samurai:setAnimation(block_down, 125)
                    end
                elseif substance == "up" then
                    if self.blocking == false then
                        self.blocking = true
                        self.moving = false
                        self.stance = "blocking up"
                        self.samurai:setAnimation(block_up, 125)
                    end
                end
            end
        end,
        --MANIPULATING BOOLEANS 
        downButtonUp = function()
          self.blocking = false
        end,
        leftButtonDown = function()
            self.moving = true
        end,
        leftButtonUp = function()
            self.moving = false
        end,
        rightButtonDown = function()
            if self.dashTimer.timeLeft > 0 and self.stowed == true then
                self.velocity = 6
                self.dashing = true
                self.moving = false
                self.stance = "dash"
                self.samurai:setAnimation(dash, 75, 1)
            elseif self.dashTimer.timeLeft == 0 then
                self.dashTimer = pd.timer.new(150)
            end
            
        end,
        rightButtonUp = function()
            self.moving = false
        end,
    }
    pd.inputHandlers.push(self.conflictInputHandler)
end

function Samurai:animateStances(stance1, anim1, stance2, anim2, stance3, anim3)
    if self.stowed and self.blocking == false then
        if self.stance ~= stance1 then
            self.samurai:setAnimation(anim1)
            self.stance = stance1 
        end
    elseif self.crank >= 90 and self.crank <= 270 then
        if self.stance ~= stance2 then
            self.samurai:setAnimation(anim2)
            self.stance = stance2
        end
    else
        if self.stance ~= stance3 then
            self.samurai:setAnimation(anim3)
            self.stance = stance3
        end
    end
end

--velocity handler, moving character
function Samurai:handleVelocity()
    if self.dashing == false then
        if self.velocity > self.maxVelocity then
            self.velocity = self.maxVelocity
        elseif self.velocity < -self.maxVelocity then
            self.velocity = -self.maxVelocity
        end
    end
    self.samurai:moveBy(self.velocity, 0)
end

--friction handler, decreasing velocity if no input
function Samurai:handleFriction()
    if self.velocity > 0 then
        self.velocity -= self.acceleration
    elseif self.velocity < 0 then
        self.velocity += self.acceleration
    end
    if math.abs(self.velocity) < 0.5 then
        self.velocity = 0
    end
end

function Samurai:update()
    print(self.stance)
    --stowing and drawing animation when docking and undocking
    if self.stowed == true and pd.isCrankDocked() == false then
        if self.attacking == false then
            self.attacking = true
            self.moving = false
            self.samurai:setAnimation(drawing, 50, 1)
        end
    elseif self.stowed == false and pd.isCrankDocked() == true then
        if self.attacking == false then
            self.attacking = true
            self.moving = false
            self.samurai:setAnimation(stowing, 50, 1)
        end
    end

    self.stowed = pd.isCrankDocked()
    self.crank = pd.getCrankPosition()

    --movement with stances
    if self.attacking == false and self.blocking == false and self.dashing == false then
        if pd.buttonIsPressed(pd.kButtonLeft) then
            if self.velocity > 0 then
                self.velocity = 0
            elseif self.velocity <= 0 then
                self.velocity -= self.acceleration
                self:animateStances("forward stow", walking_stow, "forward down", walking_down, "forward up", walking_up)
            end
        elseif pd.buttonIsPressed(pd.kButtonRight) then
            if self.velocity < 0 then
                self.velocity = 0
            elseif self.velocity >= 0 then
                self.velocity += self.acceleration
                self:animateStances("back stow", back_stow, "back down", back_down, "back up", back_up)
            end
        else
            self:handleFriction()
            if self.velocity < 0.5 or self.velocity > -0.5 then
                self:animateStances("idle stow", idle_stow, "idle down", idle_down, "idle up", idle_up)
            end
        end
    elseif self.samurai:hasEnded() and self.attacking == true then
        self.attacking = false
    elseif self.samurai:hasEnded() and self.dashing == true then
        self.dashing = false
    else
        self:handleFriction()
    end
    self:handleVelocity()
end