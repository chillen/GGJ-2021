extends StaticBody

const takes_input = true
var display_text = "This is a really awesome tree. No Forest, it really isn't. Perhaps it used to be..."
onready var animation_player = $"../AnimationPlayer"


func _ready():
	animation_player.seek(0.0, true)


func handle_command(command):
	if command == "light":
		animation_player.play("Activated")
		return true
	return false
