import "minigames/minigame"
import "elements/randomText"
import "minigames/conflict/samurai"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Conflict').extends('Minigame')

local backgroundImage = gfx.image.new("images/Conflict_Minigame/temple")
local background = gfx.sprite.new(backgroundImage)

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
    self.samurai = Samurai()

    --BACKGROUND
    self.background = background
    self.background:add()
    self.background:setZIndex(1)
    self.background:moveTo(centerPoint)
end

function Conflict:update()
    self.samurai:update()
end