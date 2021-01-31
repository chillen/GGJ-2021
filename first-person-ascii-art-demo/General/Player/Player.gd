extends KinematicBody

# these are the constants representing the three possible states of the game pertaining to 
# user input; in COMMAND_LINE mode, mouse look is disabled and any key presses appear in the
# terminal display in the bottom left; in FP_SHOW_TEXT mode mouse look is disabled and the
# player cannot move but their key presses are used in the text entry frame in the first person
# view; in FP_FREE_LOOK, mouse look is enables and key presses are used to move about the scene
enum UserInputMode { COMMAND_LINE, FP_STILL_IMG, FP_TXT_ENTRY, FP_FREE_LOOK, FP_NONE }


# this is the variable controlling the state of the game pertaining to user input
var user_input_state = UserInputMode.COMMAND_LINE

# Objects will look at this varible, and play a sound depending on the current state
# State : 1, 2 (can add more, but modification to objects needed)
export var audio_state = 1
export var pitch_deviance = 0.2
var initial_pitch = 1

export var fidelity_colour : float = 1
export var char_colour : float = 1

# this code is adapted from a first-person shooter in Godot tutorial that I was
# working through the other day... it could probably use some refinement... :)

var running = false
var walk_speed: float = 5.0
var run_speed: float = 12.0
var gravity_force: float = 60.0

var velocity: Vector3 = Vector3()

var minimum_look_angle: float = -90.0
var maximum_look_angle: float = 90.0

var mouse_sensitivity: float = 10.0
var mouse_movement: Vector2 = Vector2()

var buffer_display: String = ""
var buffer_command: String = ""

# handles to the various components that must be accessed
onready var camera_handle: Camera = $"Camera"
onready var camera_raycast: RayCast = $"Camera/RayCast"
onready var terminal_handle: Node = $"/root/Main/Terminal"
onready var lineedit_handle: LineEdit = $"/root/Main/LineEdit"
onready var ascii_art: Sprite = $"/root/Main/AsciiArt"

onready var anime : AnimationPlayer = $FidelityAnimation


onready var examine_memory: Node
onready var looking_memory: Node


var hidden_torch = null
onready var item_in_inventory = null

# used by AsciiArt
var object_to_interact_with

func _ready():
	# lock down the mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	initial_pitch = $FootSteps.pitch_scale


func _physics_process(delta):
	if Input.is_action_pressed("debug_command_line_mode"):
		user_input_state = UserInputMode.COMMAND_LINE
	if Input.is_action_pressed("debug_fp_free_look_mode"):
		user_input_state = UserInputMode.FP_FREE_LOOK
	if Input.is_action_pressed("debug_fp_txt_entry_mode"):
		user_input_state = UserInputMode.FP_TXT_ENTRY
	if Input.is_action_pressed("debug_fp_still_img_mode"):
		user_input_state = UserInputMode.FP_STILL_IMG

	# zero out the x and z components of velocity each frame
	# (but don't clear y because the player might be "falling" or something)
	velocity.x = 0
	velocity.z = 0

	# clear the user input vector
	var input = Vector2()

	if not (user_input_state == UserInputMode.FP_FREE_LOOK):
		lineedit_handle.grab_focus()

	else:
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
			if Input.is_action_pressed("run"):
				running = true
			else:
				running = false

			# normalize it (so that diagonal movement is not faster)
			input = input.normalized()

		# this is obviously for sound, but I am not sure why it is here with the input handling
		# maybe we could move this down towards the "render" area at the bottom of this function?
		if (input.x != 0 or input.y != 0) and not $FootSteps.playing and is_on_floor():
			$FootSteps.pitch_scale = rand_range(
				max(0, initial_pitch - pitch_deviance), initial_pitch + pitch_deviance
			)
			$FootSteps.play()
		if Input.is_action_just_pressed("move_jmp") and is_on_floor():
			$FootSteps.play()

		# now compute the relative direction using the global transform
		var relative_direction = (
			global_transform.basis.x * input.x
			+ global_transform.basis.z * input.y
		)
		
		# compute the components of the velocity vector and pass to move_and_slide 
		if running:
			velocity.x = relative_direction.x * run_speed
			velocity.z = relative_direction.z * run_speed
		else:
			velocity.x = relative_direction.x * walk_speed
			velocity.z = relative_direction.z * walk_speed
		velocity.y -= gravity_force * delta
		velocity = move_and_slide(velocity, Vector3.UP)

		# if the user is in free look or show text mode then the raycast of the player must be checked
		if user_input_state == UserInputMode.FP_FREE_LOOK:
			# hide the spotlight
			# spotlight_handle.hide()
			

			if camera_raycast.get_collider():
				if examine_memory != camera_raycast.get_collider():
					examine_memory = null

				if (
					'display_text' in camera_raycast.get_collider()
					or 'takes_input' in camera_raycast.get_collider()
				):
					pass
					#spotlight_handle.transform.origin = camera_raycast.get_collision_point() + (Vector3.UP * 3)
					#spotlight_handle.show()

				# if the player is trying to interact with an interactible object in front of them, then change mode to text entry
				if Input.is_action_just_pressed("interact"):
					# my changes
					
					# user_input_state = UserInputMode.FP_TXT_ENTRY
					object_to_interact_with = camera_raycast.get_collider()
					# terminal_handle.flashing_prompt_timer = 10
					self.action("", object_to_interact_with)
					

					# code that works but doesnt take input
					# camera_raycast.get_collider().interact("")

				# if the raycast collides with something that has a description, then change mode to show text
				elif (
					Input.is_action_just_pressed("examine")
					and 'display_text' in camera_raycast.get_collider()
					and examine_memory != camera_raycast.get_collider()
				):
					# the raycast must "remember" the thing that it most recently interacted with to ensure that "triggers" don't happen every frame
					examine_memory = camera_raycast.get_collider()
					terminal_handle.print_to_terminal(camera_raycast.get_collider().display_text)
					terminal_handle.print_to_terminal(">")

				else:
					user_input_state = UserInputMode.FP_FREE_LOOK
			# If we have an item equiped, the interact with item though terminal
			elif $Camera/Item/Right.get_child_count() > 0 and Input.is_action_just_pressed("interact"):
				
