import "minigames/minigame"
import "elements/randomText"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

local lockBorder_image = gfx.image.new('images/Access_Minigame/lockBorder')
local lockTop_image = gfx.image.new('images/Access_Minigame/lockTop')
local lockBottom_image = gfx.image.new('images/Access_Minigame/lockBottom')
local bigPick_imageTable = gfx.imagetable.new('images/Access_Minigame/bigPick')

local pins_imageTable = gfx.imagetable.new('images/Access_Minigame/pinTracker')
local picks_imageTable = gfx.imagetable.new('images/Access_Minigame/pickTracker')

local lowClick = playdate.sound.sampleplayer.new("sounds/access/clickLow")
local highClick = playdate.sound.sampleplayer.new("sounds/access/clickHigh")

local breakSounds = {}
breakSounds[1] = playdate.sound.sampleplayer.new("sounds/access/break1")
breakSounds[2] = playdate.sound.sampleplayer.new("sounds/access/break2")
breakSounds[3] = playdate.sound.sampleplayer.new("sounds/access/break3")

local tensionSounds = {}
tensionSounds[1] = playdate.sound.sampleplayer.new("sounds/access/tension1")
tensionSounds[2] = playdate.sound.sampleplayer.new("sounds/access/tension2")
tensionSounds[3] = playdate.sound.sampleplayer.new("sounds/access/tension3")


local pickStart = 32
local pickMax = 42
local pickMin = 2
local pickLength = 80
local pickThick = 1

local random = 1

class('Access').extends('Minigame')

function Access:init(difficulty, endings, numPicks, numLocks)
	Access.super.init(self)
	--BASICS:  set difficulty and other core variables
	self.difficulty = difficulty
	
	self.currentLock = 1
	self.endings = endings

	--DIFFICULTY: determine difficulty
	if self.difficulty <= 1 then
		self.maxTension = 7
		self.progressGoal = 10
		self.numPicks = 2
		self.numLocks = 2
	elseif self.difficulty == 2 then
		self.maxTension = 5
		self.progressGoal = 15
		self.numPicks = 2
		self.numLocks = 3
	elseif self.difficulty >= 3 then
		self.maxTension = 3
		self.progressGoal = 15
		self.numPicks = 1
		self.numLocks = 3
	end
	if numPicks ~= nil then 
		self.numPicks = numPicks
	end
	if numLocks ~= nil then 
		self.numLocks = numLocks
	end

	--set key and crank (compared)
	self.key = math.random(-14, 45)
	self.bigKey = nil
	self.pickPos = 0
	
	self.pinLeeway = 3
	
	--TRACKERS: for picks (like hearts) and pins
	local sideOffset = (self.numPicks*16)/2 + 15
	self.pickTracker = Tracker(self.numPicks, picks_imageTable, 1, 0, nil, -sideOffset, nil)
	sideOffset = (self.numLocks*16)/2 + 15
	self.pinTracker = Tracker(self.numLocks, pins_imageTable, 1, 0, nil, sideOffset, nil)
	
	--CRANK: set crank variables
	self.crankAngle = pd.getCrankPosition()
	self.crankTicks = pd.getCrankTicks(120)
	self.prevAngle = 0
	self.curAngle = 0
	
	--SPRITES: init sprites and do setup
	--init big pick
	self.bigPick = AnimatedSprite(bigPick_imageTable)
		self.bigPick:pauseAtFrame(1)
		self.bigPick:moveTo(centerX, centerY + pickStart)
		self.bigPick:setZIndex(4)
		self.bigPick:add()
	--init small pick
	self.smallPick = gfx.sprite.new()
	self.smallPickImage = gfx.image.new((pickLength)*2, (pickLength)*2)
	pickThick = 2
	self:drawPick()
	self.smallPick:moveTo(centerX, centerY)
	self.smallPick:setZIndex(6)
	self.smallPick:add()
	--init border
	self.border = gfx.sprite.new(lockBorder_image)
		self.border:moveTo(centerX, centerY)
		self.border:setZIndex(2)
		self.border:add()
	--init background
	local backgroundImage = gfx.image.new(400, 240)
		gfx.pushContext(backgroundImage)
			gfx.fillRect(0, 0, 400, 240)
		gfx.popContext()
	self.background = gfx.sprite.new(backgroundImage)
		self.background:moveTo(centerX, centerY)
		self.background:setZIndex(1)
		self.background:add()
	--init lock
	self.lockBottom = gfx.sprite.new(lockBottom_image)
		self.lockBottom:moveTo(centerX, centerY)
		self.lockBottom:setZIndex(3)
		self.lockBottom:add()
	self.lockTop = gfx.sprite.new(lockTop_image)
		self.lockTop:moveTo(centerX, centerY)
		self.lockTop:setZIndex(5)
		self.lockTop:add()
		
	--VARIABLES: various variables such as...
	--Booleans: for determining mode of picking and if pickable
	self.pickingMode = true
	self.pickable = false
	--Counters: for determining tension and progress
	self.tension = 0
	self.progress = 0
	
	--TRANSITION:
	self.pickTransitioning = false
	self.pickAnimator = nil
	
	--SHAKER: you gotta shake it
	self.pickShaker = Shake(self.bigPick)
	self.pickTrackerShaker = Shake(self.pickTracker:currentSprite())
	self.pinShaker = Shake(self.pinTracker:currentSprite())
	self.shakeIntensity = 2
	
	--CONTROLS: singular input handler for press A to cast
	self.accessInputHandler = {
		--if ready to cast, cast out
		AButtonUp = function()
			if self.pickingMode and self.pickTransitioning == false then
				--set previous angle
				self.prevAngle = self.crankAngle
				--reset self.crankTicks so that big pick doesn't move
				self.crankTicks = pd.getCrankTicks(1)
				--manip picking mode to BIG PICK
				self.pickingMode = false
				--change small pick
				pickThick = 1
				self:drawPick()
				--change big pick
				self.bigPick:pauseAtFrame(2)
				--init shaker
				self.pickShaker = Shake(self.bigPick)
				--calculate big pick key if pickable
				if self.pickable then 
					if math.abs(self.bigPick.y - (centerY + pickMax)) < math.abs(self.bigPick.y - (centerY + pickMin)) then
						self.bigKey = math.random(centerY + pickMin + 1, self.bigPick.y - 2)
					else
						self.bigKey = math.random(self.bigPick.y + 2, centerY + pickMax - 1)
					end
				end
			elseif not self.pickingMode and self.pickTransitioning == false then
				--set current angle
				self.curAngle = pd.getCrankPosition() - 90
				--begin pick animation
				if self.curAngle ~= self.prevAngle then
					self.pickTransitioning = true
					self.pickAnimator = gfx.animator.new(500, self.prevAngle, self.curAngle, pd.easingFunctions.inCubic)
				end
				--manip picking mode to SMALL PICK
				self.pickingMode = true
				--change small pick
				pickThick = 2
				self:drawPick()
				--change big pick
				self.bigPick:pauseAtFrame(1)
			end
		end,
	}
	pd.inputHandlers.push(self.accessInputHandler)
