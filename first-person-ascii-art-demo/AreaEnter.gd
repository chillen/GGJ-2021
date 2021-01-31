extends Area
# Note : use layer 3 for collision with player
export var text = "Area Entered"
export var multiple_enter = true
var inital_enter = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Object_body_shape_entered(body_id, body, body_shape, local_shape):
	if not inital_enter :
		body.terminal_call(text)
		inital_enter = not inital_enter
	elif multiple_enter:
		body.terminal_call(text)

