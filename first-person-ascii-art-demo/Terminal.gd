extends Node

# this is a work in progress, but this node is going to control the traditional
# interactive fiction interface
var screen_buffer_data = []
var screen_buffer_wide : int = 60
var screen_buffer_high : int = 9  # a weird "off-by-one" issue... e.g., 9 will allow 10 lines onscreen
var last_printed_row : int = 0
var last_printed_col : int = 0
var last_buffered_row : int = 0
var last_buffered_col : int = 0

func _ready():
	
	# add some of Connor's script for testing
	print_to_terminal("You are an explorer, an author, seeking information about a lost civilization. After years of searching, a glade seemed to reach out to *you*, but on approach something curious happens. The world is less clear. Your brain begins to fog. The magic of the ancients is strong here, and you aren't quite sure that you like it.")
	print_to_terminal()
	print_to_terminal("It is hard to discern now, but this place seems to be the ritual site from your research. A voice echoes \"Words speak louder than actions, seeker.\"")
	print_to_terminal()
	print_to_terminal("You see an altar filled with flammable oils.")

	# display the contents of the buffer (for debugging purposes
	for i in range(len(screen_buffer_data)):
		print(i, screen_buffer_data[i])
	print(last_printed_row, " ", last_printed_col, " ", last_buffered_row, " ", last_buffered_col)
	
func print_to_terminal(remaining_characters = "_"):
	
	# convert the text to be printed to uppercase
	remaining_characters = remaining_characters.to_upper()
	
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

