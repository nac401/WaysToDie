import 'elements/animatedsprite'

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--font repository
regFont = gfx.font.new("fonts/regular")
smallFont = gfx.font.new("fonts/regularSmall")
scaryFont = gfx.font.new("fonts/rubber")
gfx.setFont(smallFont)

--import text sounds
--first low beeps, for scary text
local low1 = playdate.sound.sampleplayer.new("sounds/dialogue/low/low1")
local low2 = playdate.sound.sampleplayer.new("sounds/dialogue/low/low2")
local low3 = playdate.sound.sampleplayer.new("sounds/dialogue/low/low3")
local low4 = playdate.sound.sampleplayer.new("sounds/dialogue/low/low4")
local low5 = playdate.sound.sampleplayer.new("sounds/dialogue/low/low5")
local low6 = playdate.sound.sampleplayer.new("sounds/dialogue/low/low6")
--make array of low sounds
local lowSounds = {low1, low2, low3, low4, low5, low6}
--then med beeps, for regular text
local med1 = playdate.sound.sampleplayer.new("sounds/dialogue/med/med1")
local med2 = playdate.sound.sampleplayer.new("sounds/dialogue/med/med2")
local med3 = playdate.sound.sampleplayer.new("sounds/dialogue/med/med3")
local med4 = playdate.sound.sampleplayer.new("sounds/dialogue/med/med4")
local med5 = playdate.sound.sampleplayer.new("sounds/dialogue/med/med5")
local med6 = playdate.sound.sampleplayer.new("sounds/dialogue/med/med6")
--an array of the medium sounds
local medSounds = {med1, med2, med3, med4, med5, med6}
--single shout sound
local shoutSound = playdate.sound.sampleplayer.new("sounds/dialogue/crash")

--initialize button prompt sprite
local glyphTable_A = gfx.imagetable.new("images/buttonglyphs/AButton/AbuttonGlyph")
glyphSprite = AnimatedSprite(glyphTable_A)

--constants, defining indents
local leftIndent        = 20
local lineIndent        = 25
local rightIndent       = 350
local soundFrequency    = 5

class('Printer').extends()

function Printer:init()
    Printer.super.init(self)
    --master image and sprite for all existing dialogue, initialize sprite
    self.dialogueImage   = gfx.image.new(400,800)
    self.dialogueSprite  = gfx.sprite.new(dialogueImage)
    self.dialogueSprite:moveTo(200, 390)
    self.dialogueSprite:add()
    self.dialogueSprite:setZIndex(1)

    --local variables used in basic print functions
    self.printMeter        = 1
    self.charPos           = leftIndent
    self.printLine         = lineIndent
    self.finalLineLoc      = lineIndent
    self.nextWordSize      = 0
    self.randOffset        = 0
    self.style = "regular"

    --shared variables used to communicate with overall dialogue printer and continuing
    --with player input
    self.linePos = 1
    self.queryContinue = true
    self.playerInput = false
end

