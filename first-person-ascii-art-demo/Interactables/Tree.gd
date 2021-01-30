extends StaticBody

const takes_input = true
var display_text = "This is a really awesome tree"

onready var emitter: Particles = $"/root/Main/Viewport/Spatial/Tree/Particles"


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
