extends MeshInstance

var is_removed = false
onready var collision_shape : CollisionShape = $StaticBody/CollisionShape

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func remove():
	if is_removed == true:
		return
	
	is_removed = true
	collision_shape.disabled = true
