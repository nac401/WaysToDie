--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

scene = {}
save = {}

load = pd.datastore.read("save")
start = "mainTest"

scene["template"] = {
	initialize = function()
		local dialogue =    {
			"dialogue1",
			"dialogue2",
			"dialogue3"
			}
		local prompts =     {
			"prompt1", 
			"prompt2", 
			"prompt3"
		}
		local answers =     {
			"answerID1", 
			"answerID2", 
			"answerID3"
		}
		--DIALOGUE: create dialogue scene of parts created above.
		thisScene = Dialogue(dialogue, prompts, answers)
		
		--TRANSITION: create transition and randomly assign text
		transitioner:cleanUp()
		local random = math.random(1, 10)
		local introText = gameText[random]
		transitioner = Transition("GAME", introText)
		
		--SAVE GAME: save ID and store it in a json
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		--UPDATE: do dialogue scene
		thisScene:update()
		--QUERY: for transition to next scene, game or prompt option
		if selectedID == "game" then
			transitioner.transitioning = true
			if transitioner.queueLoadIn then
				sceneTransition(selectedID)
			end
		elseif selectedID ~= "template" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		--CLEAN UP: run cleanup function for dialogue
		thisScene:cleanUp()
	end
}

function sceneTransition(nextScene)
	scene[currentScene]["terminate"]()
	currentScene = nextScene
	scene[currentScene]["initialize"]()
end