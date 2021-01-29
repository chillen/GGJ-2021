extends KinematicBody

# these are the constants representing the three possible states of the game pertaining to 
# user input; in COMMAND_LINE mode, mouse look is disabled and any key presses appear in the
# terminal display in the bottom left; in FP_SHOW_TEXT mode mouse look is disabled and the
# player cannot move but their key presses are used in the text entry frame in the first person
# view; in FP_FREE_LOOK, mouse look is enables and key presses are used to move about the scene
enum UserInputMode {
	COMMAND_LINE,
	FP_SHOW_TEXT,
	FP_TXT_ENTRY,
	FP_FREE_LOOK	
}

# this is the variable controlling the state of the game pertaining to user input
var user_input_state = UserInputMode.FP_FREE_LOOK

# Objects will look at this varible, and play a sound depending on the current state
# State : 1, 2 (can add more, but modification to objects needed)
export var audio_state = 1

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

var buffer_display : String = ""
var buffer_command : String = ""

# handles to the various components that must be accessed
onready var camera_handle : Camera = $"Camera"
onready var spotlight_handle : SpotLight = $"SpotLight"
onready var camera_raycast : RayCast = $"Camera/RayCast"
onready var terminal_handle : Node = $"/root/Main/Terminal"
onready var raycast_memory : Node


func _ready():
	
	# lock down the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 


func _physics_process(delta):
	
	if Input.is_action_pressed("debug_command_line_mode"):
		user_input_state = UserInputMode.COMMAND_LINE
	if Input.is_action_pressed("debug_fp_free_look_mode"):
		user_input_state = UserInputMode.FP_FREE_LOOK
	if Input.is_action_pressed("debug_fp_txt_entry_mode"):
		user_input_state = UserInputMode.FP_TXT_ENTRY
	if Input.is_action_pressed("debug_fp_show_text_mode"):
		user_input_state = UserInputMode.FP_SHOW_TEXT
		
	# zero out the x and z components of velocity each frame
	# (but don't clear y because the player might be "falling" or something)
	velocity.x = 0
	velocity.z = 0

	# clear the user input vector
	var input = Vector2()

	if user_input_state == UserInputMode.FP_FREE_LOOK:
			
		# get a 2D vector corresponding to the movement inputs received
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

	# if the user is in free look or show text mode then the raycast of the player must be checked
	if user_input_state == UserInputMode.FP_FREE_LOOK or user_input_state == UserInputMode.FP_SHOW_TEXT:
		
		if camera_raycast.get_collider():
			
			if 'display_text' in camera_raycast.get_collider() or 'takes_input' in camera_raycast.get_collider():
				spotlight_handle.position = camera_raycast.get_collider().position
				spotlight_handle.show()

			# if the player is trying to interact with an interactible object in front of them, then change mode to text entry
			if Input.is_action_pressed("interact") and 'takes_input' in camera_raycast.get_collider() and camera_raycast.get_collider().takes_input:
				# user_input_state = UserInputMode.FP_TXT_ENTRY
				pass

			# if the raycast collides with something that has a description, then change mode to show text
			elif Input.is_action_pressed("examine") and 'display_text' in camera_raycast.get_collider() and raycast_memory != camera_raycast.get_collider():
				user_input_state = UserInputMode.FP_SHOW_TEXT
				terminal_handle.print_to_terminal(camera_raycast.get_collider().display_text)
				
				# display the contents of the buffer (for debugging purposes
				for i in range(len(terminal_handle.screen_buffer_data)):
					print(i, terminal_handle.screen_buffer_data[i])
				print(terminal_handle.last_printed_row, " ", terminal_handle.last_printed_col, " ", terminal_handle.last_buffered_row, " ", terminal_handle.last_buffered_col)				

			else:
				user_input_state = UserInputMode.FP_FREE_LOOK

			# the raycast must "remember" the thing that it most recently collided with to ensure that "triggers" don't happen every frame
			raycast_memory = camera_raycast.get_collider()
		
		else:
			
			user_input_state = UserInputMode.FP_FREE_LOOK
			
			# hide the spotlight
			spotlight_handle.hide()
			


func _process(delta):
	
	# using the mouse movement captured and passed down from main, rotate the camera (if permitted by the current state)
	if user_input_state == UserInputMode.FP_FREE_LOOK or user_input_state == UserInputMode.FP_SHOW_TEXT:
		camera_handle.rotation_degrees.x -= mouse_movement.y * mouse_sensitivity * delta
		camera_handle.rotation_degrees.x = clamp(camera_handle.rotation_degrees.x, minimum_look_angle, maximum_look_angle)
		rotation_degrees.y -= mouse_movement.x * mouse_sensitivity * delta
	
	# clear the mouse movement vector each frame
	mouse_movement = Vector2()
