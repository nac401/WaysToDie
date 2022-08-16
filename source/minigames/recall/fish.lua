import "minigames/recall/rod"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--splash init and its two animations, starting with idle
local splashIdle_ImageTable = gfx.imagetable.new("images/Recall_Minigame/Rod/splashIdle")
local splashPull_ImageTable = gfx.imagetable.new("images/Recall_Minigame/Rod/splashPull")
local splash = AnimatedSprite(splashIdle_ImageTable, 500)
--fish images init
local maniniCatchImage = gfx.imagetable.new("images/Recall_Minigame/fishEmerge")
local fish = {}
fish[1] = maniniCatchImage

--init sounds
local bobSounds = {}
bobSounds[1] = playdate.sound.sampleplayer.new("sounds/recall/bob1")
bobSounds[2] = playdate.sound.sampleplayer.new("sounds/recall/bob2")
bobSounds[3] = playdate.sound.sampleplayer.new("sounds/recall/bob3")

--local constants
--splash offsets
local splashStartX = 72
--fish coords
local fishOffset = 40
local fishY = 132

class('Fish').extends()

function Fish:init(difficulty)
	--BASICS: difficulty
	self.difficulty = difficulty

	--DIFFICULTY: difficulty variables and initialization of those variables
	self.numPulls = 2
	if self.difficulty >= 3 then
		self.numPulls = 1
	end
	
	--SPRITES: initialization and setup
	--initialize and setup splash sprite 
	self.splash = splash
	self.splash:setZIndex(9)
	self.splash:moveTo(splashStartX, splashY)
	--initialize fish sprites
	self.fish = AnimatedSprite(fish[1], nil, 1)
	self.fish:setZIndex(15)
	self.fish:noLoop()
	self.fish:setFrame(1)
	self.fish:pause()
	--init win text
	self.textImage = gfx.image.new(60, 15)
	gfx.pushContext(self.textImage)
		gfx.drawText("caught!", 0, 0)
	gfx.popContext()
	self.winText = gfx.sprite.new(self.textImage)
	self.winText:setZIndex(50)
	self.winText:moveTo(centerX, centerY - fishOffset)
	
	
	--TRAITS: fish variables
	self.speed = 1
	
	--ANIMATORS: animator variables
	self.transitioning = false
	self.animatorX = nil
	self.animatorY = nil
	self.timer = nil
end

function Fish:start()
	--add splash at starting point
	self.splash:add()
	self.splash:moveTo(splashStartX, splashY)
end

function Fish:setIdle()
	self.splash:setAnimation(splashIdle_ImageTable, 500)
end

function Fish:setPulling()
	self.splash:setAnimation(splashIdle_ImageTable, 500)
end

function Fish:pull()
	local randomPulls = math.random(1, self.numPulls)
	local randNum = math.random(1, 3)
	bobSounds[randNum]:play(randomPulls)
	self.splash:setAnimation(splashPull_ImageTable, 50, randomPulls)
end

function Fish:splashRemove()
	self.splash:remove()
	self.splash:moveTo(splashStartX, splashY)
end

function Fish:animationEnded()
	if self.fish.loopFinished then
		return true
	else
		return false
	end
end

function Fish:caughtAnimation()
	local spriteX, spriteY = self.fish:getPosition()
	if self.transitioning and self.animatorX == nil then
		pd.inputHandlers.pop()
		self.animatorX = gfx.animator.new(500, spriteX, centerX, pd.easingFunctions.inCubic, 250)
		self.animatorY = gfx.animator.new(500, spriteY, centerY, pd.easingFunctions.inCubic, 250)
	elseif self.animatorX == nil then
		return
	elseif self.animatorX:ended() then
		if spriteY <= -50 then
			self.transitioning = false
			self.animatorX = nil
			self.animatorY = nil
			self:reset()
		else
			self.animatorX = gfx.animator.new(500, centerX, centerX, pd.easingFunctions.inCubic, 500)
			self.animatorY = gfx.animator.new(500, centerY, -100, pd.easingFunctions.inCubic, 500)
			self.winText:add()
			self.timer = pd.timer.new(500)
		end
	end
	if self.transitioning then
		self.fish:moveTo(self.animatorX:currentValue(), self.animatorY:currentValue())
	end
	if self.timer ~= nil and self.timer.timeLeft <= 0 then
		self.winText:remove()
	end
end

function Fish:caught()
	--start fish transitioning
	self.transitioning = true
	--add fish
	self.fish:moveTo(self.splash.x, fishY)
	self.fish:add()
	self.fish:continue()
end

function Fish:reset()
	--reset fish animation
	self.fish:remove()
	self.fish = AnimatedSprite(fish[1], nil, 1)
	self.fish:setZIndex(15)
	self.fish:noLoop()
	self.fish:setFrame(1)
	self.fish:pause()
	--reset speed
	self.speed = 1
end

function Fish:cleanUp()
	self.splash:remove()
	self.fish:remove()
end

function Fish:update()
	self:caughtAnimation()
	self.speed = math.random(0, 2)
end