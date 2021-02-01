extends DirectionalLight

onready var blackboard = $"/root/BlackBoard"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if blackboard.ambient_light_enabled:
		show()
	else:
		hide()
