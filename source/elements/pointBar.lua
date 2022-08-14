--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class("PointBar").extends(gfx.sprite)

function PointBar:init(x, y, endVal, endPoint, barWidth)
	PointBar.super.init(self)
	--establish pos variable
	self.x = x
	self.y = y
	--establish qualities variables
	self.startVal = 1
	self.endVal = endVal
	self.endPoint = endPoint
	self.barWidth = barWidth
	--establish manipulatable value
	self.currentVal = 1
	self.modifiedVal = math.ceil(self.currentVal*(self.endVal/self.endPoint))
	--update and move self
	self:updateLength(self.modifiedVal)	
	self:setZIndex(100)
	self:add()
end

function PointBar:updateLength(updatedValue)
	--update current value
	self.currentVal = updatedValue
	self.modifiedVal = math.ceil(self.currentVal*(self.endVal/self.endPoint))
	--init bar image
	local barImage = gfx.image.new(self.endVal, self.barWidth)
	--update bar image
	gfx.pushContext(barImage)
		gfx.fillRect(0, 0, self.modifiedVal, self.barWidth)
	gfx.popContext()	
	--update bar sprite
	self:setImage(barImage)
end