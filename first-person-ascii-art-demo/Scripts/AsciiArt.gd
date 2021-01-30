extends Sprite

# rather than import a font resource (which is obviously on the "to-do" list)
# the default font in godot can be acquired like this
var default_font = Label.new().get_font("")
var dynamic_font = DynamicFont.new()

# this "magic number" is just the step size for processing the pixels in the first-person view
# it roughly corresponds to the amount of screen space associated with a single character in the ASCII art display
var magic_number_x = 10
var magic_number_y = 16
var magic_offset_h = 0
var magic_offset_v = 14

# these are the dimensions of the text entry frame that can be used in the first-person mode
var txt_frame_top = 20
var txt_frame_btm = 25
var txt_frame_lft = 50
var txt_frame_rgt = 110

# this is a greyscale palette (representing the maximum possible "colour depth")
var ascii_art_palette: String = "rJticlvsunzLIxoTajwCFZhSyekYfUVdbqpPAEHXmKGDgORWNBQM"
# var ascii_art_palette : String = "chthulhunaflfhtagn"

# these values specify the fidelity of the ascii art representation to the actual first person view
# they range between 0 and 1 (with 0 being almost completely unusable); experimentally, I think that
# using 0.5 as a minimum value gives a really nice effect
var palette_usage: float = 1
var colour_fidelity: float = 1

# the number of usable characters is a function of the palette_usage parameter above
var usable_palette_size: int

# this will be the 2D array that contains the actual mask (to which the new masks
# from the particle system are added)
var mask_array = []

# handles to the various components that must be accessed
onready var viewport_handle: Viewport = $"/root/Main/FirstPersonViewport"
onready var player_handle: KinematicBody = $"/root/Main/FirstPersonViewport/GameWorld/Player"
onready var terminal_handle: Node = $"/root/Main/Terminal"
onready var maskparticles_handle: Particles2D = $"/root/Main/MaskViewport/MaskParticles"
onready var masksprite_handle: Sprite = $"/root/Main/MaskSprite"
onready var masktimer_handle: Timer = $"/root/Main/MaskTimer"
onready var lineedit_handle: LineEdit = $"/root/Main/LineEdit"
onready var textadventure_handle: Node = $"/root/Main/TextAdventure"

# the size of the viewport is necessary for the loop that examines the pixel data
onready var viewport_wid: int = viewport_handle.get_texture().get_data().get_width()
onready var viewport_hgt: int = viewport_handle.get_texture().get_data().get_height()


func _ready():
	# compute the initial palette size
	usable_palette_size = int(palette_usage * (ascii_art_palette.length() - 1)) + 1

	# loading the dynamic font (and note that the font size is magic_number_y)
	dynamic_font.font_data = load("res://Assets/Font/iosevka-term-curly-slab-bold.ttf")
	dynamic_font.size = magic_number_y - 1

	# this creates an empty mask (currently holding only 0s and 1s, but I will
	# be changing this shortly) and this mask is used to hide the first-person
	# view behind the simulated terminal (which has not yet been added) 
	# n.b., 160 and 45 are 1280 / magic_number_x and 720 / magic_number_y, respectively

	for row in range(720 / magic_number_y):
		mask_array.append([])
		for col in range(1280 / magic_number_x):
			mask_array[row].append(0)


