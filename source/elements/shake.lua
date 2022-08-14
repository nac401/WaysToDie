local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Shake').extends()

function Shake:init(sprite)
    self.sprite = sprite
    if self.sprite ~= nil then
        self.x = self.sprite.x
        self.y =  self.sprite.y
    end
    self.shakeAmount = 0
end

function Shake:update()
    if self.sprite ~= nil and self.shakeAmount > 0 then
        local shakeAngle = math.random()*math.pi*2;
        shakeX = math.floor(math.cos(shakeAngle)*self.shakeAmount);
        shakeY = math.floor(math.sin(shakeAngle)*self.shakeAmount);
        self.shakeAmount -= 1
        self.sprite:moveTo(self.x + shakeX,  self.y + shakeY)
    elseif self.sprite ~= nil then
        self.sprite:moveTo(self.x, self.y)
    else
        if self.shakeAmount > 0 then
            local shakeAngle = math.random()*math.pi*2;
            shakeX = math.floor(math.cos(shakeAngle)*self.shakeAmount);
            shakeY = math.floor(math.sin(shakeAngle)*self.shakeAmount);
            self.shakeAmount -= 1
            pd.display.setOffset(shakeX, shakeY)
        else
            pd.display.setOffset(0, 0)
        end
    end
end

function Shake:transition(sprite)
    if sprite ~= nil then
        self.sprite:moveTo(self.x, self.y)
        self.sprite = sprite
        self.x = self.sprite.x
        self.y =  self.sprite.y
        self.shakeAmount = 0
    else
        return
    end
end

function Shake:cleanUp()
    if self.sprite ~= nil then
        self.sprite:remove()
    end
end