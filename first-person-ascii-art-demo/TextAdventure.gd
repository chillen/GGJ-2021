extends Node

var area_descs = {}
var area_flags = {}
var area_hints = {}
var area_exits = {}
var area_gates = {}
var area_locks = {}
var area_items = {}

var item_names = {}
var item_descs = {}

var curr_area = "AREA_00"
var inventory = ["KEY"]

onready var terminal_handle : Node = $"/root/Main/Terminal"
onready var player_handle : Node = $"/root/Main/FirstPersonViewport/GameWorld/Player"
onready var masktimer_handle : Node = $"/root/Main/MaskTimer"

func _ready():
	
	area_descs["AREA_00"] = "You are dimly aware of strange life all around you, but the angry snarl of a not so distant beast wrenches you from your stupor. You are in a dense forest, surrounded by the menacing shadows of twisted trees. As the savage sounds grow to a chorus and start to draw closer, you know that you are no longer safe here."
	area_descs["AREA_01"] = "Hands outstretched, you race away from the howling darkness. Branches claw at your face and you nearly stumble on the thick roots, but you know that falling now will mean certain death."
	area_descs["AREA_02"] = "Your heart hammers your chest as the blood roars through your veins. You can see fractured daylight through the trees ahead, but the thundering hoofbeats tell you that the beasts are nearly upon you."
	area_descs["AREA_03"] = "You throw yourself into the clearing at the last moment and crawl into the sunlight. You can feel the hateful eyes at your back but it seems that they will not follow you out of the denser part of the forest. But as your eyes adjust to the light, your relief is replaced by bewilderment."
	area_descs["AREA_04"] = "You are inside the first room."
	area_descs["AREA_05"] = "You are on the east side of the room."
	area_descs["AREA_06"] = "You are on the west side of the room."
	area_descs["AREA_07"] = "You are now being switched to a low-fidelity, first-person view..."

	area_flags["AREA_00"] = []
	area_flags["AREA_01"] = []
	area_flags["AREA_02"] = []
	area_flags["AREA_03"] = ["trigger fp_still_image mode"]
	area_flags["AREA_04"] = []
	area_flags["AREA_05"] = []
	area_flags["AREA_06"] = []
	area_flags["AREA_07"] = []
				
	area_hints["AREA_00"] = "You have no choice but to run."
	area_hints["AREA_01"] = "You have no choice but to run."
	area_hints["AREA_02"] = "You have no choice but to run."
	area_hints["AREA_03"] = "But there is a familiarity to this scene that you cannot explain, and you suspect that you may have something in your INVENTORY that can help you."
	area_hints["AREA_04"] = ""
	area_hints["AREA_05"] = ""
	area_hints["AREA_06"] = ""
	area_hints["AREA_07"] = ""

	area_exits["AREA_00"] = { "RUN": "AREA_01" }
	area_exits["AREA_01"] = { "RUN": "AREA_02" }
	area_exits["AREA_02"] = { "RUN": "AREA_03" }
	area_exits["AREA_03"] = { }
	area_exits["AREA_04"] = { "W": "AREA_05" , "E": "AREA_06" }
	area_exits["AREA_05"] = { "E": "AREA_04" }
	area_exits["AREA_06"] = { "W": "AREA_04" }
	area_exits["AREA_07"] = { }

	area_gates["AREA_00"] = [ ["*", "There's no time for that now."], ["NORTH", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["SOUTH", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["EAST", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["WEST", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."]]
	area_gates["AREA_01"] = [ ["*", "There's no time for that now."], ["NORTH", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["SOUTH", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["EAST", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["WEST", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."]]
	area_gates["AREA_02"] = [ ["*", "There's no time for that now."], ["NORTH", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["SOUTH", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["EAST", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."], ["WEST", "The only direction you are concerned about right now is the one that takes you away from your pursuers. You need to RUN."]]
	area_gates["AREA_03"] = [ ["OPEN DOOR", "Even with a crowbar you would not be able to force this lock. There is no way in without a KEY."], ["*", "You are thoroughly consumed by the need to OPEN this door, and you dare not return to the forest anyway..."] ]
	area_gates["AREA_04"] = []
	area_gates["AREA_05"] = []
	area_gates["AREA_06"] = []
	area_gates["AREA_07"] = []

	area_locks["AREA_04"] = []
	area_locks["AREA_05"] = []
	area_locks["AREA_06"] = []
	area_locks["AREA_07"] = []
	area_locks["AREA_03"] = [ [ ["USE KEY"], ["Finally reunited with the strange key, the lock snaps open. You should be able to OPEN the door now.", ["OPEN DOOR", "AREA_04"]] ] ]
	area_locks["AREA_04"] = []
	area_locks["AREA_05"] = []
	area_locks["AREA_06"] = []
	area_locks["AREA_07"] = []

	area_items["AREA_00"] = []
	area_items["AREA_01"] = []
	area_items["AREA_02"] = []
	area_items["AREA_03"] = ["DOOR"]
	area_items["AREA_04"] = []
	area_items["AREA_05"] = []
	area_items["AREA_06"] = []
	area_items["AREA_07"] = []
	
	item_names["DOOR"] = "a heavy wooden door"
	item_names["KEY"] = "a silver key"
	
	item_descs["DOOR"] = "Cast iron bands desperately grip this heavy oak door, and the curious sigil burned into the planks seems to beckon you inside. Unfortunately, it also bears an impressive warded lock."
	item_descs["KEY"] = "The blade of this ancient silver key has been cut to resemble a glyph from some exotic alphabet. You seem to recall once reading something about a silver key, but this probably isn't it."
	
	area_flags[curr_area].append("visited")

	terminal_handle.print_to_terminal(area_descs[curr_area])
	if not area_hints[curr_area] == "":
		terminal_handle.print_to_terminal(area_hints[curr_area])
		
	terminal_handle.print_to_terminal(">")


func play(input_string):

	# just for debugging purposes
	print(input_string)

	# trim the unwanted characters from the string taken from the terminal
	input_string = input_string.trim_prefix(">").trim_prefix(" ").trim_suffix(" ")
	
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
	
	# this is the "update" stage of the text adventure game loop
	if input_action == "LOOK":
		
		if input_object in area_items[curr_area]:
			terminal_handle.print_to_terminal(item_descs[input_object])
		elif input_object in inventory:
			terminal_handle.print_to_terminal(item_descs[input_object])

	elif input_action == "USE":
		pass
	
	elif input_action == "DROP":
		pass

	elif input_action == "GRAB":
		# if you already have it say so
		# if you dont already have it but it is in the room then take it
		# if you cant take it but it is in the room say so
		# if it isnt there say so
		pass

	elif input_action == "INVENTORY":

		match len(inventory):

			0:
				terminal_handle.print_to_terminal("You aren't carrying anything.")

			1:
				terminal_handle.print_to_terminal("You are carrying " + item_names[inventory[0]] + ".")

			2:
				terminal_handle.print_to_terminal("You are carrying " + item_names[inventory[0]] + " and " + item_names[inventory[1]] + ".")

			_: # obviously this needs to be rewritten, as it only works for a maximum of 3 items...
				terminal_handle.print_to_terminal("You are carrying " + item_names[inventory[0]] + ", " + item_names[inventory[1]] + ", and " + item_names[inventory[2]], ".")
		
	elif input_action in ["RUN", "NORTH", "SOUTH", "EAST", "WEST"]:

		if input_action in area_exits[curr_area]:
			curr_area = area_exits[curr_area][input_action]
		elif input_action == "RUN":
			terminal_handle.print_to_terminal("Where do you think you can run?")
		else:
			terminal_handle.print_to_terminal("You can't go in that direction.")

	elif input_action == "HELP":
		pass

	elif input_action == "EXIT":
		pass
			
	else:
		terminal_handle.print_to_terminal("I don't understand what you mean...")
		
	# this is the "render" stage of the text adventure game loop	
	if not ("visited" in area_flags[curr_area]):
		area_flags[curr_area].append("visited")
		terminal_handle.print_to_terminal(area_descs[curr_area])
		if not area_hints[curr_area] == "":
			terminal_handle.print_to_terminal(area_hints[curr_area])

	terminal_handle.print_to_terminal(">")
	
	if "trigger fp_still_image mode" in area_flags[curr_area]:
		area_flags[curr_area].erase("trigger fp_still_image mode")
		player_handle.user_input_state = player_handle.UserInputMode.FP_STILL_IMG
		masktimer_handle.start(4)