func _draw():
	# get the image data from the viewport and flip it
	var viewport_image_data = viewport_handle.get_texture().get_data()
	viewport_image_data.flip_y()

	# get the image data from the mask; currently there is a camera pointed
	# at a particle system in a viewport rendered onto this sprite, so the
	# particle system can be used as a mask
	var mask_image_data = masksprite_handle.get_texture().get_data()

	# lock the pixels of those images so they can be accessed quickly
	viewport_image_data.lock()
	mask_image_data.lock()

	# NOTE TO SELF: THIS ROUTINE DRAWS THE ASCII ART VIEW OF THE 3D WORLD (AND SHOULD PROBABLY BE A FUNCTION OF ITS OWN)

	# visit every 'magic_number'-th pixel in the image (and note that there are
	# now two magic numbers for the characters because that is necessary to reflect
	# the aspect ratio (approximately 1x2) of the characters of the font
	var char_row = 0
	var char_col = 0
	for y in range(0, viewport_hgt, magic_number_y):
		for x in range(0, viewport_wid, magic_number_x):
			# any pixel in the mask that has been "hit" by a particle is permanently
			# transparent (n.b., the permanent mask is mask_array but mask_image_data
			# is the image from the camera pointed at the particle system
			if (
				mask_image_data.get_pixel(char_col, char_row)[3] == 1
				and (mask_array[char_row][char_col] == 0)
			):
				mask_array[char_row][char_col] = 1

			# if the corresponding permanent mask location is transparent, draw it
			# (it might not be necessary to add alpha here, but if we wanted to,
			# then this would be where it would be added)

			if mask_array[char_row][char_col] == 1 and (char_row < 33 or char_col > 60):
				# if mask_array[char_row][char_col] == 1 and (char_row < 33 or char_col > 60) and (not player_handle.user_input_state == player_handle.UserInputMode.FP_TXT_ENTRY or (char_col < txt_frame_lft or char_col > txt_frame_rgt or char_row < txt_frame_top or char_row > txt_frame_btm)):

				# get the pixel and compute it's luminance
				var pixel_colour = viewport_image_data.get_pixel(x, y)
				var pixel_luminance = (
					0.2126 * pixel_colour[0]
					+ 0.7152 * pixel_colour[1]
					+ 0.0722 * pixel_colour[2]
				)
				if pixel_luminance < 0.1:
					pixel_colour = Color(.1, .1, .1, 1)

				# this calculation maps a luminance to an index into the palette string
				var char_index = (
					round(pixel_luminance * usable_palette_size)
					* (ascii_art_palette.length() - 1)
					/ usable_palette_size
				)

				# replace the alpha value of the colour of the current pixel with 
				# the fidelity parameter and blend with base colour black; the result 
				# is a character colour that ranges from black to the actual pixel colour
				pixel_colour[3] = colour_fidelity
				var char_colour = Color.white.blend(pixel_colour)

				# draw the character on the sprite
				# it is probably worth noting that the values of x and y here are
				# also dependent on the magic number value mentioned above
				draw_char_by_row_col(char_row, char_col, ascii_art_palette[char_index], char_colour)

			char_col += 1
		char_col = 0
		char_row += 1

	# NOTE TO SELF: THIS ROUTINE DRAWS THE TERMINAL IN THE BOTTOM LEFT (AND SHOULD PROBABLY BE A FUNCTION OF ITS OWN)

	var current_row = max(0, terminal_handle.last_printed_row - terminal_handle.screen_buffer_high)
	var current_col = 0

	var topmost_row = 43
	var lftmost_col = 1

	while (
		current_row < terminal_handle.last_printed_row
		or current_col < terminal_handle.last_printed_col
	):
		draw_char_by_row_col(
			topmost_row - (terminal_handle.last_printed_row - current_row),
			lftmost_col + current_col,
			terminal_handle.screen_buffer_data[current_row][current_col],
			Color.white
		)

		current_col += 1
		if current_col == len(terminal_handle.screen_buffer_data[current_row]):
			current_col = 0
			current_row += 1

	for _i in range(terminal_handle.display_speed):
		if (
			terminal_handle.last_printed_row < terminal_handle.last_buffered_row
			or terminal_handle.last_printed_col < terminal_handle.last_buffered_col
		):
			terminal_handle.last_printed_col += 1
			if (
				terminal_handle.last_printed_col
				== len(terminal_handle.screen_buffer_data[terminal_handle.last_printed_row])
			):
				terminal_handle.last_printed_col = 0
				terminal_handle.last_printed_row += 1

	if terminal_handle.flashing_prompt_timer > -1:
		if terminal_handle.flashing_prompt_timer == 0:
			terminal_handle.flashing_prompt_timer = 20
			terminal_handle.flashing_prompt_state = not terminal_handle.flashing_prompt_state

		terminal_handle.flashing_prompt_timer -= 1
		if terminal_handle.flashing_prompt_state:
			draw_char_by_row_col(topmost_row, lftmost_col + 1, "_", Color.red)


