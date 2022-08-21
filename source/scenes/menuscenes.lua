import "elements/menu"
import "scenes/template"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--music
local titleMusic = playdate.sound.fileplayer.new("sounds/music/ManyWaysToDie")

scene["mainmenu"] = {
	initialize = function()
		local menuImageTable = {}
			for i = 1, 5 do
				menuImageTable[i] = gfx.imagetable.new("images/titles/MainTitle1")
			end
			menuImageTable[6] = gfx.imagetable.new("images/titles/MainTitle2")
			menuImageTable[7] = gfx.imagetable.new("images/titles/MainTitle3")
			menuImageTable[8] = gfx.imagetable.new("images/titles/MainTitle4")
			menuImageTable[9] = gfx.imagetable.new("images/titles/MainTitle5")
			menuImageTable[10] = gfx.imagetable.new("images/titles/MainTitle6")
		local randomSelector = math.random(1, 10)

		mainMenu = AnimatedSprite(menuImageTable[randomSelector])
		mainMenu:add()
		mainMenu:moveTo(200, 120)

		local options = {"new game", "continue"}
		menuOptions = Menu(options)
		seeMenu = false

		--play music
		titleMusic:stop()
		titleMusic = playdate.sound.fileplayer.new("sounds/music/ManyWaysToDie")
		titleMusic:play()
	end,

	running = function()
		if seeMenu == true then
			menuOptions:draw()
		end
		if selectedID == "continue" then
			if load ~= nil then
				selectedID = load["saveID"]
			else
				print("DATA CORRUPTED, STARTING NEW GAME.")
				selectedID = start
			end
			sceneTransition(selectedID)
		elseif selectedID == "new game" then
			selectedID = start
			sceneTransition(selectedID)
		end
		if pd.buttonJustPressed(pd.kButtonA) and  seeMenu == false then
			seeMenu = true
			pd.inputHandlers.push(menuOptions.menuInputHandler)
			mainMenu:pauseAtFrame(1)
		end
	end,

	terminate = function()
		mainMenu:remove()
		menuOptions:cleanUp()
		titleMusic:setVolume(0, 0, 1)
	end
}