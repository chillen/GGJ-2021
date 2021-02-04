extends Sprite

# rather than import a font resource (which is obviously on the "to-do" list)
# the default font in godot can be acquired like this
export var dynamic_font : DynamicFont

# this "magic number" is just the step size for processing the pixels in the first-person view
# it roughly corresponds to the amount of screen space associated with a single character in the ASCII art display
# draw_char draw based on the center of the charater, not top left
var  magic_number_x = 10
var  magic_number_y = 16

# TODO : make this dynamic based on the size of the charater
# number of pixel jumps until we print the next charater
var magic_offset_h = 7
var magic_offset_v = 14

# screen size is not perfect to the size of the charaters, this pads the margins evenly
var extra_x_offset = 0
var extra_y_offset = 0







# the number of usable characters is a function of the palette_usage parameter above
var usable_palette_size: int

# value 0 : charater position will be printed on draw
# value 1 : charater position will not be printed on draw
var mask_array = []

# handles to the various components that must be accessed
onready var viewport_handle: Viewport = self.get_parent().find_node("Viewport")
onready var camera_handle: Spatial = self.get_parent()

func _ready():
	# compute the initial palette size
	usable_palette_size = int(self.camera_handle.palette_usage * (self.camera_handle.ascii_art_palette.length() - 1)) + 1

	# loading the dynamic font (and note that the font size is magic_number_y)
	dynamic_font.size = magic_number_y - 1
	
	for row in range(floor(viewport_handle.size.y / magic_number_y)):
		mask_array.append([])
		for col in range(floor(viewport_handle.size.x / magic_number_x)):
			mask_array[row].append(0)
	


func _process(delta):
	usable_palette_size = int(self.camera_handle.palette_usage * (self.camera_handle.ascii_art_palette.length() - 1)) + 1
	self.extra_y_offset = (viewport_handle.size.y - floor(viewport_handle.size.y / magic_number_y)*magic_number_y)/2
	self.extra_x_offset = (viewport_handle.size.x - floor(viewport_handle.size.x / magic_number_x)*magic_number_x)/2
	self.update_mask()
	self.update()
	
# get the mask texture and decide if a charater should be draw based on the luminocity
func update_mask():
	if camera_handle.mask_texture == null:
		for row in range(floor(viewport_handle.size.y / magic_number_y)):
			for col in range(floor(viewport_handle.size.x / magic_number_x)):
				mask_array[row][col] = 0
	else:
			
		var image  : Image = camera_handle.mask_texture.get_data()
		image.resize(mask_array[0].size(),mask_array.size(),Image.INTERPOLATE_TRILINEAR)
		
		image.lock()
		for row in range(floor(viewport_handle.size.y / magic_number_y)):
			for col in range(floor(viewport_handle.size.x / magic_number_x)):
				var colour : Color = image.get_pixel(col,row)
				if colour.a < 0.5:
					mask_array[row][col] = 1
		
		image.unlock()
	


func _draw():
	# get the image data from the viewport and flip it
	var viewport_image_data = viewport_handle.get_texture().get_data()
	viewport_image_data.resize(mask_array[0].size(),mask_array.size(),Image.INTERPOLATE_TRILINEAR)
	# lock the pixels of those images so they can be accessed quickly
	viewport_image_data.lock()

	# visit every 'magic_number'-th pixel in the image (and note that there are
	# now two magic numbers for the characters because that is necessary to reflect
	# the aspect ratio (approximately 1x2) of the characters of the font

	for row in range(floor(viewport_handle.size.y / magic_number_y)):
		for col in range(floor(viewport_handle.size.x / magic_number_x)):
	
			
			if mask_array[row][col]:
				continue
				
			# get the pixel and compute it's luminance
			var pixel_colour = viewport_image_data.get_pixel(col, row)
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
				* (self.camera_handle.ascii_art_palette.length() - 1)
				/ usable_palette_size
			)

			# replace the alpha value of the colour of the current pixel with 
			# the fidelity parameter and blend with base colour black; the result 
			# is a character colour that ranges from black to the actual pixel colour
			pixel_colour[3] = self.camera_handle.colour_fidelity
			var char_colour = Color.white.blend(pixel_colour)
			

			# draw the character on the sprite
			# it is probably worth noting that the values of x and y here are
			# also dependent on the magic number value mentioned above
			draw_char_by_row_col(row, col, self.camera_handle.ascii_art_palette[char_index], char_colour)

	viewport_image_data.unlock()

# this function is just a nice wrapper for drawing characters on the screen by row and column
func draw_char_by_row_col(row, col, character, colour):
		draw_char(
		dynamic_font,
		Vector2(col * magic_number_x + magic_offset_h + extra_x_offset, row * magic_number_y + magic_offset_v + extra_y_offset),
		character,
		" ",
		colour
	)


