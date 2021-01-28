extends Node2D


onready var player_handle : KinematicBody = $"Viewport/Spatial/Player"
onready var viewport : Viewport = $"Viewport"

func _ready():	
	# just a message box to remind everyone how to tune the fidelity
	OS.alert('You can use the PAGE_UP and PAGE_DOWN keys to control the fidelity (i.e., colour fidelity and size of character palette) of the ASCII art representation of the first-person view.', 'Important Note')

	
func _input(event):
	
	# it is necessary to pass the mouse movement from the Main node (where
	# it gets captured), into the Player node in the Viewport (where it is
	# actually needed in order to get the mouse look to work)
	if event is InputEventMouseMotion:
		player_handle.mouse_movement = event.relative
		
	if event is InputEventKey:
		player_handle.handle_key_press(event)
