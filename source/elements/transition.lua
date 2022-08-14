local pd <const> = playdate
local gfx <const> = playdate.graphics

local titleStart = -130
local curtainStart = -240
local subtitleStart = -110

class('Transition').extends()

function Transition:init(titleText, subtitleText)
    gfx.setFont(regFont)
    self.titleX, self.titleY = gfx.getTextSize(titleText)
    gfx.setFont(smallFont)
    self.subX, self.subY = gfx.getTextSize(subtitleText)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(regFont)

    --initialize title  
    self.title = gfx.sprite.new()
    self.titleImage = gfx.image.new(self.titleX + 10, self.titleY + 10)
    gfx.pushContext(self.titleImage)
        gfx.drawText(titleText, 5, 5)
    gfx.popContext()
    self.title:setImage(self.titleImage)
    self.title:setZIndex(1000)
    self.title:add()

    --initialize subtitle
    gfx.setFont(smallFont)
    self.subtitle = gfx.sprite.new()
    self.subtitleImage = gfx.image.new(self.subX + 10, self.subY + 10)
    gfx.pushContext(self.subtitleImage)
        gfx.drawText(subtitleText, 5, 5)
    gfx.popContext()
    self.subtitle:setImage(self.subtitleImage)
    self.subtitle:setZIndex(1000)
    self.subtitle:add()

    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    --initialize curtain
    self.curtainSprite = gfx.sprite.new()
    self.curtainImage = gfx.image.new(400, 240)
    gfx.pushContext(self.curtainImage)
            gfx.fillRect(0, 0, 400, 240)
    gfx.popContext()
    self.curtainSprite:setImage(self.curtainImage)
    self.curtainSprite:setCenter(0, 0)
    self.curtainSprite:setZIndex(999)
    self.curtainSprite:moveTo(0, curtainStart)
    self.curtainSprite:add()
    
    --initialize variables
    self.transitioning = false
    self.transitionAnimator = nil
    self.queueLoadIn = false
    self.queueFinish = false
end

function Transition:curtain()
    if self.transitionAnimator == nil then
        self.transitionAnimator = gfx.animator.new(1000, 0, 240, pd.easingFunctions.outCubic)
    end
    if self.transitioning then
        --animate titles and curtain
        self.curtainSprite:moveTo(0, curtainStart + self.transitionAnimator:currentValue())
        self.title:moveTo(200, titleStart + self.transitionAnimator:currentValue())
        self.subtitle:moveTo(200, subtitleStart + self.transitionAnimator:currentValue())
        --move on to next phase of animation or wrap up animation
        if self.transitionAnimator:ended() then
            if self.transitionAnimator:currentValue() == 0 then
                self.transitioning = false
                self.queueLoadIn = false
                self.queueFinish = true
                self.title:remove()
                self.subtitle:remove()
                self.curtainSprite:remove()
            else
                self.transitionAnimator = gfx.animator.new(1000, 240, 0, pd.easingFunctions.inCubic, 1000)
                self.queueLoadIn = true
            end
        end
    end
end

function Transition:cleanUp()
   self.curtainSprite:remove()
   self.title:remove()
   self.subtitle:remove() 
end

function Transition:update()
   if self.transitioning == true then
      self:curtain()
   end
end