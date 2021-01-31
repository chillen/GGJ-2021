extends Spatial

onready var lights = [
	[$"puzzle_lights/lightpair0/far", $"puzzle_lights/lightpair0/close"],
	[$"puzzle_lights/lightpair1/far", $"puzzle_lights/lightpair1/close"],
	[$"puzzle_lights/lightpair2/right", $"puzzle_lights/lightpair2/left"],
	[$"puzzle_lights/lightpair3/close", $"puzzle_lights/lightpair3/far"],
	[$"puzzle_lights/lightpair4/left", $"puzzle_lights/lightpair4/right"],
	[$"puzzle_lights/lightpair5/far", $"puzzle_lights/lightpair5/close"],
	[$"puzzle_lights/lightpair6/close", $"puzzle_lights/lightpair6/far"]
]

onready var hidden_door_collisions = [
	$HiddenDoors/HiddenDoor1/StaticBody/CollisionShape,
	$HiddenDoors/HiddenDoor2/StaticBody/CollisionShape
]

onready var draw_bridge = $DrawBridge
onready var invisible_wall = $InvisibleWall
onready var hidden_doors = $HiddenDoors

onready var env_lights = $env_lights
onready var puzzle_lights = $puzzle_lights

onready var blackboard = $"/root/BlackBoard"

var is_on = false

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_off()
	
	for light_pair in lights:
		light_pair[0].show()
		light_pair[1].hide()
		
func turn_on():
	is_on = true
	puzzle_lights.show()
	env_lights.show()
	hidden_doors.hide()
	for door in hidden_door_collisions:
		door.disabled = true

func turn_off():
	is_on = false
	puzzle_lights.hide()
	env_lights.hide()
	hidden_doors.show()
	for door in hidden_door_collisions:
		door.disabled = false

func _on_button_on(button_id):
	lights[button_id][0].hide()
	lights[button_id][1].show()

func _on_button_off(button_id):
	lights[button_id][0].show()
	lights[button_id][1].hide()

func _on_enter(body_id, body, body_shape, local_shape):
	blackboard.ambient_light_enabled = false

func _on_exit(body_id, body, body_shape, local_shape):
	blackboard.ambient_light_enabled = true
