extends StaticBody

const takes_input = true
var display_text = "This is a really awesome tree"

onready var emitter: Particles = $"/root/Main/Viewport/Spatial/Tree/Particles"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass  # Replace with function body.


func handle_command(command):
	if command == "flip":
		emitter.emitting = true
		get_parent().translate(Vector3(0, 5, 0))
		get_parent().rotate_z(PI)
		return true
	if command == "sparkle":
		emitter.emitting = true
		return true

	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
