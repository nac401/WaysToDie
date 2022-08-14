import "printer/printer"
import "printer/prompt"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Dialogue').extends('Printer')

function Dialogue:init(stringSeries, promptOptions, promptAnswers)
	Dialogue.super.init(self)
	--initialize animators and animator variables
	self.prompts = promptOptions
	self.strings = stringSeries
	self.answer = promptAnswers
	self.currentPrompt = nil
	self.promptAnimator = nil
	self.dialogueRepoAnimator = nil
	self.originalY = 0
	self.transitioningIn = false
	self.transitioningOut = false
end

--enable cranking to scroll text when prompting
function Dialogue:enableCrankScroll()
	local crankValue = pd.getCrankTicks(120)
	if crankValue < 0 and self.dialogueSprite.y > self.originalY then
		self.dialogueSprite:moveBy(0, crankValue)
	elseif crankValue > 0 and self.dialogueSprite.y < 385 then
		self.dialogueSprite:moveBy(0, crankValue)
	end
end

--print dialogue and transition in and out of scene
function Dialogue:printDialogue()
	if self.linePos <= #self.strings and self.queryContinue == true then
		self:printText(self.strings[self.linePos])
	elseif  self.linePos == #self.strings + 1 and self.queryContinue == true then
		self.currentPrompt = Prompt(self.prompts, self.answer)
		self.currentPrompt.promptWindow:add()
		self.originalY = self.dialogueSprite.y
		self.promptAnimator = gfx.animator.new(1000, 0, 600, pd.easingFunctions.outCubic)
		self.dialogueRepoAnimator = gfx.animator.new(1000, 0, 240 - self.finalLineLoc - self.currentPrompt:getPromptHeight() + 15, pd.easingFunctions.outBounce)
		self.transitioningIn = true
		self.linePos += 1
	elseif self.linePos > #self.strings + 1 then
		self.currentPrompt:draw()
		self:enableCrankScroll()
	end

	--commit in transition
	if self.transitioningIn then
		self.dialogueSprite:moveTo(200, self.originalY + self.dialogueRepoAnimator:currentValue())
		self.currentPrompt.promptWindow:moveTo(-400 + self.promptAnimator:currentValue(), 120)
		if self.promptAnimator:ended() and self.dialogueRepoAnimator:ended() then
			confirmedSprite:add()
			self.transitioningIn = false
			self.originalY = self.dialogueSprite.y
			pd.inputHandlers.push(self.currentPrompt.promptInputHandler)
		end
	end

	--initialize out transition
	if promptSelected then
		self.promptAnimator = gfx.animator.new(500, 0, 600, pd.easingFunctions.inCubic)
		self.dialogueRepoAnimator = gfx.animator.new(500, 0, -self.finalLineLoc - 240, pd.easingFunctions.inCubic)
		self.originalY = self.dialogueSprite.y
		self.transitioningOut = true
		promptSelected = false
	end

	--commit out transition
	if self.transitioningOut then
		self.dialogueSprite:moveTo(200, self.originalY + self.dialogueRepoAnimator:currentValue())
		self.currentPrompt.promptWindow:moveTo(200 + self.promptAnimator:currentValue(), 120)
		if self.promptAnimator:ended() and self.dialogueRepoAnimator:ended() then
			self.transitioningOut = false
			selectedID = newID
		end
	end
end

function Dialogue:cleanUp()
	if self.currentPrompt ~= nil then
		self.currentPrompt:cleanUp()
	end
	self.dialogueSprite:remove()
end

function Dialogue:update()
	--print dialogue
	self:printDialogue()
	--query continue
	if self.playerInput == true and pd.buttonJustPressed(pd.kButtonA) then
		self.queryContinue = true
		self.playerInput = false
		glyphSprite:remove()
	end
end