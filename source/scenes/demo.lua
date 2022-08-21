import "scenes/template"

--constants and shortcuts
local pd <const> = playdate
local gfx <const> = pd.graphics

--MAIN TEST HUB
scene["mainTest"] = {
	initialize = function()
		local dialogue = 	{ 
			"Choose from the options below for what test to run."
			}
		local prompts = 	{
			"Examples of text!", 
			"Performance Minigame", 
			"Recall Minigame", 
			"Access Minigame"
		}
		local answers = 	{
			"textTest1", 
			"performanceMenu", 
			"recallMenu",
			"accessMenu"
		}
		transitioner:cleanUp()
		thisScene = Dialogue(dialogue, prompts, answers)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "mainTest" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		thisScene:cleanUp()
	end
}

--TEXT TESTING/TEXT SFX TESTS
--only for testing purposes 
scene["textTest1"] = {
	initialize = function()
		local dialogue =    {
			"The quick brown fox jumps over the lazy dog.", 
			"@CRASH!", 
			"#Look out behind you..."
		}
		local prompts =     {
			"Continue Text Test", 
			"Return to Main"
		}
		local answers =     {
			"textTest2", 
			"mainTest"
		}
		thisScene = Dialogue(dialogue, prompts, answers)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "textTest1" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		thisScene:cleanUp()
	end
}

scene["textTest2"] = {
	initialize = function()
		local dialogue =    {
			"All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy. All work and no play makes Jack a dull boy."
		}
		local prompts =     {
			"Continue Text Test", 
			"Return to Main"
		}
		local answers =     {
			"textTest1", 
			"mainTest"
		}
		thisScene = Dialogue(dialogue, prompts, answers)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "textTest2" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		thisScene:cleanUp()
	end
}

--GENERIC SUCCESS/FAIL SCENES
--only for testing purposes 
scene["genericFail"] = {
	initialize = function()
		local dialogue =    {
			"You failed!"
		}
		local prompts =     {
			"To Performance", 
			"To Recall",
			"To Access",
			"Return to Main"
		}
		local answers =     {
			"performanceMenu", 
			"recallMenu",
			"accessMenu",
			"mainTest"
		}
		thisScene = Dialogue(dialogue, prompts, answers)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "genericFail" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		thisScene:cleanUp()
	end
}

scene["genericSuccess"] = {
	initialize = function()
		local dialogue =    {
			"You succeeded!"
		}
		local prompts =     {
			"To Performance", 
			"To Recall",
			"To Access",
			"Return to Main"
		}
		local answers =     {
			"performanceMenu", 
			"recallMenu",
			"accessMenu",
			"mainTest"
		}
		thisScene = Dialogue(dialogue, prompts, answers)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "genericSuccess" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		thisScene:cleanUp()
	end
}

--RECALL TEST GAME SCENES
--EASY, MEDIUM, AND HARD
scene["recallMenu"] = {
	initialize = function()
		local dialogue =    {
			"@Recall Minigame!",
			"Press A to cast.",
			"Use the crank to pull the fish in!"
			}
		local prompts =     {
			"Easy", 
			"Medium", 
			"Hard",
			"Return to Main"
		}
		local answers =     {
			"recallEasy", 
			"recallMedium", 
			"recallHard",
			"mainTest"
		}
		--DIALOGUE: create dialogue scene of parts created above.
		thisScene = Dialogue(dialogue, prompts, answers)
		
		--TRANSITION: create transition and randomly assign text
		transitioner:cleanUp()
		local random = math.random(1, 10)
		local introText = recallText[random]
		transitioner = Transition("RECALL", introText)
		
		--SAVE GAME: save ID and store it in a json
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		--UPDATE: do dialogue scene
		thisScene:update()
		--QUERY: for transition to next scene, game or prompt option
		if selectedID == "mainTest" then
			sceneTransition(selectedID)
		elseif selectedID ~= "recallMenu" then
			transitioner.transitioning = true
			if transitioner.queueLoadIn then
				sceneTransition(selectedID)
			end
		end
	end,

	terminate = function()
		--CLEAN UP: run cleanup function for dialogue
		thisScene:cleanUp()
	end
}

