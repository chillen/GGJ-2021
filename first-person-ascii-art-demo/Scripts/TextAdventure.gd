extends Node

var area_descs = {}
var area_flags = {}
var area_hints = {}
var area_exits = {}
var area_fails = {}
var area_gates = {}
var area_items = {}

var item_names = {}
var item_descs = {}
var item_flags = {}

var curr_area
var inventory

onready var terminal_handle: Node = $"/root/Main/Terminal"
onready var player_handle: Node = $"/root/Main/FirstPersonViewport/GameWorld/Player"
onready var masktimer_handle: Node = $"/root/Main/MaskTimer"

onready var is_debug_mode_on = get_node("/root/BlackBoard").DEBUG

signal cutscene


func _ready():
	# a "desc" is a long description of an area
	area_descs["FOREST_01"] = "You are dimly aware of strange life all around you, but the angry snarl of a not so distant beast wrenches you from your stupor. You are in a dense forest, surrounded by the menacing shadows of twisted trees. As the savage sounds grow to a chorus and start to draw closer, you know that you are no longer safe here."
	area_descs["FOREST_02"] = "Hands outstretched, you race away from the howling darkness. Branches claw at your face and you nearly stumble on the thick roots, but you know that falling now will mean certain death."
	area_descs["FOREST_03"] = "Your heart hammers your chest as the blood roars through your veins. You can see fractured moonlight through the trees ahead, but the thundering hoofbeats tell you that the beasts are nearly upon you."
	area_descs["EXT_DOOR"] = "You throw yourself into the clearing at the last moment. Even though you can still feel hateful eyes at your back, it seems that your pursuers will not follow you out of the denser part of the forest. But your relief is quickly overshadowed by the building that looms before you. A voice from your own forgotten history tells you that it has been constructed in the style of the ancient lemurians. You dare not try to explain its presence here, far from the shifting sands. Perhaps it is the fear of this monument to a forgotten age that keeps the beasts of the forest at bay. Even still, you would feel more comfortable with that heavy door between you and the night."
	area_descs["ANTE_CAMP"] = "The warmth exhaled from the antechamber banishes the chill in the night air. Much of the detail on the statue here has been consumed by time, but you are still able to recognize the winged being that was depicted here. Faint wisps of smoke rise from the torches on either side, suggesting that they were hastily extinguished only a short time ago. Not wanting to disturb the site, you make your way towards one corner of the room, suddenly finding yourself standing in the remains of a small basecamp."
	area_descs["ANTE_W_BRAZIER"] = "The cast iron brazier before you can barely contain its crackling flames, and the fact that the brazier is lit at all suggests that you are not alone in this temple. The other brazier is on the eastern side of the room, and the camp is against the southern wall by the entrance."
	area_descs["ANTE_E_BRAZIER"] = "It would appear that this brazier was hastily extinguished only a short while ago. You can see a tin-plated canteen half buried in the still warm coals, but you have little use for an empty canteen. The other brazier  is on the western side of the room, and the camp is against the southern wall by the entrance."

	# a "flag" can indicate if an area has already been visited or if a special effect is to occur (upon entry)
	area_flags["FOREST_01"] = []
	area_flags["FOREST_02"] = []
	area_flags["FOREST_03"] = []
	area_flags["EXT_DOOR"] = [
							"trigger fp_still_image mode",
							"cutscene intro_walking"]
	area_flags["ANTE_CAMP"] = []
	area_flags["ANTE_W_BRAZIER"] = []
	area_flags["ANTE_E_BRAZIER"] = []


	# a "hint" really is just an additional text entry played when an area is entered
	area_hints["FOREST_01"] = "You have no choice but to run."
	area_hints["FOREST_02"] = "You have no choice but to run."
	area_hints["FOREST_03"] = "You have no choice but to run."
	area_hints["EXT_DOOR"] = ""
	area_hints["ANTE_CAMP"] = "You now realize that you have been moving as though in a deep trance. Taking a few deep breaths, you force your limbs to relax. (Use your mouse to look around, WASD to move, and left-click to interact.) "
	area_hints["ANTE_W_BRAZIER"] = ""
	area_hints["ANTE_E_BRAZIER"] = ""

	# an "exit" pairs a command with the identifier for the area that you will reach if you issue that command
	area_exits["FOREST_01"] = {"RUN": ["FOREST_02", "no cutscene"]}
	area_exits["FOREST_02"] = {"RUN": ["FOREST_03", "no cutscene"]}
	area_exits["FOREST_03"] = {"RUN": ["EXT_DOOR", "no cutscene"]}
	area_exits["EXT_DOOR"] = {}
	area_exits["ANTE_CAMP"] = {"W": ["ANTE_W_BRAZIER", "ante_camp_to_ante_w_brazier"], "E": ["ANTE_E_BRAZIER", "ante_camp_to_ante_e_brazier"]}
	area_exits["ANTE_W_BRAZIER"] = {"S": ["ANTE_CAMP", "ante_w_brazier_to_ante_camp"], "E": ["ANTE_E_BRAZIER", "ante_w_brazier_to_ante_e_brazier"]}
	area_exits["ANTE_E_BRAZIER"] = {"S": ["ANTE_CAMP", "ante_e_brazier_to_ante_camp"], "W": ["ANTE_W_BRAZIER", "ante_e_brazier_to_ante_w_brazier"]}

	# a "fail" is a text entry displayed when the user does a specific command that, while normally valid, will not work for some reason
	# a "fail" that is associated with a "gate" can be removed once the "gate" is opened
	area_fails["FOREST_01"] = [
		["*", "There's no time for that now."],
		[
			"NORTH",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"SOUTH",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"EAST",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"WEST",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		]
	]
	area_fails["FOREST_02"] = [
		["*", "There's no time for that now."],
		[
			"NORTH",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"SOUTH",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"EAST",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"WEST",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		]
	]
	area_fails["FOREST_03"] = [
		["*", "There's no time for that now."],
		[
			"NORTH",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"SOUTH",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"EAST",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		],
		[
			"WEST",
			"The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."
		]
	]
	area_fails["EXT_DOOR"] = [
		[
			"OPEN DOOR",
			"Even with a crowbar you would not be able to force this stone slab out of the way. Perhaps you should LOOK over the door more closely."
		],
		[
			"*",
			"You are thoroughly consumed by the need to OPEN this door, and you dare not return to the forest anyway..."
		]
	]
	area_fails["ANTE_CAMP"] = []
	area_fails["ANTE_W_BRAZIER"] = []
	area_fails["ANTE_E_BRAZIER"] = []

	# a "gate" is a bit of an abstract concept here, but each "gate" groups an action (action + object), a text description, and an "exit" (that ends up being added to the current area)
	# the exit action + object also needs to be removed from area_fails
	# e.g., in area_03, the command "USE KEY", will print the description "Finally reunited...", and then add ["OPEN DOOR", "AREA_04"] as an exit to area_03
	area_gates["FOREST_01"] = []
	area_gates["FOREST_02"] = []
	area_gates["FOREST_03"] = []
	area_gates["EXT_DOOR"] = [
		[
			"SAY PLEASE",
			"As you shape your lips to speak, your mouth suddenly goes dry and you feel the curious sensation of insects crawling over your tongue. Although it was your intention to plead for entry, your ears heard only the word \"ahlloigehye\" in a voice that you no longer recognize as your own. But the guardian of this temple seems satisfied, and you suspect that you will now be able to open the door.",
			["OPEN DOOR", ["ANTE_CAMP", "ext_door_to_ante_camp"]]
		]
	]
	area_gates["ANTE_CAMP"] = []
	area_gates["ANTE_W_BRAZIER"] = []
	area_gates["ANTE_E_BRAZIER"] = []

	# these are the locations of the items
	area_items["FOREST_01"] = []
	area_items["FOREST_02"] = []
	area_items["FOREST_03"] = []
	area_items["EXT_DOOR"] = ["DOOR"]
	area_items["ANTE_CAMP"] = ["UNLITTORCH"]
	area_items["ANTE_W_BRAZIER"] = []
	area_items["ANTE_E_BRAZIER"] = []

	# these are the short descriptions of the items, used for inventory (and upon changing areas)
	item_names["DOOR"] = "a heavy wooden door"
	item_names["PAGE"] = "a page that was torn from a journal"
	item_names["UNLITTORCH"] = "an unlit torch"
	item_names["LITTORCH"] = "a lit torch"
	
	# these are the long descriptions of the items, shown when the player "LOOKS" at the item
	item_descs["DOOR"] = "There are telltale signs of the crude tools once used to cut this great stone door, but you can find no evidence of a lock or hinges. As you inspect more closely, your gaze is drawn inexplicably to the green stone in the center. A hush falls over the forest, and you cannot help but feel that the stone is... Listening... There is a familiarity to this scene that you cannot explain, and you suspect that you may have something in your inventory that might help."
	item_descs["PAGE"] = "It was not unreasonable to hope that this page held some clue to your lost identity, but this was not the case. It appears to be a page torn from an expedition journal. The tone is academic, and most of the details recorded would be of little use, but one passage in particular echoes in your mind. \"Their savage rituals notwithstanding, the woshippers of the H' ahf' Mggoka were always strangely courteous with outsiders. When i bore this in mind, it became quite clear why the warden stone paid no heed to words like open or unlock. All I needed to do was to remember my manners and ask nicely.\""
	item_descs["UNLITTORCH"] = "There are flakes of burnt parchment throughout the area, and you suspect this torch to be the culprit. It is not currently lit."
	item_descs["LITTORCH"] = "The torch is burning brightly now."

	# items can be portable (or not), and portable items are either consumed, retained, or discarded upon use
	item_flags["DOOR"] = []
	item_flags["PAGE"] = ["portable", "consumed"]
	item_flags["UNLITTORCH"] = ["portable"]
	item_flags["LITTORCH"] = ["portable"]

	# initialize the important values for the "player"
	curr_area = "FOREST_01"
	inventory = ["PAGE"]
	area_flags[curr_area].append("visited")

	# print the initial room description
	terminal_handle.print_to_terminal(area_descs[curr_area])
	if not area_hints[curr_area] == "":
		terminal_handle.print_to_terminal(area_hints[curr_area])

	# print the terminal prompt
	terminal_handle.print_to_terminal(">")

	if is_debug_mode_on:
		masktimer_handle.start(0)
		player_handle.user_input_state = player_handle.UserInputMode.FP_FREE_LOOK
		
	# This is an example of emitting a cutscene request to player,
	# it will allow for different animations to be called from the text adveture if needed
	# emit_signal("cutscene", "intro_walking")


