extends Node2D


onready var player_handle : KinematicBody = $"Viewport/3DWorld/Player"
onready var viewport : Viewport = $"Viewport"
onready var start_handle : Position3D = $"Viewport/Level/Start"


func _ready():
	
	pass
	
	# just a message box to remind everyone how to tune the fidelity
	# OS.alert('You can use the PAGE_UP and PAGE_DOWN keys to control the fidelity (i.e., colour fidelity and size of character palette) of the ASCII art representation of the first-person view.', 'Important Note')
	
	# inside the level there is a Position3D named "Start" that can be used as
	# the entry point for the player into the scene
	# player_handle.transform = start_handle.transform


func _input(event):

	# for debugging purposes, since the mouse is locked, escape can be used to quit
	if Input.is_action_pressed("debug_exit"):
		get_tree().quit()

	# it is necessary to pass the mouse movement from the Main node (where
	# it gets captured), into the Player node in the Viewport (where it is
	# actually needed in order to get the mouse look to work)
	if event is InputEventMouseMotion:
		player_handle.mouse_movement = event.relative
		
	if event is InputEventKey:
		player_handle.handle_key_press(event)
