extends Spatial

signal on
signal off

var toggle = false


func press(interaction_string):
	toggle = ! toggle

	if $AnimationPlayer.is_playing():
		return

	if toggle:
		emit_signal("on")
		$AnimationPlayer.play("Button_Press")
	else:
		emit_signal("off")
		$AnimationPlayer.play_backwards("Button_Press")
