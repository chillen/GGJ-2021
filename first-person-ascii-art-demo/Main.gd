extends Node2D


onready var player_handle : KinematicBody = $"Viewport/Spatial/Player"


func _ready():
	
	# just a message box to remind everyone how to tune the fidelity
	OS.alert('You can use the PAGE_UP and PAGE_DOWN keys to control the fidelity (i.e., colour fidelity and size of character palette) of the ASCII art representation of the first-person view.', 'Important Note')

	
func _input(event):
	
	# it is necessary to pass the mouse movement from the Main node (where
	# it gets captured), into the Player node in the Viewport (where it is
	# actually needed in order to get the mouse look to work)
	if event is InputEventMouseMotion:
		player_handle.mouse_movement = event.relative

	# Give debug views with f keys
	if Input.is_action_pressed("f1"):
		$FirstPerson.visible = true
		$AsciiArt.visible = false
		$Viewport.set_debug_draw(0)
	elif Input.is_action_pressed("f2"):
		$FirstPerson.visible = false
		$AsciiArt.visible = true
		$Viewport.set_debug_draw(0)
	elif Input.is_action_pressed("f3"):
		$FirstPerson.visible = false
		$AsciiArt.visible = true
		$Viewport.set_debug_draw(1)
