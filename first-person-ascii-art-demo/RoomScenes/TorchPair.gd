extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AreaEnter_body_shape_entered(body_id, body, body_shape, local_shape):
	$TorchP1.show()
	$TorchP2.show()
	pass # Replace with function body.


func _on_AreaEnter_body_shape_exited(body_id, body, body_shape, local_shape):
	yield (get_tree().create_timer(4),"timeout")
	$TorchP1.hide()
	$TorchP2.hide()
	
	pass # Replace with function body.