#				user_input_state = UserInputMode.FP_TXT_ENTRY
				object_to_interact_with = $Camera/Item/Right.get_child(0).find_node("Interactable")
#				terminal_handle.flashing_prompt_timer = 20
				
				
			else:
				examine_memory = null
				user_input_state = UserInputMode.FP_FREE_LOOK
				
# Player calling interactable object to do task
# called from AsciiArt
func action(input, interactable):
	interactable.interact(input, self)

# used by interactables to call to terminal
func terminal_call(text):
	terminal_handle.print_to_terminal(text)
	
# checks if no other items are equipted
# equipts the item
func equip_item(item):
	if $Camera/Item/Right.get_child_count() > 0:
		return false
	var parent = item.get_parent()
	parent.remove_child(item)
	$Camera/Item/Right.add_child(item)
	item.set_owner($Camera/Item/Right)
	
	item_in_inventory = item
	
	return true

# checks if interaction item, is item in hand
# check if I ahve any items
# drops item at player position
func de_equip_item(item_inter):
	print("de-equip")
	var item = $Camera/Item/Right.get_child(0)
	if $Camera/Item/Right.get_child_count() <= 0 or not item_inter == item:
		return false
	
	$Camera/Item/Right.remove_child(item)
	self.get_parent().add_child(item)
	item.set_owner(self.get_parent())
	item.translation = self.translation
	
	item_in_inventory = null
	
	return true

func equip_torch_from_holder():
	if hidden_torch == null or $Camera/Item/Right.get_child_count() > 0:
		return false
	
	hidden_torch.show()
	$Camera/Item/Right.add_child(hidden_torch)
	hidden_torch.set_owner($Camera/Item/Right)
	hidden_torch = null
	
func unequip_torch_to_holder():
	if $Camera/Item/Right.get_child_count() <= 0:
		return false
		
	hidden_torch = $Camera/Item/Right.get_child(0)
	$Camera/Item/Right.remove_child(hidden_torch)
	hidden_torch.hide()

func jump_off():
	$"../PlayerAnimations".play("ThrowOff")
	


func _process(delta):
	ascii_art.colour_fidelity = fidelity_colour
	# using the mouse movement captured and passed down from main, rotate the camera (if permitted by the current state)
	if user_input_state == UserInputMode.FP_FREE_LOOK:
		camera_handle.rotation_degrees.x -= mouse_movement.y * mouse_sensitivity * delta
		camera_handle.rotation_degrees.x = clamp(
			camera_handle.rotation_degrees.x, minimum_look_angle, maximum_look_angle
		)
		rotation_degrees.y -= mouse_movement.x * mouse_sensitivity * delta

	# clear the mouse movement vector each frame
	mouse_movement = Vector2()