func _process(delta):
	# for debugging our "changing ASCII art fidelity" concept, I have added some
	# temporary code here allowing the player to increase or decrease fidelity
	# by using the PAGE_UP and PAGE_DOWN keys
	if Input.is_action_pressed("debug_raise_fidelity"):
		palette_usage = min(1, palette_usage + 0.01)
		usable_palette_size = int(palette_usage * (ascii_art_palette.length() - 1)) + 1
		colour_fidelity = min(1, colour_fidelity + 0.01)
	if Input.is_action_pressed("debug_lower_fidelity"):
		palette_usage = max(0, palette_usage - 0.01)
		usable_palette_size = int(palette_usage * (ascii_art_palette.length() - 1)) + 1
		colour_fidelity = max(0, colour_fidelity - 0.01)

	# required for continually recreating the ASCII art view
	update()


# this function is just a nice wrapper for drawing characters on the screen by row and column
func draw_char_by_row_col(row, col, character, colour):
	draw_char(
		dynamic_font,
		Vector2(col * magic_number_x + magic_offset_h, row * magic_number_y + magic_offset_v),
		character,
		" ",
		colour
	)


# this is signal from the timer that controls how the particle system "pierces"
# the mask that hides the first-person display
func _on_Timer_timeout():
	# this "moves" the particle system somewhere on the mask
	maskparticles_handle.position[0] = randi() % 1280 / magic_number_x
	maskparticles_handle.position[1] = randi() % 720 / magic_number_y

	# the timer is a "one-shot, explosion-like" effect that is very short, so
	# the timer triggering it must be restarted, but the wait time is reduced so
	# the effect of "piercing" the mask is being accelerated
	masktimer_handle.wait_time = max(0.2, masktimer_handle.wait_time * 0.6)
	maskparticles_handle.restart()


func _on_LineEdit_text_changed(new_text):
	terminal_handle.flashing_prompt_timer = -1
	terminal_handle.flashing_prompt_state = false

	if (
		player_handle.user_input_state == player_handle.UserInputMode.COMMAND_LINE
		or player_handle.user_input_state == player_handle.UserInputMode.FP_TXT_ENTRY
	):
		terminal_handle.text_entry(new_text)
	lineedit_handle.text = ""


func _on_LineEdit_text_entered(new_text):
	if terminal_handle.screen_buffer_data[terminal_handle.last_buffered_row] != " ":
		if player_handle.user_input_state == player_handle.UserInputMode.COMMAND_LINE:
			textadventure_handle.play(
				terminal_handle.screen_buffer_data[terminal_handle.last_buffered_row]
			)
		if player_handle.user_input_state == player_handle.UserInputMode.FP_TXT_ENTRY:
			# Get the input bugger, and transform it into the input string for the interaction object
			# send interaction to interaction object that player is viewing
			var input = terminal_handle.screen_buffer_data[terminal_handle.last_buffered_row]
			if terminal_handle.last_buffered_row > 0:
				input = input.substr(1,len(input))
			input = input.to_lower().trim_prefix(" ").trim_suffix(" ")
			player_handle.action(input,player_handle.object_to_interact_with)
			#player_handle.object_to_interact_with.interact(input)
			
			player_handle.object_to_interact_with = null
			terminal_handle.print_to_terminal(">")
			player_handle.user_input_state = player_handle.UserInputMode.FP_FREE_LOOK


func _on_LineEdit_gui_input(event):
	if event is InputEventKey and event.scancode == KEY_BACKSPACE:
		terminal_handle.backspace()
