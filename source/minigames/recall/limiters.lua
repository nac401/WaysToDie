import "minigames/recall/rod"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--init limiter sprites
local maxLimiterImage = gfx.image.new("images/Recall_Minigame/maxLimiter")
local minLimiterImage = gfx.image.new("images/Recall_Minigame/minLimiter")

class('Limiters').extends()

function Limiters:init(difficulty)
	--LIMITERS: init limiters and their variables
	--set difficulty
	self.difficulty = difficulty

	--DIFFICULTY: set zone size and time between movements
	if self.difficulty <= 1 then
		self.zoneDifficulty = 45
		self.timeDifficulty = 600
	elseif self.difficulty == 2 then
		self.zoneDifficulty = 40
		self.timeDifficulty = 500
	elseif self.difficulty >= 3 then
		self.zoneDifficulty = 30
		self.timeDifficulty = 400
	end

	--initialize the good zone
	self.goodZoneMin = centerX - self.zoneDifficulty
	self.goodZoneMax = centerX + self.zoneDifficulty
	--initialize limiters
	self.minLimiter = gfx.sprite.new(minLimiterImage)
	self.maxLimiter = gfx.sprite.new(maxLimiterImage)
	self.minLimiter:moveTo(self.goodZoneMin, splashY)
	self.maxLimiter:moveTo(self.goodZoneMax, splashY)
	self.minLimiter:setZIndex(8)
	self.maxLimiter:setZIndex(8)
	--limiter timer
	self.limiterTimer = pd.timer.new(1000)
	self.limiterTimer:pause()
	self.limiterAnimator = nil
end

function Limiters:add()
	self.minLimiter:add()
	self.maxLimiter:add()
	local randomTime = math.random(1000, 1500)
	self.limiterTimer = pd.timer.new(randomTime)
end

function Limiters:inGoodZone(x)
	if x > self.goodZoneMin and x < self.goodZoneMax then
		return true
	else
		return false
	end
end

function Limiters:move()
	if self.limiterTimer.timeLeft == 0 then
		local xMin = self.zoneDifficulty + 10
		local xMax = 250 - self.zoneDifficulty
		local randomLoc = math.random(xMin, xMax)
		local time1 = math.random(self.timeDifficulty, self.timeDifficulty*2)
		local time2 = math.random(self.timeDifficulty*2, self.timeDifficulty*2 + 500)
		self.limiterAnimator = gfx.animator.new(time1, self.goodZoneMin, randomLoc, pd.easingFunctions.outCubic)
		self.limiterTimer = pd.timer.new(time2)
	elseif self.limiterAnimator ~= nil then
		self.goodZoneMin = self.limiterAnimator:currentValue()
		self.goodZoneMax = self.limiterAnimator:currentValue() + self.zoneDifficulty*2
		self.minLimiter:moveTo(self.goodZoneMin, splashY)
		self.maxLimiter:moveTo(self.goodZoneMax, splashY)
	end
end

function Limiters:reset()
	self.goodZoneMin = centerX - self.zoneDifficulty
	self.goodZoneMax = centerX + self.zoneDifficulty
end

function Limiters:cleanUp()
	self.minLimiter:remove()
	self.maxLimiter:remove()
	self.limiterTimer:remove()
end