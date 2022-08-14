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
	--define good zone for fish catching
	self.zoneDifficulty = (10 - self.difficulty)*5
	self.goodZoneOffset = -50
	self.goodZoneMin = centerX - self.zoneDifficulty + self.goodZoneOffset
	self.goodZoneMax = centerX + self.zoneDifficulty + self.goodZoneOffset
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
		local time1 = math.random(500, 1000)
		local time2 = math.random(1000, 1500)
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
	self.goodZoneMin = centerX - self.zoneDifficulty + self.goodZoneOffset
	self.goodZoneMax = centerX + self.zoneDifficulty + self.goodZoneOffset
end

function Limiters:cleanUp()
	self.minLimiter:remove()
	self.maxLimiter:remove()
	self.limiterTimer:remove()
end