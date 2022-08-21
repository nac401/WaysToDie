import "minigames/minigame"
import "elements/randomText"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--initialize graphics and variables for this minigame
--curtain offset to center the part/overlap
local curtainOffset = 117

--initialize background
local backgroundImage = gfx.image.new('images/Performance_Minigame/performanceBackground')
local backgroundSprite = gfx.sprite.new(backgroundImage)

--initialize curtains
local curtainImage = gfx.image.new('images/Performance_Minigame/performanceCurtain')
local leftCurtainSprite = gfx.sprite.new(curtainImage)
local rightCurtainSprite = gfx.sprite.new()
rightCurtainSprite:setImage(curtainImage, gfx.kImageFlippedX)

--initialize glyphs
local glyphTable = {}
local keyTable = {} 
--A
local glyphA_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_A')
glyphTable[1] = glyphA_image
keyTable[1] = "A"
--B
local glyphB_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_B')
glyphTable[2] = glyphB_image
keyTable[2] = "B"
--RIGHT
local glyphR_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_RIGHT')
glyphTable[3] = glyphR_image
keyTable[3] = "R"
--LEFT
local glyphL_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_LEFT')
glyphTable[4] = glyphL_image
keyTable[4] = "L"
--UP
local glyphU_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_UP')
glyphTable[5] = glyphU_image
keyTable[5] = "U"
--DOWN
local glyphD_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_DOWN')
glyphTable[6] = glyphD_image
keyTable[6] = "D"
--COUNTER CLOCKWISE CRANK
local glyphCCW_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_CRANKCCW')
glyphTable[7] = glyphCCW_image
keyTable[7] = "CCW"
--CLOCKWISE CRANK
local glyphCW_image = gfx.image.new('images/Performance_Minigame/glyphs/Glyph_CRANKCW')
glyphTable[8] = glyphCW_image
keyTable[8] = "CW"

--optional hearttracker imagetable
local heartImageTable = gfx.imagetable.new("images/UI/hearts")

--init sounds
local mistakeSounds = {}
mistakeSounds[1] = playdate.sound.sampleplayer.new("sounds/performance/mistake1")
mistakeSounds[2] = playdate.sound.sampleplayer.new("sounds/performance/mistake2")
mistakeSounds[3] = playdate.sound.sampleplayer.new("sounds/performance/mistake3")

local correctSounds = {}
correctSounds[1] = playdate.sound.sampleplayer.new("sounds/performance/success1")
correctSounds[2] = playdate.sound.sampleplayer.new("sounds/performance/success2")
correctSounds[3] = playdate.sound.sampleplayer.new("sounds/performance/success3")
correctSounds[4] = playdate.sound.sampleplayer.new("sounds/performance/success4")

local performanceMusic = playdate.sound.fileplayer.new("sounds/music/APerformanceToDieFor")

class('Performance').extends('Minigame')

