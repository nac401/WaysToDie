import "minigames/minigame"
import "minigames/recall/ambience"
import "minigames/recall/rod"

import "elements/randomText"
import "elements/pointBar"
import "elements/tracker"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--init ui graphics
local heartImageTable = gfx.imagetable.new("images/UI/hearts")
local  catchesImageTable = gfx.imagetable.new("images/UI/fish")

local successSound 	= playdate.sound.sampleplayer.new("sounds/recall/success")
local failureSound 	= playdate.sound.sampleplayer.new("sounds/recall/failure")

recall_score = 0
recall_currentCatches = 0

class('Recall').extends('Minigame')

function Recall:init(difficulty, endings, catchesNeeded, maxFailures)
	Recall.super.init(self)
	
	--BASICS: difficulty, duration, endings, score
	self.difficulty = difficulty
	self.endings = endings
	--set global variables that interact with all classes
	recall_score = 500
	recall_currentCatches = 0
	recall_failures = 0

	--DIFFICULTY: define difficulty, defaults and modifiers
	if self.difficulty <= 1 then
		self.catchesNeeded = 1
		self.maxFailures = 2 
	elseif self.difficulty == 2 then
		self.catchesNeeded = 2
		self.maxFailures = 2 
	elseif self.difficulty >= 3 then
		self.catchesNeeded = 1
		self.maxFailures = 1 
	end
	--set modifiers if defined, to catches needed and maximum failures
	if catchesNeeded ~= nil then
		self.catchesNeeded = catchesNeeded
	end
	if maxFailures ~= nil then
		self.maxFailures = maxFailures
	end
	
	--win conditions
	self.caught = false
	self.lost = false
	
	--TRACKERS:
	--init  heart icons
	self.heartTracker = Tracker(self.maxFailures, heartImageTable, 2)
	--init catches icons
	self.catchesTracker = Tracker(self.catchesNeeded, catchesImageTable, 1, nil, nil, nil, 16)
	
	--ROD: init rod
	self.rod = Rod(self.difficulty)	
	--ANIMATION: creates ambient background
	self.ambience = Ambience()	
	--UI: create UI
	--init bar to track points
	pointBar = PointBar(200, 0, 400, 1000, 5)
	pointBar:moveTo(200, 0)
	pointBar:remove()
end

function Recall:endCondition()
	--establish conditions for success and failure
	if recall_score >= 1000 then
		successSound:play()
		self.caught = true	
		--prep for finish
		self.rod:prepFinish()
	elseif recall_score <= 0 then
		failureSound:play()
		self.lost = true
		--prep for finish
		self.rod:prepFinish()
	end
	--determine win condition
	if self.caught == true and self.rod:doneAnimating() then
		recall_currentCatches += 1
		self.catchesTracker:update()
		self.rod:reset()
		self.caught = false
	elseif self.lost == true and self.rod:doneAnimating() then
		recall_failures += 1
		self.heartTracker:update()
		self.rod:reset()
		self.lost = false
	end
	--determine final success or failure
	local random = math.random(1, 10)
	if recall_currentCatches >= self.catchesNeeded then
		--declare transition and initiate it
		transitioner = Transition("SUCCESS", successText[random])
		transitioner.transitioning = true
		self.endFactor = 1
		recall_currentCatches = -1
	elseif recall_failures >= self.maxFailures then
		--declare transition and initiate it
		transitioner = Transition("FAILURE", failureText[random])
		transitioner.transitioning = true
		self.endFactor = #self.endings
		recall_failures = -1
	end
end

--basic clean up function, removes relevant sprites and pops inputhandler
function Recall:cleanUp()
	self.heartTracker:cleanUp()
	self.catchesTracker:cleanUp()
	self.rod:cleanUp()
	self.ambience:cleanUp()
	pointBar:remove()
end

--update function containing the relevant functions
function Recall:update()
	self.rod:update()
	self.ambience:update()
	pointBar:updateLength(recall_score)
	self:endCondition()
	
	if transitioner.queueLoadIn == true and  self.endFactor ~= nil then
		self:cleanUp()
	end
	if transitioner.queueFinish == true and self.endFactor ~= nil then
		selectedID = self.endings[self.endFactor]
	end	
end