extends Sprite


# rather than import a font resource (which is obviously on the "to-do" list)
# the default font in godot can be acquired like this
var default_font = Label.new().get_font("")

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


# a handle to the viewport (for which the ASCII art representation is created)
onready var viewport_handle : Viewport = $"/root/Main/Viewport"

# the size of the viewport is necessary for the loop that examines the pixel data
onready var viewport_wid : int = viewport_handle.get_texture().get_data().get_width()
onready var viewport_hgt : int = viewport_handle.get_texture().get_data().get_height()


func _ready():

	# compute the initial palette size
	usable_palette_size = int(palette_usage * (ascii_art_palette.length() - 1)) + 1	


func _draw():
	
	# get the image data from the viewport and flip it
	var viewport_image_data = viewport_handle.get_texture().get_data()
	viewport_image_data.flip_y()
	
	# lock the pixels of that image so they can be accessed quickly
	viewport_image_data.lock()
	
	# visit every 'magic_number'-th pixel in the image
	# n.b., fidelity could be improved here by selecting each character based on
	# the appearance (i.e., average colour, edge shape, etc.) of a small region 
	for x in range(0, viewport_wid, magic_number):
		for y in range(0, viewport_hgt, magic_number):
			
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
			draw_char(default_font, Vector2(x, y), ascii_art_palette[char_index], " ", char_colour)
	
	
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

	# required for continually recreating the ASCII art view
	update()
