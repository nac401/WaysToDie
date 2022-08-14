import "printer/printer"
import "printer/dialogue"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--background window initialized
local background = gfx.nineSlice.new("images/promptwindow", 6, 6, 6, 6)

--initialize button confirm sprite
local confirmTable_A = gfx.imagetable.new("images/buttonglyphs/AButton/AButtonConfirm")


inputTimer = nil
inputTimerLength = 500
promptSelected = false
newID = nil

class('Prompt').extends()


--create prompt initializer
function Prompt:init(promptOptions, promptAnswers)
    Prompt.super.init(self)

    inputTimer = pd.timer.new(inputTimerLength)
    inputTimer:pause()

    --initialize promptWindow image and sprite 
    self.promptWindowImage = gfx.image.new(400, 240)
    self.promptWindow = gfx.sprite.new(self.promptWindowImage)
    self.promptWindow:setZIndex(10)

    --initialize the press A to confirm sprite
    confirmedSprite = AnimatedSprite(confirmTable_A)
    confirmedSprite.loop.delay = inputTimerLength/#confirmedSprite.sprites
    confirmedSprite:noLoop()
    confirmedSprite:setZIndex(11)
    confirmedSprite:pauseAtFrame(1)

    --initialize prompt variables
    self.prompts = promptOptions
    self.answer = promptAnswers
    self.numPrompts = #self.prompts
    self.selectedPrompt = 1
    self.promptGrid = playdate.ui.gridview.new(0, 15)
    --create input handler for prompt window 
    self.promptInputHandler = {
        downButtonUp = function()
            self.promptGrid:selectNextRow(true)
            self.selectedPrompt += 1
            if self.selectedPrompt > self.numPrompts then
                self.selectedPrompt = 1
            end
            self:draw()
        end,
        upButtonUp = function()
            self.promptGrid:selectPreviousRow(true)
             self.selectedPrompt -= 1
             if self.selectedPrompt < 1 then
                self.selectedPrompt = self.numPrompts
             end
             self:draw()
        end,
        AButtonDown = function()
            inputTimer = pd.timer.new(inputTimerLength)
        end,
        AButtonUp = function()
            if inputTimer.timeLeft == 0 then
                newID = self.answer[self.selectedPrompt]
                confirmedSprite:remove()
                pd.inputHandlers.pop()
                promptSelected = true
            end
            confirmedSprite:pauseAtFrame(1)
            inputTimer:reset()
            inputTimer:remove()
            inputTimer = pd.timer.new(inputTimerLength)
            inputTimer:pause()
        end
    }
end

function Prompt:getPromptHeight()
    local boxHeight = self.numPrompts*33
    if boxHeight > 120 then
        boxHeight = 120
    elseif boxHeight < 45 then
        boxHeight = 45
    end
    return boxHeight
end

function Prompt:draw()
    gfx.setFont(smallFont)
    self.promptGrid.prompts = self.prompts
    self.promptGrid.backgroundImage = background
    self.promptGrid:setNumberOfRows(self.numPrompts)
    self.promptGrid:setCellPadding(0, 0, 5, 5)
    self.promptGrid:setContentInset(25, 25, 6, 6)

    function self.promptGrid:drawCell(section, row, column, selected, x, y, width, height)
        gfx.drawTextInRect(row .. ". ", x, y + 5, width, height + 5, nil, "...", kTextAlignment.left)
        if selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.fillRoundRect(x + 15, y - 3, gfx.getTextSize(self.prompts[row]) + 10, 25, 10)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            confirmedSprite:moveTo(x - 10, y + 10)
            if inputTimer.timeLeft ~= inputTimerLength then
                confirmedSprite:continue()
            end
        end
        gfx.drawTextInRect(self.prompts[row], x + 20, y + 5, width, height + 5, nil, "...", kTextAlignment.left)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    end

    local boxHeight = self:getPromptHeight()

    gfx.pushContext(self.promptWindowImage)
        self.promptGrid:drawInRect(0, 240 - boxHeight, 400, boxHeight)
    gfx.popContext()
    self.promptWindow:setImage(self.promptWindowImage)
end

function Prompt:cleanUp()
    inputTimer:remove()
    self.promptWindow:remove()
end