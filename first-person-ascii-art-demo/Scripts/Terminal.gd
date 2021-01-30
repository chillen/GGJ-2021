extends Node

# this is a work in progress, but this node is going to control the traditional
# interactive fiction interface
var screen_buffer_data = []
var screen_buffer_wide: int = 60
var screen_buffer_high: int = 9  # a weird "off-by-one" issue... e.g., 9 will allow 10 lines onscreen

var last_printed_row: int = 0
var last_printed_col: int = 0
var last_buffered_row: int = 0
var last_buffered_col: int = 0

var display_speed: int = 3
var max_input_len: int = 32
var backspace_cooldown: int = 0
var flashing_prompt_state: bool = false
var flashing_prompt_timer: int = -1

var rlyehian_queued_replacements = {}
var english_to_rlyehian = {}

func _ready():
	
	# maybe we could print a title using a sweet ASCII font?
	print_to_terminal("Loss for Words")
	
	# populate the english to rlyehian dictionary
	english_to_rlyehian["walk"] = "bugnah"
	english_to_rlyehian["look"] = "mgrluh"
	english_to_rlyehian["open"] = "mgahnnn"
	english_to_rlyehian["help"] = "hafh"
	english_to_rlyehian["take"] = "mggoka"
	english_to_rlyehian["use"] = "ahuaaah"

	# puzzle specific
	english_to_rlyehian["light the way"] = "mgnghft h yogor"
	


func _process(delta):
	if backspace_cooldown > 0:
		backspace_cooldown -= 1


func print_to_terminal(remaining_characters = ""):
	screen_buffer_data.append(" ")

	# convert the text to be printed to uppercase
	remaining_characters = remaining_characters.to_lower() + " "

	# divide it into blocks of size screen_buffer_wide
	while len(remaining_characters) > screen_buffer_wide:
		# determine the length of the current chunk by looking for the first space before the last character in the block
		var current_line_len = screen_buffer_wide
		while not (remaining_characters[current_line_len - 1] == " "):
			current_line_len -= 1

		# add this line to the buffer
		var characters_to_add = remaining_characters.substr(0, current_line_len)
		screen_buffer_data.append(characters_to_add)

		# trim the blank space from the remaining text (if present) and repeat
		remaining_characters = remaining_characters.substr(current_line_len).trim_prefix(" ")

	# append the remaining characters and determine what the final row and column are
	screen_buffer_data.append(remaining_characters)

	last_buffered_row = len(screen_buffer_data) - 1
	last_buffered_col = len(remaining_characters) - 1


func text_entry(next_character):
	next_character = next_character.to_lower()
	if ( screen_buffer_data[last_buffered_row][0] == ">" and len(screen_buffer_data[last_buffered_row]) < max_input_len + 2 ):  #n.b., the +2 is because of the prompt and the trailing whitespace character
		screen_buffer_data[last_buffered_row][last_buffered_col] = next_character
		screen_buffer_data[last_buffered_row] += " "
		last_buffered_col = len(screen_buffer_data[last_buffered_row]) - 1


func backspace():
	if (
		backspace_cooldown == 0
		and screen_buffer_data[last_buffered_row][0] == ">"
		and len(screen_buffer_data[last_buffered_row]) > 2
	):
		screen_buffer_data[last_buffered_row] = screen_buffer_data[last_buffered_row].substr(
			0, len(screen_buffer_data[last_buffered_row]) - 2
		)
		screen_buffer_data[last_buffered_row] += " "
		last_buffered_col = len(screen_buffer_data[last_buffered_row]) - 1
		last_printed_col = last_buffered_col
		backspace_cooldown = 6

func replace_with_rlyehian(rlyehian_phrase):
	rlyehian_queued_replacements[phrase_to_replace] = [last_buffered_row, rlyehian_phrase, 0]
		
func process_replacements():
	for key in rlyehian_queued_replacements.keys():
		value = rlyehian_queued_replacements[key]
		row_num = value[0]
		new_word = value[1]
		curr_index = value[3]

