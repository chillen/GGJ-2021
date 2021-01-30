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
	area_descs["AREA_00"] = "You are dimly aware of strange life all around you, but the angry snarl of a not so distant beast wrenches you from your stupor. You are in a dense forest, surrounded by the menacing shadows of twisted trees. As the savage sounds grow to a chorus and start to draw closer, you know that you are no longer safe here."
	area_descs["AREA_01"] = "Hands outstretched, you race away from the howling darkness. Branches claw at your face and you nearly stumble on the thick roots, but you know that falling now will mean certain death."
	area_descs["AREA_02"] = "Your heart hammers your chest as the blood roars through your veins. You can see fractured moonlight through the trees ahead, but the thundering hoofbeats tell you that the beasts are nearly upon you."
	area_descs["AREA_03"] = "You throw yourself into the clearing at the last moment. You can feel the hateful eyes at your back but it seems that they will not follow you out of the denser part of the forest. But as your eyes adjust to the light, your relief is replaced by a dread that you cannot explain."
	area_descs["AREA_04"] = "You are inside the first room. Or you would be, at least, if this game was finished. But it isn't, so here is a picture of Rob. Something about his smug expression enrages you, and you have an irresistable urge to PUNCH him."
	area_descs["AREA_05"] = "You are on the east side of the room."
	area_descs["AREA_06"] = "You are on the west side of the room."
	area_descs["AREA_07"] = "Punching Rob was childish, but because you took the initiative, we are now granting you the ability to move about the world freely. You know what to do."

	# a "flag" can indicate if an area has already been visited or if a special effect is to occur (upon entry)
	area_flags["AREA_00"] = []
	area_flags["AREA_01"] = []
	area_flags["AREA_02"] = []
	area_flags["AREA_03"] = [
							"trigger fp_still_image mode",
							"cutscene intro_walking"]
	area_flags["AREA_04"] = []
	area_flags["AREA_05"] = []
	area_flags["AREA_06"] = []
	area_flags["AREA_07"] = ["trigger fp_free_look mode"]

	# a "hint" really is just an additional text entry played when an area is entered
	area_hints["AREA_00"] = "You have no choice but to run."
	area_hints["AREA_01"] = "You have no choice but to run."
	area_hints["AREA_02"] = "You have no choice but to run."
	area_hints["AREA_03"] = "But there is a familiarity to this scene that you cannot explain, and you suspect that you may have something in your INVENTORY that can help you."
	area_hints["AREA_04"] = ""
	area_hints["AREA_05"] = ""
	area_hints["AREA_06"] = ""
	area_hints["AREA_07"] = ""

	# an "exit" pairs a command with the identifier for the area that you will reach if you issue that command
	area_exits["AREA_00"] = {"RUN": "AREA_01"}
	area_exits["AREA_01"] = {"RUN": "AREA_02"}
	area_exits["AREA_02"] = {"RUN": "AREA_03"}
	area_exits["AREA_03"] = {"OPEN DOOR": "AREA_04"}
	area_exits["AREA_04"] = {"W": "AREA_05", "E": "AREA_06", "PUNCH ROB": "AREA_07"}
	area_exits["AREA_05"] = {"E": "AREA_04"}
	area_exits["AREA_06"] = {"W": "AREA_04"}
	area_exits["AREA_07"] = {}

	# a "fail" is a text entry displayed when the user does a specific command that, while normally valid, will not work for some reason
	# a "fail" that is associated with a "gate" can be removed once the "gate" is opened
	area_fails["AREA_00"] = [
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
	area_fails["AREA_01"] = [
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
	area_fails["AREA_02"] = [
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
	area_fails["AREA_03"] = [
		[
			"OPEN DOOR",
			"Even with a crowbar you would not be able to force this lock. There is no way in without a KEY."
		],
		[
			"*",
			"You are thoroughly consumed by the need to OPEN this door, and you dare not return to the forest anyway..."
		]
	]
	area_fails["AREA_04"] = []
	area_fails["AREA_05"] = []
	area_fails["AREA_06"] = []
	area_fails["AREA_07"] = []

	# a "gate" is a bit of an abstract concept here, but each "gate" groups an action (action + object), a text description, and an "exit" (that ends up being added to the current area)
	# the exit action + object also needs to be removed from area_fails
	# e.g., in area_03, the command "USE KEY", will print the description "Finally reunited...", and then add ["OPEN DOOR", "AREA_04"] as an exit to area_03
	area_gates["AREA_00"] = []
	area_gates["AREA_01"] = []
	area_gates["AREA_02"] = []
	area_gates["AREA_03"] = [
		[
			"USE KEY",
			"Finally reunited with the strange key, the lock snaps open. You should be able to OPEN the door now.",
			["OPEN DOOR", "AREA_04"]
		]
	]
	area_gates["AREA_04"] = []
	area_gates["AREA_05"] = []
	area_gates["AREA_06"] = []
	area_gates["AREA_07"] = []

	# these are the locations of the items
	area_items["AREA_00"] = []
	area_items["AREA_01"] = []
	area_items["AREA_02"] = []
	area_items["AREA_03"] = ["DOOR"]
	area_items["AREA_04"] = []
	area_items["AREA_05"] = []
	area_items["AREA_06"] = []
	area_items["AREA_07"] = []

	# these are the short descriptions of the items, used for inventory (and upon changing areas)
	item_names["DOOR"] = "a heavy wooden door"
	item_names["KEY"] = "a silver key"

	# these are the long descriptions of the items, shown when the player "LOOKS" at the item
	item_descs["DOOR"] = "Cast iron bands desperately grip this heavy oak door, and the curious sigil burned into the planks seems to beckon you inside. Unfortunately, it also bears an impressive warded lock."
	item_descs["KEY"] = "The blade of this ancient silver key has been cut to resemble a glyph from some exotic alphabet. You seem to recall once reading something about a silver key, but this probably isn't it."

	# items can be portable (or not), and portable items are either consumed, retained, or discarded upon use
	item_flags["DOOR"] = []
	item_flags["KEY"] = ["portable", "consumed"]

	# initialize the important values for the "player"
	curr_area = "AREA_00"
	inventory = ["KEY"]
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
	input_string = input_string.trim_prefix(">").trim_prefix(" ").trim_suffix(" ").to_upper()

	# translate the input by using known synonyms and dropping words that are not important (i.e., the, that, a, etc.)
	input_string = input_string.replace(" the ", " ")
	input_string = input_string.replace(" a ", " ")
	input_string = input_string.replace(" to ", " ")
	input_string = input_string.replace(" towards ", " ")
	input_string = input_string.replace(" away ", " ")
	input_string = input_string.replace(" from ", " ")

	input_string = input_string.split(" ", false, 1)
	var input_action = input_string[0]
	var input_object = ""
	if len(input_string) > 1:
		input_object = input_string[1]

	var fail_encountered = false
	var fail_text = ""
	
	if len(area_fails[curr_area]) > 0:
		
		for fail_details in area_fails[curr_area]:
			if fail_details[0] == (input_action + " " + input_object).trim_suffix(" "):
				fail_encountered = true
				fail_text = fail_details[1]
				break
			
#		if not fail_encountered:
#
#			for fail_details in area_fails[curr_area]:
#				if fail_details[0] == "*":
#					fail_encountered = true
#					fail_text = fail_details[1]
#					break
		
	if fail_encountered:
		terminal_handle.print_to_terminal(fail_text)
		
	else:

		if (input_action + " " + input_object) in area_exits[curr_area]:
			# this needs to be its own function...
			curr_area = area_exits[curr_area][input_action + " " + input_object]

			var pos3d_ref = get_node("/root/Main/FirstPersonViewport/GameWorld/" + curr_area)
			if not (pos3d_ref == null):
				player_handle.transform = pos3d_ref.transform

		# this is the "update" stage of the text adventure game loop
		elif input_action == "LOOK":
			if input_object in area_items[curr_area]:
				terminal_handle.print_to_terminal(item_descs[input_object])
			elif input_object in inventory:
				terminal_handle.print_to_terminal(item_descs[input_object])

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

		elif input_action == "DROP":
			pass

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

		elif input_action in ["RUN", "NORTH", "SOUTH", "EAST", "WEST"]:
			if input_action in area_exits[curr_area]:
				curr_area = area_exits[curr_area][input_action]
				var pos3d_ref = get_node("/root/Main/FirstPersonViewport/GameWorld/" + curr_area)
				if not (pos3d_ref == null):
					player_handle.position = pos3d_ref.position

			elif input_action == "RUN":
				terminal_handle.print_to_terminal("Where do you think you can run?")

			else:
				terminal_handle.print_to_terminal("You can't go in that direction.")

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

		if len(area_items[curr_area]) > 0:
			var items_in_area = []
			for item in area_items[curr_area]:
				items_in_area.append(item_names[item])
			terminal_handle.print_to_terminal(list_to_nice_string(items_in_area))

	terminal_handle.print_to_terminal(">")
	
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
				print("cutscene")
				emit_signal("cutscene", arguments[1])

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
