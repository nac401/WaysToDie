import "minigames/minigame"
import "elements/randomText"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Conflict').extends('Minigame')

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

local offset = 64
local floor = 50


function Conflict:init(difficulty, endings, hearts, enemyHearts)
    Conflict.super.init(self)
    --BASICS: set difficulty and other core variables
    self.difficulty = difficulty
    self.endings = endings

    --DIFFICULTY: set difficulty, including set modifiers
    if self.difficulty <= 1 then
        self.hearts = 2
        self.enemyHearts = 2
	elseif self.difficulty == 2 then
        self.hearts = 2
        self.enemyHearts = 2
	elseif self.difficulty >= 3 then
        self.hearts = 1
        self.enemyHearts = 2
	end
    --change variables if specific modifiers are present in init
    if hearts ~= nil then
        self.hearts = hearts
    end
    if enemyHearts ~= nil then
        self.enemyHearts = enemyHearts
    end

    --SPRITES
    self.samurai = AnimatedSprite(idle_stow)
    self.samurai:add()
    self.samurai:setZIndex(2)
    self.samurai:moveTo(centerX + offset, 240 - floor)

    --BACKGROUND
    self.background = background
    self.background:add()
    self.background:setZIndex(1)
    self.background:moveTo(centerPoint)

    --CRANK
    self.stowed = pd.isCrankDocked()
    self.crank = pd.getCrankPosition()

    --BOOLEANS: used to determine status
    self.moving = false
    self.attacking = false

    --INPUT HANDLER: 
    self.conflictInputHandler = {
        upButtonDown = function()
            local substance = string.sub(self.stance, #self.stance - 1, #self.stance)
            if substance == "wn" then
                if self.attacking == false then
                    self.attacking = true
                    self.moving = false
                    self.samurai:setAnimation(attack_down, 100, 1)
                end
            elseif substance == "up" then
                if self.attacking == false then
                    self.attacking = true
                    self.moving = false
                    self.samurai:setAnimation(attack_up, 100, 1)
                end
            else
                self.attacking = false
            end
        end,
        leftButtonDown = function()
            self.moving = true
        end,
        leftButtonUp = function()
            self.moving = false
        end,

        rightButtonDown = function()
            self.moving = true
        end,
        rightButtonUp = function()
            self.moving = false
        end,
    }
    pd.inputHandlers.push(self.conflictInputHandler)
end

function Conflict:animateStances(stance1, anim1, stance2, anim2, stance3, anim3, speed)
    
    if self.stowed then
        if self.stance ~= stance1 then
            if speed ~= nil and self.moving == true then 
                self.samurai:setAnimation(anim1, speed)
            else 
                self.samurai:setAnimation(anim1)
            end
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

function Conflict:update()
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
    if self.attacking == false then
        if pd.buttonIsPressed(pd.kButtonLeft) then
            if self.stance == "forward stow" then
                self.samurai:moveBy(-2, 0)
            else
                self.samurai:moveBy(-1, 0)
            end
            self:animateStances("forward stow", walking_stow, "forward down", walking_down, "forward up", walking_up, 50)
        elseif pd.buttonIsPressed(pd.kButtonRight) then
            if self.stance == "back stow" then
                self.samurai:moveBy(2, 0)
            else
                self.samurai:moveBy(1, 0)
            end
            self:animateStances("back stow", back_stow, "back down", back_down, "back up", back_up, 50)
        else
            self:animateStances("idle stow", idle_stow, "idle down", idle_down, "idle up", idle_up)
        end
    elseif self.samurai:hasEnded() and self.attacking == true then
        self.stance = "transition"
        self.attacking = false
    end
end