extends Spatial

signal on
signal off

var toggle = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func _process(delta):
#	if Input.is_action_just_pressed("ui_accept"):
#		press()

func press(interaction_string):
	toggle = !toggle

	if $AnimationPlayer.is_playing():
		return
		
	if toggle:
		emit_signal("on")
		$AnimationPlayer.play("Button_Press")
	else:
		emit_signal("off")
		$AnimationPlayer.play_backwards("Button_Press")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
