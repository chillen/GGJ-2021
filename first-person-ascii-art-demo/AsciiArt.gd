extends Sprite


# rather than import a font resource (which is obviously on the "to-do" list)
# the default font in godot can be acquired like this
var dynamic_font = DynamicFont.new()

# this "magic number" is just the step size for processing the pixels in the first-person view
# it roughly corresponds to the amount of screen space associated with a single character in the ASCII art display
var magic_number = 12

# this is a 70-character greyscale palette (representing the maximum possible "colour depth")
var ascii_art_palette : String = "@#$%&8BMW*mwqpdbkhaoQ0OZXYUJCLtfjzxnuvcr][}{1)(|\\/?Il!i><+_-~;\":^,`'. "

# these values specify the fidelity of the ascii art representation to the actual first person view
# they range between 0 and 1 (with 0 being almost completely unusable)
var palette_usage : float = 0.075
var colour_fidelity : float = 0.075

# the number of usable characters is a function of the palette_usage parameter above
var usable_palette_size : int 

var draw_ui : bool = false

# a handle to the viewport (for which the ASCII art representation is created)
onready var viewport_handle : Viewport = $"/root/Main/Viewport"

# used for rendering the text overlay
onready var player : Node = $"/root/Main/Viewport/3DWorld/Player"
const border_width = 2
const border_height = 2
const border_pad_x = 1
const border_pad_y = 1
	
# the size of the viewport is necessary for the loop that examines the pixel data
onready var viewport_wid : int = viewport_handle.get_texture().get_data().get_width()
onready var viewport_hgt : int = viewport_handle.get_texture().get_data().get_height()

var cursor_timer = 0
var cursor_timer_max = 60

func get_ui_char(text, x, y):
	var text_len = len(text)
	
	if x < border_width or x >= border_width + 2*border_pad_x + player.text_buffer_width:
		return '#'
		
	if y < border_height or y >= border_height + 2*border_pad_y + 1:
		return '#'
	
	if y == border_height + border_pad_y:
		var x_offset = x - border_width - border_pad_x
		if x_offset >= 0 and x_offset < text_len:
			return text[x_offset]
		if x_offset >= 0 and x_offset == text_len and cursor_timer < cursor_timer_max / 2:
			return '_'
		
	return ' '

func get_ui_draw_color():
	if player.command_cooldown > 0:
		if player.last_command_result == true:
			return Color.green
		else:
			return Color.red
	
	return Color.black

func _ready():
	# compute the initial palette size
	usable_palette_size = int(palette_usage * (ascii_art_palette.length() - 1)) + 1	
	
	dynamic_font.font_data = load("res://Font/DejaVuSansMono.ttf")
	dynamic_font.size = 12


func _draw():
	# get the image data from the viewport and flip it
	var viewport_image_data = viewport_handle.get_texture().get_data()
	viewport_image_data.flip_y()
	
	# lock the pixels of that image so they can be accessed quickly
	viewport_image_data.lock()
	
	var ui_panel_x = 0
	var ui_panel_y = 0
	var ui_panel_width = 0
	var ui_panel_height = 0
	var text_x = 0
	var text_y = 0
	var write_text = false
	var text_to_write = ""
	
	if player.is_object_selected:
		var inst = instance_from_id(player.selected_object_id)
		var takes_input = inst.get("takes_input")
		if not takes_input == null and takes_input == true:
			text_to_write = player.command_text_buffer
			write_text = true
	
	var num_chars_x = int(viewport_wid / magic_number) + (0 if viewport_wid % magic_number == 0 else 1)
	var num_chars_y = int(viewport_hgt / magic_number) + (0 if viewport_hgt % magic_number == 0 else 1)
	
	if write_text:
		ui_panel_width = player.text_buffer_width + 2*border_pad_x + 2*border_width
		ui_panel_height = 1 + 2*border_pad_y + 2*border_height
		ui_panel_x = (num_chars_x - ui_panel_width) / 2
		ui_panel_y = (num_chars_y - ui_panel_height) / 2
		text_x = ui_panel_x + border_width + border_pad_x
		text_y = ui_panel_y + border_height + border_pad_y
	
	# visit every 'magic_number'-th pixel in the image
	# n.b., fidelity could be improved here by selecting each character based on
	# the appearance (i.e., average colour, edge shape, etc.) of a small region 
	for x_idx in range(0, num_chars_x):
		var x = x_idx * magic_number
		
		for y_idx in range(0, num_chars_y):
			var y = y_idx * magic_number
			
			if x_idx >= ui_panel_x and x_idx < ui_panel_x + ui_panel_width and y_idx >= ui_panel_y and y_idx < ui_panel_y + ui_panel_height:
				draw_char(dynamic_font, Vector2(x,y), get_ui_char(text_to_write, x_idx - ui_panel_x, y_idx - ui_panel_y), " ", get_ui_draw_color())
				continue
			
			# get the pixel and compute it's luminance
			var pixel_colour = viewport_image_data.get_pixel(x, y)
			var pixel_luminance = 0.2126 * pixel_colour[0] + 0.7152 * pixel_colour[1] + 0.0722 * pixel_colour[2]
			
			# this calculation maps a luminance to an index into the palette string
			var char_index = round(pixel_luminance *  usable_palette_size) * (ascii_art_palette.length() - 1)  / usable_palette_size
			
			# replace the alpha value of the colour of the current pixel with 
			# the fidelity parameter and blend with base colour black; the result 
			# is a character colour that ranges from black to the actual pixel colour
			pixel_colour[3] = colour_fidelity
			var char_colour = Color.black.blend(pixel_colour)
			
			# draw the character on the sprite
			# it is probably worth noting that the values of x and y here are
			# also dependent on the magic number value mentioned above
			draw_char(dynamic_font, Vector2(x, y), ascii_art_palette[char_index], " ", char_colour)
	
	
func _process(delta):
	# for debugging our "changing ASCII art fidelity" concept, I have added some
	# temporary code here allowing the player to increase or decrease fidelity
	# by using the PAGE_UP and PAGE_DOWN keys
	if Input.is_action_pressed("debug_inc_fid"):
		palette_usage = min(1, palette_usage + 0.01)
		usable_palette_size = int(palette_usage * (ascii_art_palette.length() - 1)) + 1	
		colour_fidelity = min(1, colour_fidelity + 0.01)
	if Input.is_action_pressed("debug_dec_fid"):
		palette_usage = max(0, palette_usage - 0.01)
		usable_palette_size = int(palette_usage * (ascii_art_palette.length() - 1)) + 1	
		colour_fidelity = max(0, colour_fidelity - 0.01)

	cursor_timer += 1
	if cursor_timer > cursor_timer_max:
		cursor_timer = 0

	# required for continually recreating the ASCII art view
	update()
