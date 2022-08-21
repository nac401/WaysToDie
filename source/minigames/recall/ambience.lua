--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--initialize local graphics
--dock init, animation (for the ripples)
local dockImageTable = gfx.imagetable.new("images/Recall_Minigame/dock")
local dock = AnimatedSprite(dockImageTable)
--horizon init
local horizonImage = gfx.image.new("images/Recall_Minigame/horizon")
local horizon = gfx.sprite.new(horizonImage)
--waterline init
local waterlineImage = gfx.image.new("images/Recall_Minigame/waterline")
local waterline = gfx.sprite.new(waterlineImage)
--waterline, transparent init
local waterTransparentImage = gfx.image.new("images/Recall_Minigame/waterlineTransparent")
local waterTransparent = gfx.sprite.new(waterTransparentImage)
--reflection init, animation
local reflectionImageTable = gfx.imagetable.new("images/Recall_Minigame/reflectionAnimation")
local reflection = AnimatedSprite(reflectionImageTable)
--clouds  init (into a table of images to be initialized into sprites)
local cloud1Image = gfx.image.new("images/Recall_Minigame/cloud1")
local cloud2Image = gfx.image.new("images/Recall_Minigame/cloud2")
local cloudImage = {cloud1Image, cloud2Image}

--ambient sounds
local waveSound = playdate.sound.sampleplayer.new("sounds/recall/wave")
--sound groups
local birdSounds = {}
birdSounds[1] = playdate.sound.sampleplayer.new("sounds/recall/bird1")
birdSounds[2] = playdate.sound.sampleplayer.new("sounds/recall/bird2")
birdSounds[3] = playdate.sound.sampleplayer.new("sounds/recall/bird3")

--cloud variables
local cloudMax = 90
local cloudMin = 60
local interval = 1
local speed = 2

class('Ambience').extends()

function Ambience:init()
	Recall.super.init(self)
	--SPRITES: initialization and setup
	--initialize background sprites
	self.dock = dock
	self.horizon = horizon
	self.waterline = waterline
	self.reflection = reflection
	self.waterTransparent = waterTransparent
	self.cloud = {}
	self.cloud[1] = gfx.sprite.new(cloudImage[1])
	--setup background sprites 
	--waterline init
	self.waterline:add()
	self.waterline:setZIndex(1)
	self.waterline:moveTo(centerPoint)
	--horizon init
	self.horizon:add()
	self.horizon:setZIndex(2)
	self.horizon:moveTo(centerX, centerY)
	--reflection init
	self.reflection:add()
	self.reflection:setZIndex(3)
	self.reflection:moveTo(centerX, centerY)
	self.reflection:noLoop()
	self.reflection:pauseAtFrame(1)
	--waterline transparent
	self.waterTransparent:add()
	self.waterTransparent:setZIndex(4)
	self.waterTransparent:moveTo(centerPoint)
	--dock init
	self.dock:add()
	self.dock:setZIndex(5)
	self.dock:moveTo(centerX, centerY)
	--clouds init
	self.cloudCounter = 1	
	self.numClouds = 2
	self.cloudsPresent = 0
	for i = 1, self.numClouds, 1 do
		self.cloud[i] = gfx.sprite.new()
	end
	
	
	--ANIMATION: mostly for the reflection/intro animation
	--set timers
	self.waveTimer = pd.timer.new(2000)
	self.cloudTimer = pd.timer.new(1)
	self.birdTimer = pd.timer.new(4000)

	self.running = true
end

function Ambience:ambience()
	--if wavetimer ends, play the reflection animation then reset on end
	if self.waveTimer.timeLeft == 0 then
		local randomTime = math.random(7, 10)
		randomTime = randomTime*1000
		self.waveTimer = pd.timer.new(randomTime)
		self.reflection:setFrame(1)
		self.reflection:continue()
		waveSound:play()
	end
	--move clouds continuously
	self:cloudsMove()
	--bird noise
	self:birdNoise()
end

function Ambience:cloudSpawn()
	local choice = math.random(1, 2)
	local height = math.random(cloudMin, cloudMax)
	self.cloud[self.cloudCounter] = gfx.sprite.new(cloudImage[choice])
	self.cloud[self.cloudCounter]:moveTo(-100, centerY - height)
	self.cloud[self.cloudCounter]:setZIndex(4)
	self.cloud[self.cloudCounter]:add()
	self.cloudsPresent += 1
	self.cloudCounter += 1
	if self.cloudCounter > self.numClouds then
		self.cloudCounter = 1
	end
end

function Ambience:cloudsMove()
	if interval == 1 then
		for i = 1, self.numClouds, 1 do
			self.cloud[i]:moveBy(1, 0)
			if self.cloud[i].x > 500 then
				self.cloud[i]:remove()
				self.cloud[i]:moveTo(-100, centerY)
				self.cloudsPresent -= 1
			end
		end
		interval += 1
	elseif interval >= speed then
		interval = 1
	else
		interval += 1
	end
	if self.cloudTimer.timeLeft == 0 then
		local randomDuration = math.random(10, 30)
		randomDuration = randomDuration * 1000
		if self.cloudsPresent < self.numClouds then
			self:cloudSpawn()
		end
		self.cloudTimer = pd.timer.new(randomDuration)
	end
end

function Ambience:birdNoise()
	if self.birdTimer.timeLeft == 0 then
		local randSound = math.random(1, 3)
		birdSounds[randSound]:play()
		local randTime = math.random(1, 20)*250
		self.birdTimer = pd.timer.new(randTime)
	end
end

--basic clean up function, removes relevant sprites and pops inputhandler
function Ambience:cleanUp()
	self.dock:remove()
	self.horizon:remove()
	self.waterline:remove()
	self.reflection:remove()
	self.waterTransparent:remove()
	self.cloud[1]:remove()
	self.cloud[2]:remove()
	waveSound:stop()
	self.running = false
end

--update function containing the relevant functions
function Ambience:update()
	if self.running == true then 
		self:ambience()
	end
end