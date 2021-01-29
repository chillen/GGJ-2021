extends KinematicBody

# this code is adapted from a first-person shooter in Godot tutorial that I was
# working through the other day... it could probably use some refinement... :)

# Objects will look at this varible, and play a sound depending on the current state
# State : 1, 2 (can add more, but modification to objects needed)
export var audio_state = 1

var movement_speed : float = 5.0
var jumping_force : float = 5.0
var gravity_force : float = 12.0

var velocity : Vector3 = Vector3()

var minimum_look_angle : float = -90.0
var maximum_look_angle : float = 90.0

var mouse_sensitivity : float = 10.0
var mouse_movement : Vector2 = Vector2()

var last_command_result : bool = false
var command_cooldown : int = 0
const command_cooldown_time : int = 30

const selection_ray_length = 1000
var is_object_selected : bool = false
var accept_text_input : bool = false
var selected_object_id : int = -1
var command_text_buffer = ""
const text_buffer_width = 24

onready var camera_handle : Camera = $"Camera"
onready var camera_raycast : RayCast = $"Camera/RayCast"

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
	if not accept_text_input:
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

	if not camera_raycast.get_collider():
		accept_text_input = false
		is_object_selected = false
	elif camera_raycast.get_collider().get_instance_id() != selected_object_id or not is_object_selected:
		
		if 'takes_input' in camera_raycast.get_collider() and camera_raycast.get_collider().takes_input:
			is_object_selected = true
			accept_text_input = true
			if camera_raycast.get_collider().get_instance_id() != selected_object_id:
				selected_object_id = camera_raycast.get_collider().get_instance_id()
				command_text_buffer = ""

func _process(delta):
	
	if command_cooldown > 0:
		command_cooldown -= 1
	
	# using the mouse movement captured and passed down from main, rotate the camera
	camera_handle.rotation_degrees.x -= mouse_movement.y * mouse_sensitivity * delta
	camera_handle.rotation_degrees.x = clamp(camera_handle.rotation_degrees.x, minimum_look_angle, maximum_look_angle)
	rotation_degrees.y -= mouse_movement.x * mouse_sensitivity * delta
	
	# clear the mouse movement vector each frame
	mouse_movement = Vector2()

const letter_lookup_table = {
	KEY_A: 'a',
	KEY_B: 'b',
	KEY_C: 'c',
	KEY_D: 'd',
	KEY_E: 'e',
	KEY_F: 'f',
	KEY_G: 'g',
	KEY_H: 'h',
	KEY_I: 'i',
	KEY_J: 'j',
	KEY_K: 'k',
	KEY_L: 'l',
	KEY_M: 'm',
	KEY_N: 'n',
	KEY_O: 'o',
	KEY_P: 'p',
	KEY_Q: 'q',
	KEY_R: 'r',
	KEY_S: 's',
	KEY_T: 't',
	KEY_U: 'u',
	KEY_V: 'v',
	KEY_W: 'w',
	KEY_X: 'x',
	KEY_Y: 'y',
	KEY_Z: 'z'
}

func handle_key_press(event):
	if command_cooldown == 0:
		if event.pressed and event.scancode >= KEY_A and event.scancode <= KEY_Z and accept_text_input: 
			if len(command_text_buffer) < text_buffer_width:
				command_text_buffer += letter_lookup_table[event.scancode]
		if event.pressed and event.scancode == KEY_SPACE and len(command_text_buffer) < text_buffer_width:
			command_text_buffer += ' '
		if event.pressed and event.scancode == KEY_BACKSPACE and len(command_text_buffer) > 0:
			command_text_buffer = command_text_buffer.substr(0,len(command_text_buffer)-1)
		if event.pressed and event.scancode == KEY_ENTER and len(command_text_buffer) > 0:
			var selected_object = instance_from_id(selected_object_id)
			var command_result = false
			if selected_object.has_method("handle_command"):
				command_result = selected_object.handle_command(command_text_buffer)
			else:
				print("Object should be able to handle commands!")
			
			if command_result == true:
				last_command_result = true
			else:
				last_command_result = false
			
			command_text_buffer = ""
			command_cooldown = command_cooldown_time