end

function Access:drawPick(angle)
	--CRANK: init all crank variables
	if angle == nil then
		self.crankAngle = pd.getCrankPosition() - 90
	else
		self.crankAngle = angle
	end
	--establish crank pos
	self.pickPos = math.ceil(self.crankAngle/6)
	--establish crankTicks
	self.crankTicks = pd.getCrankTicks(60)
	if self.crankTicks ~= 0 then
		if self.key == self.pickPos then
			lowClick:play()
			self.pickable = true
		else
			highClick:play()
			self.pickable = false
		end
	end
	
	--do some math
	self.pickX = math.cos(math.rad(self.crankAngle))*pickLength + pickLength
	self.pickY = math.sin(math.rad(self.crankAngle))*pickLength + pickLength
	--draw to image
	self.smallPickImage:clear(gfx.kColorClear)
	gfx.pushContext(self.smallPickImage)
		gfx.setLineWidth(3)
		gfx.drawLine(pickLength, pickLength, self.pickX, self.pickY)
		gfx.setLineWidth(pickThick)
		gfx.setColor(gfx.kColorWhite)
		gfx.drawLine(pickLength + pickThick, pickLength + pickThick, self.pickX + pickThick, self.pickY + pickThick)
		gfx.drawLine(pickLength - pickThick, pickLength - pickThick, self.pickX - pickThick, self.pickY - pickThick)
	gfx.popContext()
	self.smallPick:setImage(self.smallPickImage)
end