function Printer:playRandomSound(table, increment)
    if soundFrequency == increment then
        local randomSound = math.random(1, #table)
        table[randomSound]:play()
        soundFrequency = 0
    elseif soundFrequency > increment then
        soundFrequency = increment
    else
        soundFrequency += 1
    end

end

--drawing functions, one to be used sequentially
function Printer:drawToImage(char)
    gfx.pushContext(self.dialogueImage)
        gfx.drawText(char, self.charPos, self.printLine + self.randOffset)
    gfx.popContext()
    self.dialogueSprite:setImage(self.dialogueImage)
end
--another to draw all at once: a shout
function Printer:drawShout(text)
    gfx.pushContext(self.dialogueImage)
        gfx.drawText(text, 200 - gfx.getTextSize(text)/2, self.printLine + 10)
    gfx.popContext()
    self.dialogueSprite:setImage(self.dialogueImage)
    --reset all variables and carry on
    self:resetPrintVar()
    self.style = "regular"
    self.printMeter = 1
    --calc final line
    self.finalLineLoc += lineIndent*2
    self.printLine += lineIndent*2
    --head to next print, pausing before input
    self.linePos += 1
    self.queryContinue = false
    self.playerInput = true
    --add button prompt
    glyphSprite:add()
    glyphSprite:moveTo(rightIndent + lineIndent, self.finalLineLoc)
    glyphSprite:setZIndex(10)
end

--some basic text management functions, one to reset printer variables to clean up code
function Printer:resetPrintVar()
    --reset variables
    self.charPos = leftIndent
    self.printMeter += 1
end
--and another to get the next word size to avoid spilling over the screen
function Printer:getNextWordSize(text)
    local pos1 = self.printMeter
    local pos2 = self.printMeter + 1
    local currentChar = string.sub(text, pos2, pos2)
    while currentChar ~= " " and pos2 <= #text do
        pos2 += 1
        currentChar = string.sub(text, pos2, pos2)
    end
    local nextWord = string.sub(text, pos1, pos2)
    local nextWordSize = #nextWord
    return nextWordSize
end

--the bread and butter printer, prints each character individually in a string of text
function Printer:printChar(char, text)
    local nextChar = string.sub(text, self.printMeter + 1, self.printMeter + 1)
    --first guages if we can go to new line at a " " opportunity
    if char == " " then
        self.nextWordSize = self:getNextWordSize(text) + 5
    end
    if char == " " and (self.charPos + self.nextWordSize) > (rightIndent) then
        self:drawToImage(char)
        --self.printMeter += 1
        self:resetPrintVar()
        --calc final line
        self.finalLineLoc += lineIndent
        self.printLine += lineIndent
    else
        self:drawToImage(char)
        --queries if we have come to the end of the text, reseting and preparing for next print
        if self.printMeter > #text then
            self:resetPrintVar()
            self.style = "regular"
            self.printMeter = 1
            --calc final line
            self.finalLineLoc += lineIndent
            self.printLine += lineIndent
            --head to next print, pausing before input
            self.linePos += 1
            self.queryContinue = false
            self.playerInput = true
            --add button prompt
            glyphSprite:add()
            glyphSprite:moveTo(rightIndent + lineIndent, self.finalLineLoc)
            glyphSprite:setZIndex(10)
        else
            --move on to next character in text string
            self.printMeter += 1
            self.charPos += gfx.getTextSize(char) + 1
        end
    end
end

--all unique print functions, normal printing, 
function Printer:printNormal(char, text)
    gfx.setFont(smallFont)
    self:printChar(char, text)
    self:playRandomSound(medSounds, 3)
end
--scary printing
function Printer:printEvil(char, text)
    gfx.setFont(scaryFont)
    self.randOffset = math.random(-2, 2)
    self:printChar(char, text)
    self:playRandomSound(lowSounds, 4)
end
--and all at once shout printing
function Printer:printShout(text)
    gfx.setFont(regFont)
    self:drawShout(text)
    shoutSound:play()
    screenshake.shakeAmount = 5
end

--prints enter strings (text) frame by frame, queries for a blanket print
function Printer:printText(text)
    --move dialogue sprite if at the bottom of the screen
    if self.finalLineLoc >= 200 and self.queryContinue == true then
        self.dialogueSprite:moveBy(0, -25)
        self.finalLineLoc -= 25
    end
    --initialize character in text sequence
    local char = string.sub(text, self.printMeter, self.printMeter)
    --determine style by prefix
    if char == "#" then
        self.style = "evil"
        self.printMeter += 1
        char = string.sub(text, self.printMeter, self.printMeter)
    elseif char == "@" then
        self.style = "shout"
        self.printMeter += 1
        char = string.sub(text, self.printMeter, self.printMeter)
    end
    --print character in specific style
    if self.style == "evil" then
        self:printEvil(char,text)
    elseif self.style == "shout" then
        local newText = string.sub(text, 2, #text)
        self:printShout(newText)
    else 
        self:printNormal(char, text)
    end
    --speed up print with B button press/hold
    if pd.buttonIsPressed(pd.kButtonB) and self.printMeter < #text - 1 and self.printMeter ~= 1 then
		    char = string.sub(text, self.printMeter, self.printMeter)
            --print character in specific style
            if self.style == "evil" then
                self:printEvil(char,text)
            elseif self.style == "shout" then
                local newText = string.sub(text, 2, #text)
                self:printShout(newText)
            else 
                self:printNormal(char, text)
            end
	end
end