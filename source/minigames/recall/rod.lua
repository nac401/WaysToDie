import "minigames/recall/recall"
import "minigames/recall/fish"
import "minigames/recall/limiters"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--init rod variables
--splash coords
local rodPoint = pd.geometry.point.new(272, 57)
--interval for rod animation timer, in milliseconds
local rodInterval = 250
--how much intro graphics are offset (starting point to sail in)
local introOffset = 300
--boundaries
local boundaryMax = 250
local boundaryMin = 20

--global coordinate for the Y of the splash, limiters, etc.
splashY = 180

--init rod graphics
local rodCast_ImageTable = gfx.imagetable.new("images/Recall_Minigame/Rod/rod_cast")
local rodPull_ImageTable = gfx.imagetable.new("images/Recall_Minigame/Rod/rod_pulling")
local rodReelIn_ImageTable = gfx.imagetable.new("images/Recall_Minigame/Rod/rod_reelin")
local rodFailure_ImageTable = gfx.imagetable.new("images/Recall_Minigame/Rod/rod_failure")

--init sounds
local castSound 	= playdate.sound.sampleplayer.new("sounds/recall/cast")

class('Rod').extends()

function Rod:init(difficulty)
	Rod.super.init(self)
	
	--BASICS: difficulty and score
	self.difficulty = difficulty
	
	--SPRITES: animated and static sprities in regards to the rod
	--The Rod: the main sprite
	self.rod = AnimatedSprite(rodCast_ImageTable)
	--setup sprite
	--note: for some reason the animatedsprite without a loop 
	--doesn't function unless setFrame is called?
	self.rod:add()
	self.rod:setZIndex(10)
	self.rod:moveTo(centerX, centerY - introOffset)
	self.rod:pause()
	--The Line: only used when catching
	self.lineImage = gfx.image.new(400, 240)
	self.line = gfx.sprite.new(self.lineImage)
	self.line:setZIndex(11)
	self.line:moveTo(centerPoint)
	
	--CLASSES: initialize unique classes
	--Fish: handles fish stats/sprites/animations
	self.fish = Fish(self.difficulty)
	--Limiters: handles limiters, used when catching
	self.limiters = Limiters(self.difficulty)
	
	--TIMERS: for timing things
	--for fish pulling
	self.fishPullTimer = pd.timer.new(1000)
	self.fishPullTimer:pause()
	--and for rod animation
	self.rodTimer = pd.timer.new(rodInterval)
	self.rodTimer:pause()
	
	--STAGES: the stage booleans, used to determine where in the 
	--fishing process we are
	self.readyToCast = true
	self.reelingIn = false
	self.fishPulling = false
	self.nabbedFish = false
	
	--CRANK: crank it
	self.crank = 0
	self.crankIntensity = 4
	
	--ANIMATIONS: animations, including shaking
	--set transitioning to true for intro animation
	self.transitioning = true
	--init intro animators
	self.animator = gfx.animator.new(800, 0, introOffset, pd.easingFunctions.outBounce, 500)
	--init shaker if things gotta shake, they gotta shake
	self.shaker = nil
	
	--CONTROLS: singular input handler for press A to cast
	self.recallInputHandler = {
		--if ready to cast, cast out
		AButtonDown = function()
			if self.readyToCast then
				--set new fish timer
				local randomTime = math.random(3000, 10000)
				self.fishPullTimer = pd.timer.new(randomTime)
				self.rod:continue()
				--reset booleans
				self.readyToCast = false
				self.fishPulling = false
				self.nabbedFish = false
				--prep splash
				self.fish:setIdle()
				--castSound:setOffset(1)
				castSound:playAt(pd.sound.getCurrentTime() + 0.7)
			else
				--otherwise, shake the pole
				self.shaker = Shake(self.rod)
				self.shaker.shakeAmount = 3
			end
		end,
	}
end

