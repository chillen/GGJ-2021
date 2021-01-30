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


# Called when the node enters the scene tree for the first time.
func _ready():
	for light_pair in lights:
		light_pair[0].show()
		light_pair[1].hide()


func _on_button_on(button_id):
	lights[button_id][0].hide()
	lights[button_id][1].show()


func _on_button_off(button_id):
	lights[button_id][0].show()
	lights[button_id][1].hide()
