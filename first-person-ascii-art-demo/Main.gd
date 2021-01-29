extends Node2D


onready var player_handle : KinematicBody = $"FirstPersonViewport/GameWorld/Player"


func _input(event):

	# for debugging purposes, since the mouse is locked, escape can be used to quit
	if Input.is_action_pressed("debug_exit"):
		get_tree().quit()

	# it is necessary to pass the mouse movement from the Main node (where
	# it gets captured), into the Player node in the Viewport (where it is
	# actually needed in order to get the mouse look to work)
	if event is InputEventMouseMotion:
		player_handle.mouse_movement = event.relative
