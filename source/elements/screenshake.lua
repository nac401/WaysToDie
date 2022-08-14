local pd <const> = playdate
local gfx <const> = playdate.graphics

class('ScreenShake').extends(gfx.sprite)

function ScreenShake:init()
    shakeAmount = 0
    self:add()
end

function ScreenShake:update()
    if shakeAmount > 0 then
        local shakeAngle = math.random()*math.pi*2;
        shakeX = math.floor(math.cos(shakeAngle)*shakeAmount);
        shakeY = math.floor(math.sin(shakeAngle)*shakeAmount);
        shakeAmount -= 1
        pd.display.setOffset(shakeX, shakeY)
    else
        pd.display.setOffset(0, 0)
    end
end