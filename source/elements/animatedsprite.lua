local pd <const> = playdate
local gfx <const> = playdate.graphics

local animationTiming = 100

class('AnimatedSprite').extends(gfx.sprite)

function AnimatedSprite:init(spriteTable, timing, numLoops)
    AnimatedSprite.super.init(self)
    --determine animation timing
    self.timing = animationTiming
    if timing ~= nil then
        self.timing = timing
    end
    --init counter and number of loops 
    self.counter = 0
    self.numLoops = -1
    --init num frames
    self.numFrames = #spriteTable
    if numLoops ~= nil then
        self.numLoops = numLoops
    end
    --init boolean determining if loop is finished
    self.loopFinished = false
    --init table and animation loop
    self.sprites = spriteTable
    self.loop = gfx.animation.loop.new(self.timing, self.sprites)
end

function AnimatedSprite:animateSprite()
    self:setImage(self.loop:image())
end

function AnimatedSprite:setAnimation(newTable, newTiming, newLoops)
    --new num frames
    self.numFrames = #newTable
    --init timing
    if newTiming ~= nil then
        self.timing = newTiming
    else
        self.timing = animationTiming
    end
    --reset counter and determine new loops and reset loopFinished boolean
    self.counter = 0
    self.loopFinished = false
    if newLoops ~= nil then
        self.numLoops = newLoops
    else
        self.numLoops = -1
    end
    --init table and animation loop
    self.sprites = newTable
    self.loop = gfx.animation.loop.new(self.timing, self.sprites)
end

function AnimatedSprite:setFrame(frame)
    self.loop.frame = frame
end

function AnimatedSprite:pauseAtFrame(frame)
    self:setFrame(frame)
    self.loop.paused = true
end

function AnimatedSprite:pause()
    self.loop.paused = true
end

function AnimatedSprite:continue()
    self.loop.paused = false
end

function AnimatedSprite:doLoop()
    self.loop.shouldLoop = true
   -- self:setFrame(1)
end

function AnimatedSprite:noLoop()
    self.loop.shouldLoop = false
    --self:setFrame(1)
end

function AnimatedSprite:stopAtFrame(frame)
    if self.loop.frame == frame then
        self:pauseAtFrame(frame)
    end
end

function AnimatedSprite:update()
    if self.loop.frame == #self.sprites and self.numLoops > 0 then
        self.counter += 30/self.timing
    end
    if math.floor(self.counter + 0.5) >= self.numLoops and self.numLoops > 0 then
        self.loopFinished = true
        self:pause()
    else 
        self:animateSprite()
    end
end