function Access:moveBigPick()
	self.crankTicks = pd.getCrankTicks(120)
	if self.pickable == true then
		self.pickTrackerShaker:update()
		--PICK PROCESS: 
		if self.bigPick.y < self.bigKey + self.pinLeeway and self.bigPick.y > self.bigKey - self.pinLeeway then
			self.progress += math.abs(self.crankTicks)
			self.pinShaker:update()
			if math.abs(self.crankTicks) > 0 then
				self.pinShaker.shakeAmount = self.shakeIntensity
			end
			if self.progress >= self.progressGoal then
				self.progress = 0
				self.tension = 0
				self.pinTracker:update()
				self.key = math.random(-14, 45)
				--reset shaker
				self.pickShaker = Shake(self.bigPick)
				self.pinShaker:transition(self.pinTracker:currentSprite())
				self.pickable = false
			end
		end
		if math.abs(self.crankTicks) >= 2 then
			--increase tension and initiate shake indication
			self.tension += math.abs(self.crankTicks)
			self.pickTrackerShaker.shakeAmount = self.shakeIntensity
			--play a breaking sound
			local randNum = math.random(1, 3)
			tensionSounds[randNum]:play()
			--see if broken
			if self.tension >= self.maxTension then
				local randNum = math.random(1, 3)
				breakSounds[randNum]:play()
				self.tension = 0
				self.progress = 0
				self.pickTracker:update()
				self.key = math.random(-14, 45)
				--reset shaker
				self.pickShaker = Shake(self.bigPick)
				self.pickTrackerShaker:transition(self.pickTracker:currentSprite())
				self.pickable = false
			end
		end
		--MOVEMENT: determines if within bounds and moves
		if self.bigPick.y < centerY + pickMax and self.bigPick.y > centerY + pickMin then
			self.bigPick:moveBy(0, -self.crankTicks)
		end
		if self.bigPick.y >= centerY + pickMax then
			self.bigPick:moveTo(centerX, centerY + pickMax - 1)
		elseif self.bigPick.y <= centerY + pickMin then
			self.bigPick:moveTo(centerX, centerY + pickMin + 1)
		end
	else
		--SHAKER: pick vibrates if it cannot move
		self.pickShaker:update()
		self.pickTrackerShaker:update()
		
		if self.crankTicks ~= 0 then
			--shake the tracker and pick, to indicate breakage imminent
			self.pickTrackerShaker.shakeAmount = self.shakeIntensity
			self.pickShaker.shakeAmount = self.shakeIntensity
			--increase tension
			self.tension += 1
			--play a breaking sound
			local randNum = math.random(1, 3)
			tensionSounds[randNum]:play()
			--see if broken
			if self.tension >= self.maxTension then
				local randNum = math.random(1, 3)
				breakSounds[randNum]:play()
				self.tension = 0
				self.progress = 0
				self.pickTracker:update()
				self.key = math.random(-14, 45)
				--reset shaker
				self.pickShaker = Shake(self.bigPick)
				self.pickTrackerShaker:transition(self.pickTracker:currentSprite())
				self.pickable = false
			end
		end
	end
end

function Access:update()
	if self.pickingMode then
		if self.pickTransitioning then
			self:drawPick(self.pickAnimator:currentValue())
			self.pickable = false
			if self.pickAnimator:ended() then
				self.pickTransitioning = false
			end
		else
			self:drawPick()
		end
	elseif not self.pickingMode then
		self:moveBigPick()
	end
	
	--end conditions
	if self.pinTracker:finished() then
		random = math.random(1, 10)
		self.pinTracker:lock()
		--declare transition and initiate it
		transitioner = Transition("SUCCESS", successText[random])
		transitioner.transitioning = true
		self.endFactor = 1
	elseif self.pickTracker:finished() then
		random = math.random(1, 10)
		self.pickTracker:lock()
		--declare transition and initiate it
		transitioner = Transition("FAILURE", failureText[random])
		transitioner.transitioning = true
		self.endFactor = #self.endings
	end
	--transitioning out
	if transitioner.queueLoadIn == true and  self.endFactor ~= nil then
		self:cleanUp()
	end
	if transitioner.queueFinish == true and self.endFactor ~= nil then
		selectedID = self.endings[self.endFactor]
	end	
end

function Access:cleanUp()
	self.bigPick:remove()
	self.smallPick:remove()
	
	self.border:remove()
	self.background:remove()
	
	self.lockBottom:remove()
	self.lockTop:remove()
	
	self.pickShaker:cleanUp()
	self.pickTrackerShaker:cleanUp()
	self.pinShaker:cleanUp()
	
	self.pickTracker:cleanUp()
	self.pinTracker:cleanUp()
end