extends Spatial

export var animation_open = "Hinge_Open"

signal open
signal closed



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#	pass

func open():
	$AnimationPlayer.play(animation_open)
	emit_signal("open")
	pass
	
func close():
	$AnimationPlayer.play_backwards(animation_open)
	emit_signal("closed")
	pass