function Rod:intro()
	if self.transitioning then
		self.rod:moveTo(centerX, centerY - introOffset + self.animator:currentValue())
		--end intro transition when final animator finishes
		if self.animator:ended() then
			self.transitioning = false
			pd.inputHandlers.push(self.recallInputHandler)
		end
	end
end

function Rod:casting()
	--STAGE 1: CASTING/REELING IN
	--if bait is in the water, begin reeling in
	if not self.readyToCast and self.rod.loop.frame >= 18 then
		self.fish:start()
		--set reel-in animation
		self.rod:setAnimation(rodReelIn_ImageTable)
		self.rod:pauseAtFrame(1)
		self.reelingIn = true
		--set fish timer
		local newRandomTime = math.random(3000, 10000)
		self.fishPullTimer = pd.timer.new(newRandomTime)
	--otherwise if reeled in completely, stop reeling in, set ready to cast
	elseif self.reelingIn == true and self.rod.loop.frame >= 15 then
		self.reelingIn = false
		self.readyToCast = true
		--reset fishPullTimer
		self.fishPullTimer = pd.timer.new(1)
		self.fishPullTimer:pause()
		--set rod animation to casting
		self.rod:setAnimation(rodCast_ImageTable)
		self.rod:pauseAtFrame(1)
	end
	--reel in with the crank
	if self.crank > 0 and self.reelingIn then
		if not self.fishPulling then
			--modify fish timer
			local currentTime = self.fishPullTimer.timeLeft
			local randomModifier = math.random(-1000, 500)
			if currentTime + randomModifier <= 500 then
				local newRandomTime = math.random(500, 1000)
				self.fishPullTimer = pd.timer.new(newRandomTime)
			else
				self.fishPullTimer = pd.timer.new(currentTime + randomModifier)
			end
		end
		--animate line and bob in
		local newFrame = self.rod.loop.frame + self.crank
		self.rod:pauseAtFrame(newFrame)
		--move splash or remove splash
		if self.rod.loop.frame == 13 then
			self.fish.splash:remove()
		else
			self.fish.splash:moveBy(self.crank*16, 0)
		end
	end
end

function Rod:baiting()
	--STAGE 2: BAITING FISH
	--if fish timer reaches zero, the fish pulls
	if self.fishPullTimer.timeLeft == 0 and self.fishPulling == false then
		self.fishPulling = true
		self.fish:pull()
	end
	--once the fish finishes pulling, the fish timer resets and the fish gets away
	if self.fishPulling == true and self.fish.splash.loopFinished then
		--reinit fish timer
		local randomTimer = math.random(5000, 10000)
		self.fishPullTimer = pd.timer.new(randomTimer)
		self.fish:setPulling()
		self.fishPulling = false
	end
	--if the fish is pulling and the player pulls, then we enter into 
	--the conflict with the fish: the tug of war
	if self.fishPulling == true and self.crank > 0 then
		--set crank intensity higher
		self.crankIntensity = 40
		--reset and pause fish timer
		self.fishPullTimer = pd.timer.new(1)
		self.fishPullTimer:pause()
		--init timers
		--first fish speed changing timer
		local randomTime = math.random(1000, 3000)
		self.fishSpeedChange = pd.timer.new(randomTime)
		--then the limiter timer
		randomTime = math.random(1000, 3000)
		self.limiterTimer = pd.timer.new(randomTime)
		--manipulate fish booleans
		self.nabbedFish = true 
		self.reelingIn = false
		self.fishPulling = false 
		--set splash
		self.fish:setIdle()
		self.fish.splash:pauseAtFrame(2)
		--set rod
		self.rod:setAnimation(rodPull_ImageTable, 333)
		self.rod:pauseAtFrame(1)
		--set line
		self.line:add()
		--add limiters
		self.limiters:add()
		--set rod animation timer
		self.rodTimer = pd.timer.new(rodInterval)
		--add point bar
		pointBar:add()
	end
end