scene["recallEasy"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Recall(1, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "recallEasy" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		thisScene:cleanUp()
		transitioner:cleanUp()
	end
}

scene["recallMedium"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Recall(2, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "recallMedium" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		transitioner:cleanUp()
	end
}

scene["recallHard"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Recall(3, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "recallHard" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		transitioner:cleanUp()
	end
}

--PERFORMANCE TEST GAME SCENES
--EASY, MEDIUM, AND HARD
scene["performanceMenu"] = {
	initialize = function()
		local dialogue =    {
			"@Performance Minigame!",
			"Press the buttons that show up on screen before the time runs out.",
			"Do it enough times and you win!"
			}
		local prompts =     {
			"Easy", 
			"Medium", 
			"Hard",
			"Return to Main"
		}
		local answers =     {
			"performanceEasy", 
			"performanceMedium", 
			"performanceHard",
			"mainTest"
		}
		--DIALOGUE: create dialogue scene of parts created above.
		thisScene = Dialogue(dialogue, prompts, answers)
		
		--TRANSITION: create transition and randomly assign text
		transitioner:cleanUp()
		local random = math.random(1, 10)
		local introText = performanceText[random]
		transitioner = Transition("PERFORMANCE", introText)
		
		--SAVE GAME: save ID and store it in a json
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		--UPDATE: do dialogue scene
		thisScene:update()
		--QUERY: for transition to next scene, game or prompt option
		if selectedID == "mainTest" then
			sceneTransition(selectedID)
		elseif selectedID ~= "performanceMenu" then
			transitioner.transitioning = true
			if transitioner.queueLoadIn then
				sceneTransition(selectedID)
			end
		end
	end,

	terminate = function()
		--CLEAN UP: run cleanup function for dialogue
		thisScene:cleanUp()
	end
}

scene["performanceEasy"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Performance(1, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "performanceEasy" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		transitioner:cleanUp()
	end
}

scene["performanceMedium"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Performance(2, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "performanceMedium" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		transitioner:cleanUp()
	end
}

scene["performanceHard"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Performance(3, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "performanceHard" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		transitioner:cleanUp()
	end
}

--ACCESS TEST GAME SCENES
--EASY, MEDIUM, AND HARD
scene["accessMenu"] = {
	initialize = function()
		local dialogue =    {
			"@Access Minigame!",
			"Use the crank to move your picks.",
			"Press A to switch between them!"
			}
		local prompts =     {
			"Easy", 
			"Medium", 
			"Hard",
			"Return to Main"
		}
		local answers =     {
			"accessEasy", 
			"accessMedium", 
			"accessHard",
			"mainTest"
		}
		--DIALOGUE: create dialogue scene of parts created above.
		thisScene = Dialogue(dialogue, prompts, answers)
		
		--TRANSITION: create transition and randomly assign text
		transitioner:cleanUp()
		local random = math.random(1, 10)
		local introText = accessText[random]
		transitioner = Transition("ACCESS", introText)
		
		--SAVE GAME: save ID and store it in a json
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		--UPDATE: do dialogue scene
		thisScene:update()
		--QUERY: for transition to next scene, game or prompt option
		if selectedID == "mainTest" then
			sceneTransition(selectedID)
		elseif selectedID ~= "accessMenu" then
			transitioner.transitioning = true
			if transitioner.queueLoadIn then
				sceneTransition(selectedID)
			end
		end
	end,

	terminate = function()
		--CLEAN UP: run cleanup function for dialogue
		thisScene:cleanUp()
	end
}

scene["accessEasy"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Access(1, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "accessEasy" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		transitioner:cleanUp()
		thisScene:cleanUp()
	end
}

scene["accessMedium"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Access(2, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
		print("initialize")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "accessMedium" then
			sceneTransition(selectedID)
		end
		print("running")
	end,

	terminate = function()
		transitioner:cleanUp()
		thisScene:cleanUp()
	end
}

scene["accessHard"] = {
	initialize = function()
		local endings = {"genericSuccess", "genericFail"}
		thisScene = Access(3, endings)
		save["saveID"] = selectedID
		pd.datastore.write(save, "save")
	end,

	running = function()
		thisScene:update()
		if selectedID ~= "accessHard" then
			sceneTransition(selectedID)
		end
	end,

	terminate = function()
		transitioner:cleanUp()
		thisScene:cleanUp()
	end
}