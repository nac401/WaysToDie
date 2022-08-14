--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Minigame').extends()

function Minigame:init()
	Minigame.super.init(self)
	--initialize all common variables throughout minigames
	--transition boolean
	self.transitioning = false
	--basic animator variable
	self.animator = nil
	
	--mistakes counter
	self.mistakes = 0
	
	--set end factor, options: 1 is success, #endFactor is failure, in between: optional
	self.endFactor = nil
	
	--CRANK: init crank variables
	self.crank = 0
	self.crankIntensity = 0	
end