function Performance:init(difficulty, endings, hearts, duration, numGlyphs)
	Performance.super.init(self)
	--BASICS:  set difficulty and other core variables
	self.difficulty = difficulty
	self.duration = duration
	self.currentDuration = 0
	self.endings = endings

	--DIFFICULTY: set difficulty, including number of glyphs and number of rounds
	if self.difficulty <= 1 then
		self.duration = 3
		self.typeGlyphs = 6
		self.numGlyphs = 3
		self.timerDifficulty = 2500
	elseif self.difficulty == 2 then
		self.duration = 4
		self.typeGlyphs = 8
		self.numGlyphs = 4
		self.timerDifficulty = 3500
	elseif self.difficulty >= 3 then
		self.duration = 4
		self.typeGlyphs = 8
		self.numGlyphs = 4
		self.timerDifficulty = 3000
	end
	--change variables if specific modifiers are present in the init
	if numGlyphs ~= nil then
		self.numGlyphs = numGlyphs
	end
	if duration ~= nil then 
		self.duration = duration
	end


	--SPRITES: init sprites and do setup
	self.background = backgroundSprite
	self.curtainLeft = leftCurtainSprite
	self.curtainRight = rightCurtainSprite
	--place background
	self.background:add()
	self.background:setZIndex(1)
	self.background:moveTo(centerPoint)
	--place curtains
	self.curtainLeft:add()
	self.curtainLeft:setZIndex(101)
	self.curtainLeft:moveTo(centerX - curtainOffset, centerY)
	self.curtainRight:add()
	self.curtainRight:setZIndex(102)
	self.curtainRight:moveTo(centerX + curtainOffset, centerY)
	
	--GLYPHS: init tables of glyphs and keys
	self.glyphTable = glyphTable
	self.keyTable = keyTable
	self.glyphPrinter = {}
	self.printedKey = {}
	
	--VARIABLES: init other miscellaneous variables
	self.printed = false
	self.testIncrement = 1
	
	--initialize timers
	self.timer = pd.timer.new(2250)
	
	--print first round of glyphs before curtain call
	self:printGlyphs()

	--CRANK: init crank variables
	self.crankIntensity = 4	
	
	--allow screenshake
	self.shaker = Shake()
	self.shakeIntensity = 3

	--init optional heartTracker
	self.canMistake = true
	if hearts ~= nil then
		self.hearts = hearts
		self.heartTracker = Tracker(self.hearts, heartImageTable, 2, 0, nil, nil, 5)
	else 
		self.hearts = nil
	end

	--play music
	performanceMusic:stop()
	performanceMusic = playdate.sound.fileplayer.new("sounds/music/APerformanceToDieFor")
	performanceMusic:play()
end

function Performance:running()
	--if curtains are open, check for glyph input
	if self.curtainLeft.x < 50 and self.testIncrement <= self.numGlyphs then
		self:checkGlyphs()
	end
	--if not transitioning AND the timer is expired, begin next run
	if self.transitioning == false and self.timer.timeLeft == 0 then
		if self.curtainLeft.x > 50 then
			self.animator = gfx.animator.new(1000, 0, 190, pd.easingFunctions.outElastic)
		else
			self.animator = gfx.animator.new(1000, 190, 0, pd.easingFunctions.outElastic)
		end
		self.transitioning = true
	end
	--begin next run!
	if self.transitioning then 
		self.curtainLeft:moveTo(centerX - curtainOffset - self.animator:currentValue(), centerY)
		self.curtainRight:moveTo(centerX + curtainOffset + self.animator:currentValue(), centerY)
		if self.animator:ended() then
			--pause before entering next phase of run
			self.transitioning = false
			--determine timer
			if self.curtainLeft.x > 50 then
				--set timer for break while curtains are closed
				self.timer = pd.timer.new(100)
			else
				--set timer until next phase of run 
				self.timer = pd.timer.new(self.timerDifficulty)
			end
			local random = math.random(1, 10)
			if self.curtainLeft.x > 50 then
				self:removeGlyphs()
				self.currentDuration += 1
				if self.testIncrement <= self.numGlyphs then
					--set longer timer to ensure curtains stay closed during transition
					self.timer = pd.timer.new(2000)
					--declare transition and initiate it
					transitioner = Transition("FAILURE", failureText[random])
					transitioner.transitioning = true
					performanceMusic:setVolume(0, 0, 0.5)
					self.endFactor = #self.endings
				elseif self.currentDuration >= self.duration then
					--set longer timer to ensure curtains stay closed during transition
					self.timer = pd.timer.new(2000)
					--declare transition and initiate it
					transitioner = Transition("SUCCESS", successText[random])
					transitioner.transitioning = true
					performanceMusic:setVolume(0, 0, 0.5)
					self.endFactor = 1
				else
					self.testIncrement = 1
					self:printGlyphs()
					self.printed = true
				end
			end
		end
	end
	--check if out of hearts
	if self.hearts ~= nil and self.hearts <= 0 then
		self.hearts = nil
		self.timer = pd.timer.new(2000)
		local random = math.random(1, 10)
		--declare transition and initiate it
		transitioner = Transition("FAILURE", failureText[random])
		transitioner.transitioning = true
		self.endFactor = #self.endings
		performanceMusic:setVolume(0, 0, 0.5)
	end
