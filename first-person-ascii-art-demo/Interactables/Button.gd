extends Spatial

signal on
signal off

var toggle = false


func press(interaction_string,interaction_caller):
	toggle = ! toggle

	if $AnimationPlayer.is_playing():
		return

	if toggle:
		emit_signal("on")
		$AnimationPlayer.play("Button_Press")
		interaction_caller.terminal_call("It looks like this device lit up a different section of the platform.")
	else:
		emit_signal("off")
		$AnimationPlayer.play_backwards("Button_Press")
		interaction_caller.terminal_call("It looks like this device lit up a different section of the platform.")
