--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

class('Menu').extends()

function Menu:init(options)
    self.options = options
    self.numOptions = #self.options
    self.selectedOption = 1
    self.optionGrid = playdate.ui.gridview.new(25, 15)
    self.menuImage = gfx.image.new(100, 100)
    self.menuSprite = gfx.sprite.new(self.menuImage)
    self.menuSprite:setZIndex(50)
    self.menuSprite:add()

    --create input handler for menu options
    self.menuInputHandler = {
        downButtonUp = function()
            self.optionGrid:selectNextRow(true)
            self.selectedOption += 1
            if self.selectedOption > self.numOptions then
                self.selectedOption = 1
            end
            self:draw()
        end,
        upButtonUp = function()
            self.optionGrid:selectPreviousRow(true)
            self.selectedOption -= 1
            if self.selectedOption < 1 then
                self.selectedOption = self.numOptions
            end
            self:draw()
        end,
        AButtonDown = function()
            selectedID = self.options[self.selectedOption]
        end
    }
end

function Menu:draw()
    gfx.setFont(smallFont)
    self.optionGrid.options = self.options
    self.optionGrid:setNumberOfRows(self.numOptions)
    self.optionGrid:setCellPadding(0, 0, 5, 5)
    self.optionGrid:setContentInset(25, 25, 6, 6)
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    function self.optionGrid:drawCell(section, row, column, selected, x, y, width, height)     
        if selected then
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
            gfx.drawText("> ", x, y)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.drawText("> ", x, y)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        end
        gfx.drawText(self.options[row], x + 10, y)
       
    end

    gfx.pushContext(self.menuImage)
        self.optionGrid:drawInRect(0, 0, 400, 200)
    gfx.popContext()
    self.menuSprite:setImage(self.menuImage)
    self.menuSprite:moveTo(185, 225)
end

function Menu:cleanUp()
    self.menuSprite:remove()
    pd.inputHandlers.pop()
    gfx.setColor(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end