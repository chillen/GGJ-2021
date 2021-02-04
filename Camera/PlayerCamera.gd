extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var viewport_handle : Viewport = $Viewport
export var background_colour : Color = Color.black
export var render_size : Vector2 = Vector2(1024,600)
export var mask_texture : Texture  = null


# these values specify the fidelity of the ascii art representation to the actual first person view
# they range between 0 and 1 (with 0 being almost completely unusable); experimentally, I think that
# using 0.5 as a minimum value gives a really nice effect
export var palette_usage: float = 1
export var colour_fidelity: float = 1
export var mask_luminosity: float = 0.5

# this is a greyscale palette (representing the maximum possible "colour depth")
export var ascii_art_palette: String = "~csrzetvIixayJhCfnYjuVblUXAdpMLqomSWOgZkwGFTQNEHPRKDB"
 

# Called when the node enters the scene tree for the first time.
func _ready():
	render_size = OS.get_real_window_size()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
