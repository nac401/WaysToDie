import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/animation"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import 'CoreLibs/crank'
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import "scenes/menuscenes"
import "scenes/demo"
import "scenes/act1"
import "scenes/template"

import "printer/dialogue"

import "elements/animatedsprite"
import "elements/shake"
import "elements/transition"

import "minigames/performance/performance"
import "minigames/recall/recall"
import "minigames/access/access"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--initialize helpful global functions and variables
centerPoint = pd.geometry.point.new(200, 120)
centerX = 200
centerY = 120

--global screenshake
screenshake = Shake()

load = pd.datastore.read("save")

--initialize function for testing
local function initialize()
	selectedID = "mainmenu"
	transitioner = Transition("", "")
	currentScene = selectedID
	scene[currentScene]["initialize"]()
end
--run initialize function once before runtime
initialize()

--test init
local endings = {"genericSuccess", "genericFail"}
test = Recall(2, 2, 2, endings)

--our treasured update function, hallowed be thy name
function playdate.update()	
	--update screenshake
	screenshake:update()
	--check for transitions between scenes
	transitioner:update()
	
	--run current scene
	--scene[currentScene]["running"]()

	--run test minigame
	test:update()
	
	--update sprites and timers
	gfx.sprite.update()
	pd.timer.updateTimers()
end