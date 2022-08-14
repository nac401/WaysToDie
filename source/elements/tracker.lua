import "elements/animatedsprite"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Tracker').extends()

function Tracker:init(quantity, imageTable, startingState, x, y, xOffset, yOffset)
	Tracker.super.init(self)
	--init target quantity
	self.quantity = quantity
	--init counter
	self.counter = 1
	
	--POSITION: default is top right
	--make sure offsets aren't nil
	if xOffset == nil then
		xOffset = 0
	end
	if yOffset == nil then
		yOffset = 0
	end
	--X: neg = L, 0 = C, pos = R
	if x == nil then
		self.x = 400 - 16*self.quantity + xOffset
	elseif x < 0 then
		self.x = 16 + xOffset
	elseif x == 0 then
		self.x = 200 - (16*self.quantity)/2 + xOffset + 8
	elseif x > 0 then
		self.x = 400 - 16 - 16*self.quantity + xOffset
	end
	--Y, neg = B, pos = T
	if y == nil then
		self.y = 16 + yOffset
	elseif y < 0 then
		self.y = 240 - 16 + yOffset
	elseif y >= 0 then
		self.y = 16 + yOffset
	end
	
	--STATES: starting state is default 1, some imageTables may be different
	self.startingState = 1
	if startingState ~= nil then
		self.startingState = startingState
	end
	--init opposing state and default
	if self.startingState == 2 then
		self.opposingState = 1
	else
		self.opposingState = 2
	end
	
	--SPRITETABLE: initialize and setup animated sprites in a table
	self.imageTable = imageTable
	self.trackerTable = {}
	for i = 1, self.quantity, 1 do
		local offset = (i-1)*16
		self.trackerTable[i] = AnimatedSprite(self.imageTable)
		self.trackerTable[i]:pauseAtFrame(self.startingState)
		self.trackerTable[i]:moveTo(self.x + offset, self.y)
		self.trackerTable[i]:setZIndex(100)
		self.trackerTable[i]:add()
	end
end

function Tracker:currentSprite()
	return self.trackerTable[self.counter]
end

function Tracker:update()
	self.trackerTable[self.counter]:pauseAtFrame(self.opposingState)
	self.counter += 1
end

function Tracker:regress()
	self.counter -= 1
	self.trackerTable[self.counter]:pauseAtFrame(self.startingState)
end

function Tracker:finished()
	if self.counter > self.quantity then
		return true
	else
		return false
	end
end

function Tracker:cleanUp()
	for i = 1, self.quantity, 1 do
		self.trackerTable[i]:remove()
	end
end

function Tracker:lock()
	self.counter = -1
end