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

--walking
local walking_stow = gfx.imagetable.new("images/Conflict_Minigame/Samurai/walking_stow")
local walking_up = gfx.imagetable.new("images/Conflict_Minigame/Samurai/walking_up")
local walking_down = gfx.imagetable.new("images/Conflict_Minigame/Samurai/walking_down")


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
    self.samurai:moveTo(centerX - offset, 240 - floor)

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
    self.attacking= true

    --INPUT HANDLER
    self.conflictInputHandler = {

		upButtonDown = function()
			
		end,

        leftButtonDown = function()
			self.samurai:moveBy(-1, 0)
            self:animateStances(walking_stowed, walking_down, walking_up)
            self.moving = true
		end,
        leftButtonUp = function()
			self.moving = false
		end,


        rightButtonDown = function()
			self.samurai:moveBy(1, 0)
            self:animateStances(walking_stowed, walking_down, walking_up)
            self.moving = true
		end,
        rightButtonUp = function()
			self.moving = false
		end,
	}
    pd.inputHandlers.push(self.conflictInputHandler)
end

function Conflict:animateStances(stance1, stance2, stance3)
    if self.stowed then
        if self.stance ~= 1 then
            self.samurai:setAnimation(stance1)
            self.stance = 1 
        end
    else 
        if self.crank >= 90 and self.crank <= 270 then
            if self.stance ~= 2 then
                self.samurai:setAnimation(stance2)
                self.stance = 2
            end
        else
            if self.stance ~= 3 then
                self.samurai:setAnimation(stance3)
                self.stance = 3
            end
        end
    end
end



function Conflict:update()
    self.stowed = pd.isCrankDocked()
    self.crank = pd.getCrankPosition()

    if pd.


    self:animateStances(idle_stow, idle_down, idle_up)
end