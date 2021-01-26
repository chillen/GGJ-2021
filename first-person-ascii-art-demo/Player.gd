extends KinematicBody

# this code is adapted from a first-person shooter in Godot tutorial that I was
# working through the other day... it could probably use some refinement... :)

var movement_speed : float = 5.0
var jumping_force : float = 5.0
var gravity_force : float = 12.0

var velocity : Vector3 = Vector3()

var minimum_look_angle : float = -90.0
var maximum_look_angle : float = 90.0

var mouse_sensitivity : float = 10.0
var mouse_movement : Vector2 = Vector2()


onready var camera_handle : Camera = $"Camera"


func _ready():
	
	# lock down the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 


func _physics_process(delta):
	
	# zero out the x and z components of velocity each frame
	# (but don't clear y because the player might be "falling" or something)
	velocity.x = 0
	velocity.z = 0

	# get a 2D vector corresponding to the movement inputs received
	var input = Vector2()
	if Input.is_action_pressed("move_fwd"):
		input.y -= 1
	if Input.is_action_pressed("move_bwd"):
		input.y += 1
	if Input.is_action_pressed("move_lft"):
		input.x -= 1
	if Input.is_action_pressed("move_rgt"):
		input.x += 1
	if Input.is_action_pressed("move_jmp") and is_on_floor():
		velocity.y = jumping_force

	# normalize it (so that diagonal movement is not faster)
	input = input.normalized()

	# now compute the relative direction using the global transform
	var relative_direction = (global_transform.basis.x * input.x + global_transform.basis.z * input.y)

	# compute the components of the velocity vector and pass to move_and_slide 
	velocity.x = relative_direction.x * movement_speed
	velocity.z = relative_direction.z * movement_speed
	velocity.y -= gravity_force * delta
	velocity = move_and_slide(velocity, Vector3.UP)


func _process(delta):
	
	# using the mouse movement captured and passed down from main, rotate the camera
	camera_handle.rotation_degrees.x -= mouse_movement.y * mouse_sensitivity * delta
	camera_handle.rotation_degrees.x = clamp(camera_handle.rotation_degrees.x, minimum_look_angle, maximum_look_angle)
	rotation_degrees.y -= mouse_movement.x * mouse_sensitivity * delta
	
	# clear the mouse movement vector each frame
	mouse_movement = Vector2()