function Rod:catching()
	--STAGE 3: CATCHING FISH
	if self.nabbedFish then
		--PART 0: MOVE THE LIMITERS
		self.limiters:move()
		
		--PART 1: get the fish speed
		self.fish:getSpeed()
		
		--PART 2: DETERMINE CRANK/ANIMATION
		if self.crank < 0 then
			self.crank = -1
		end
		--set variable for current speed at this frame
		local currentSpeed = self.crank - self.fish.speed
		--change animation at every interval
		if self.rodTimer.timeLeft == 0 then
			--set animation according to speed
			if currentSpeed < -4 or currentSpeed > 4 and self.crank > 0 then
				self.rod:pauseAtFrame(4)
			elseif currentSpeed > 2 and self.crank > 0 then
				self.rod:pauseAtFrame(3)
			elseif currentSpeed < -2 or currentSpeed > 2 and self.crank <= 0 then
				self.rod:pauseAtFrame(2)
			else
				self.rod:pauseAtFrame(1)
			end
			self.rodTimer = pd.timer.new(rodInterval)
		end
		
		--PART 3: MAKE LINE AND MOVE SPLASH
		--find coords for making line, and coords for splash
		local x1, y1 = self.fish.splash:getPosition()
		local x2, y2 = rodPoint:unpack()
		--ensure that current speed isn't moving the splash out of bounds
		if x1 + currentSpeed > boundaryMax then 
			self.fish.splash:moveTo(boundaryMax, splashY)
		elseif x1 + currentSpeed < boundaryMin then
			self.fish.splash:moveTo(boundaryMin, splashY)
		else
			--move the fish/splash
			self.fish.splash:moveBy(currentSpeed, 0)
		end
		--set line
		self.lineImage:clear(playdate.graphics.kColorClear)
		gfx.pushContext(self.lineImage)
			gfx.drawLine(x1, y1, x2, y2)
		gfx.popContext()
		self.line:setImage(self.lineImage)
		
		--PART 4: DETERMINE IF IN GOOD ZONE
		if self.limiters:inGoodZone(x1) then
			recall_score += 5
		else
			recall_score -= 6
		end
	end
end

function Rod:prepFinish()
	if recall_score >= 1000 then
		self.fish:caught()
	end
	--remove point bar
	pointBar:remove()
	--remove line
	self.line:remove()
	--remove limiters
	self.limiters:cleanUp()
	--reset splash
	self.fish:splashRemove()
	--set new rod animation
	self.rod:setAnimation(rodFailure_ImageTable, nil, 1)
	self.rod:continue()
	--break score
	recall_score = 500
	self.nabbedFish = false
end

function Rod:reel()
	self.crank = pd.getCrankTicks(self.crankIntensity)
	--perform checks on status
	self:casting()
	self:baiting()
	self:catching()
end

function Rod:reset()
	--reset limiters
	self.limiters:reset()
	--reset timers
	self.fishPullTimer = pd.timer.new(1000)
	self.fishPullTimer:pause()
	--and for rod animation
	self.rodTimer = pd.timer.new(rodInterval)
	self.rodTimer:pause()
	--reset all variables
	--reset rod
	self.rod:setAnimation(rodCast_ImageTable)
	self.rod:noLoop()
	self.rod:setFrame(1)
	self.rod:pause()
	--reset score
	recall_score = 500
	--fishing variables and
	self.readyToCast = true
	self.reelingIn = false
	self.fishPulling = false
	self.nabbedFish = false
	--reset crank intensity
	self.crankIntensity = 4
end

function Rod:doneAnimating()
	if self.rod.loopFinished then
		return true
	else
		return false
	end
end

function Rod:cleanUp()
	self.rod:remove()
	self.line:remove()
	self.fishPullTimer:remove()
	self.rodTimer:remove()
	self.fish:cleanUp()
	self.limiters:cleanUp()
end

function Rod:update()
	self:intro()
	self:reel()
	self.fish:update()
	if self.fish.timer ~= nil and self.fish.timer.timeLeft <= 0 then
		pd.inputHandlers.push(self.recallInputHandler)
	end
end