func play(input_string):
	
	# replace with rlyehian, even if we are just playing the text adventure
	# n.b., we might not actually need this	
	var phrase_entered = terminal_handle.screen_buffer_data[terminal_handle.last_buffered_row].trim_prefix(">").trim_suffix(" ")
	if phrase_entered in terminal_handle.english_to_rlyehian:
		terminal_handle.replace_with_rlyehian(terminal_handle.english_to_rlyehian[phrase_entered])
	
	# trim the unwanted characters from the string taken from the terminal
	input_string = " " + input_string.trim_prefix(">").trim_prefix(" ").trim_suffix(" ").to_upper() + " "

	# translate the input by using known synonyms and dropping words that are not important (i.e., the, that, a, etc.)
	var punctuation_marks = [".", ",", "!", "\"", "'"]
	var junk_words = ["AT", "THE", "A", "AN", "TO", "TOWARDS", "AWAY", "FROM", "MY", "OUT", "FOREST", "CLOSELY", "AROUND"]
	var synonyms = [
		["LEAVE", "RUN"],
		["EXIT", "RUN"],
		["WALK", "RUN"],
		["MOVE", "RUN"],
		["ESCAPE", "RUN"],
		["FLEE", "RUN"],
		["N", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["E", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["S", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["W", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["NORTH", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["EAST", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["SOUTH", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["WEST", "RUN"], # this would need to be removed if we end up using the text adventure interface for the torch puzzles
		["EXAMINE", "LOOK"],
		["INSPECT", "LOOK"],
		["LOOK SELF", "INVENTORY"],
		["LOOK INVENTORY", "INVENTORY"],
		["CHECK INVENTORY", "INVENTORY"],
		["CHECK EQUIPMENT", "INVENTORY"],
		["READ", "LOOK"],
		["ASK NICELY", "SAY PLEASE"],
		["SPEAK", "SAY"],
		["TORN JOURNAL PAGE", "PAGE"],
		["TORN PAGE", "PAGE"],
		["JOURNAL PAGE", "PAGE"],
		["JOURNAL", "PAGE"],
		["PAGES", "PAGE"],
		["HEAVY DOOR", "DOOR"],
		["HEAVY STONE DOOR", "DOOR"],
		["STONE DOOR", "DOOR"],
		["OPEN INVENTORY", "INVENTORY"]
	]
	
	for punctuation_mark in punctuation_marks:
		input_string = input_string.replace(punctuation_mark, "")
		
	for junk_word in junk_words:
		input_string = input_string.replace(" " + junk_word + " ", " ")
	print(input_string)
	for synonym_pair in synonyms:
		var synonym = synonym_pair[0]
		var replacement = synonym_pair[1]
		input_string = input_string.replace(" " + synonym + " ", " " + replacement + " ")
	print(input_string)

	input_string = input_string.trim_prefix(" ").trim_suffix(" ")
	input_string = input_string.split(" ", false, 1)
	
	print(input_string)
	
	var input_action = input_string[0]
	var input_object = ""
	if len(input_string) > 1:
		input_object = input_string[1]

	var fail_encountered = false
	var fail_text = ""

	if input_action == "OPEN" and input_object == "":
		input_object = "DOOR"
	
	if len(area_fails[curr_area]) > 0:

					
		for fail_details in area_fails[curr_area]:
			if fail_details[0] == (input_action + " " + input_object).trim_suffix(" "):
				fail_encountered = true
				fail_text = fail_details[1]
				break
		
	if fail_encountered:
		terminal_handle.print_to_terminal(fail_text)
		
	else:

		if (input_action + " " + input_object).trim_suffix(" ") in area_exits[curr_area]:

			var selected_exit = area_exits[curr_area][(input_action + " " + input_object).trim_suffix(" ")]
			curr_area = selected_exit[0]
			var cutscene_title = selected_exit[1]
#			var pos3d_ref = get_node("/root/Main/FirstPersonViewport/GameWorld/" + curr_area)
#			if not (pos3d_ref == null):
#				player_handle.position = pos3d_ref.position
			emit_signal("cutscene", cutscene_title)	
			
			# and now it gets klugey...
			
			if cutscene_title == "ext_door_to_ante_camp":
				$"/root/Main/FirstPersonViewport/GameWorld/EntryRoom/DoorTemplate".open()
			
			

		# this is the "update" stage of the text adventure game loop
		elif input_action == "LOOK":
			if input_object in area_items[curr_area]:
				terminal_handle.print_to_terminal(item_descs[input_object])
			elif input_object in inventory:
				terminal_handle.print_to_terminal(item_descs[input_object])
			else:
				terminal_handle.print_to_terminal("WHAT DO YOU WANT TO LOOK AT?")

		elif input_action == "SAY" or input_action == "PLEASE":
			
			if input_action == "PLEASE":
				input_action = "SAY"
				input_object = "PLEASE"
					
			# check each of the "gates" in the area to see if one has been removed by this "use"
			var had_effect = false
			for gate_details in area_gates[curr_area]:
				
				if gate_details[0] == input_action + " " + input_object:
					had_effect = true
					terminal_handle.print_to_terminal(gate_details[1])
					
					if gate_details[2] != []:
						area_exits[curr_area][gate_details[2][0]] = gate_details[2][1]
						for fail_details in area_fails[curr_area]:
							if fail_details[0] == gate_details[2][0]:
								area_fails[curr_area].erase(fail_details)
								break

#		elif input_action == "LIGHT" and input_object == "TORCH":
#			# if the object is in the players inventory
#			if "UNLITTORCH" in inventory and curr_area == "ANTE_W_BRAZIER":
#				inventory.erase("UNLITTORCH")
#				inventory.append("LITTORCH")
				
		elif input_action == "USE":
			# if the object is in the players inventory
			if input_object in inventory:
				
				# check each of the "gates" in the area to see if one has been removed by this "use"
				var had_effect = false
				for gate_details in area_gates[curr_area]:
					if gate_details[0] == input_action + " " + input_object:
						had_effect = true
						terminal_handle.print_to_terminal(gate_details[1])
						
						if gate_details[2] != []:
							area_exits[curr_area][gate_details[2][0]] = gate_details[2][1]
							for fail_details in area_fails[curr_area]:
								if fail_details[0] == gate_details[2][0]:
									area_fails[curr_area].erase(fail_details)
									break

				# if using this object doesn't do anything, say so
				if had_effect == false:
					terminal_handle.print_to_terminal("That doesn't accomplish anything.")

			# otherwise, if the object is not in the player's inventory...
			else:
				# if it is in the room tell the player to pick it up (if portable) or ignore it
				if input_object in area_items[curr_area]:
					if "portable" in item_flags[input_object]:
						terminal_handle.print_to_terminal(
							(
								"You will first need to TAKE the "
								+ input_object
								+ " if you intend to use it."
							)
						)
					else:
						terminal_handle.print_to_terminal(
							"You won't be able to use the " + input_object + "."
						)

				# if it isn't in the room
				else:
					terminal_handle.print_to_terminal("You don't have any " + input_object + " to use.")

		elif input_action == "MATT":
			masktimer_handle.start(0.01)
			player_handle.transform.origin = Vector3(155.58,0,54.084)
			$"/root/Main/FirstPersonViewport/GameWorld/EntryRoom/Torch"._on_Interactable_interacted("take", player_handle)
			player_handle.user_input_state = player_handle.UserInputMode.FP_FREE_LOOK

		elif input_action == "CONNOR":
			masktimer_handle.start(0.01)
			player_handle.transform.origin = Vector3(-.1, 0, 50)
			$"/root/Main/FirstPersonViewport/GameWorld/EntryRoom/Torch"._on_Interactable_interacted("take", player_handle)
			player_handle.user_input_state = player_handle.UserInputMode.FP_FREE_LOOK
			
		elif input_action == "TAKE":
			area_items[curr_area].erase(input_object)
			inventory.append(input_object)

		elif input_action == "INVENTORY":
			match len(inventory):
				0:
					terminal_handle.print_to_terminal("You aren't carrying anything.")

				1:
					terminal_handle.print_to_terminal(
						"You are carrying " + item_names[inventory[0]] + "."
					)

				2:
					terminal_handle.print_to_terminal(
						(
							"You are carrying "
							+ item_names[inventory[0]]
							+ " and "
							+ item_names[inventory[1]]
							+ "."
						)
					)

				_:  # obviously this needs to be rewritten, as it only works for a maximum of 3 items...
					terminal_handle.print_to_terminal(
						(
							"You are carrying "
							+ item_names[inventory[0]]
							+ ", "
							+ item_names[inventory[1]]
							+ ", and "
							+ item_names[inventory[2]]
						),
						"."
					)

		elif input_action == "HELP":
			terminal_handle.print_to_terminal("Haven't you ever played a text adventure game?")

		elif input_action == "EXIT":
			terminal_handle.print_to_terminal("Are you even allowed to quit the game at this stage?")

		else:
			terminal_handle.print_to_terminal("I don't understand what you mean...")

	# this is the "render" stage of the text adventure game loop	
	if not ("visited" in area_flags[curr_area]):
		area_flags[curr_area].append("visited")
		terminal_handle.print_to_terminal(area_descs[curr_area])
		
		if not area_hints[curr_area] == "":
			terminal_handle.print_to_terminal(area_hints[curr_area])

# I don't need to describe items in the scene any more
#		if len(area_items[curr_area]) > 0:
#			var items_in_area = []
#			for item in area_items[curr_area]:
#				if "portable" in item_flags[item]:
#					items_in_area.append(item_names[item])
#			if len(items_in_area) > 0: 
#				terminal_handle.print_to_terminal(list_to_nice_string(items_in_area))

		for command in area_flags[curr_area]:
			var arguments = command.split(" ")
			match arguments[0]:
				"trigger":
					match arguments[1]:
						"fp_still_image":
							player_handle.user_input_state = player_handle.UserInputMode.FP_STILL_IMG
							masktimer_handle.start(2)
						"fp_free_look":
							player_handle.user_input_state = player_handle.UserInputMode.FP_FREE_LOOK
							
				"cutscene":
					emit_signal("cutscene", arguments[1])
					
	terminal_handle.print_to_terminal(">")

func list_to_nice_string(list):
	if len(list) == 1:
		return list[0]
	elif len(list) == 2:
		return list[0] + " and " + list[1]
	else:
		var nice_string = ""
		for i in range(len(list) - 1):
			nice_string += list[i] + ", "
		return nice_string + "and " + list[len(list) - 1]