end

function Performance:mistake()
	self.shaker = Shake(self.glyphPrinter[self.testIncrement])
	self.shaker.shakeAmount = self.shakeIntensity
	self.mistakes += 1
	local randNum = math.random(1, 3)
	mistakeSounds[randNum]:play()
	if self.canMistake and self.hearts ~= nil then
		self.hearts -= 1
		self.heartTracker:update()
		self.canMistake = false
	end
end

function Performance:correct()
	self.glyphPrinter[self.testIncrement]:remove()
	self.testIncrement += 1
	self.crank = 0
	self.canMistake = true
	local randNum = math.random(1, 4)
	correctSounds[randNum]:play()
end

function Performance:printGlyphs()
	for i = 1, self.numGlyphs, 1 do
		local random = math.random(1, self.typeGlyphs)
		self.glyphPrinter[i] = gfx.sprite.new(self.glyphTable[random])
		self.printedKey[i] = self.keyTable[random]
		self.glyphPrinter[i]:add()
		self.glyphPrinter[i]:setZIndex(2)
		self.glyphPrinter[i]:moveTo(centerX - (self.numGlyphs/2)*60 + i*60 - 30, centerY)
	end
end

function Performance:removeGlyphs()
	for i = 1, self.numGlyphs, 1 do
		self.glyphPrinter[i]:remove()
	end
end

function Performance:checkGlyphs()
	--get crank 
	self.crank += pd.getCrankTicks(self.crankIntensity)
	
	if self.printedKey[self.testIncrement] == "A" and pd.buttonJustPressed(pd.kButtonA) then 
		self:correct()
	elseif pd.buttonJustPressed(pd.kButtonA)then
		self:mistake()
	end
	if self.printedKey[self.testIncrement] == "B" and pd.buttonJustPressed(pd.kButtonB) then 
		self:correct()
	elseif pd.buttonJustPressed(pd.kButtonB)then
		self:mistake()
	end
	if self.printedKey[self.testIncrement] == "U" and pd.buttonJustPressed(pd.kButtonUp) then 
		self:correct()
	elseif pd.buttonJustPressed(pd.kButtonUp)then
		self:mistake()
	end
	if self.printedKey[self.testIncrement] == "D" and pd.buttonJustPressed(pd.kButtonDown) then 
		self:correct()
	elseif pd.buttonJustPressed(pd.kButtonDown)then
		self:mistake()
	end
	if self.printedKey[self.testIncrement] == "L" and pd.buttonJustPressed(pd.kButtonLeft) then 
		self:correct()
	elseif pd.buttonJustPressed(pd.kButtonLeft)then
		self:mistake()
	end
	if self.printedKey[self.testIncrement] == "R" and pd.buttonJustPressed(pd.kButtonRight) then 
		self:correct()
	elseif pd.buttonJustPressed(pd.kButtonRight)then
		self:mistake()
	end
	if self.printedKey[self.testIncrement] == "CW" then
		if self.crank > self.crankIntensity - 2 then
			self:correct()
		end
	elseif self.printedKey[self.testIncrement] == "CCW" then
		if self.crank < -self.crankIntensity + 2 then
			self:correct()
		end
	elseif self.crank ~= 0 then
		self.crank = 0
	end
	--end timer when all glyphs have been checked and removed
	if self.testIncrement > self.numGlyphs then
		self.timer = pd.timer.new(0)
	end
end

function Performance:cleanUp()
	self.curtainRight:remove()
	self.curtainLeft:remove()
	self.background:remove()
	self.shaker:cleanUp()
end

function Performance:update()
	self.shaker:update()
	self:running()
	if transitioner.queueLoadIn == true and self.endFactor ~= nil then
		self:cleanUp()
		performanceMusic:stop()
	end
	if transitioner.queueFinish == true and self.endFactor ~= nil then
		selectedID = self.endings[self.endFactor]
	end	
end

