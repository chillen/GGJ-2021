extends Spatial

signal on(interaction_caller)
signal off(interaction_caller)

var toggle = false
export var audio: AudioStream = null

func _ready():
	$ButtonClick.stream = audio

func press(interaction_string,interaction_caller):
	toggle = ! toggle

	if $AnimationPlayer.is_playing():
		return

	if toggle:
		emit_signal("on", interaction_caller)
		$ButtonClick.play()
		$AnimationPlayer.play("Button_Press")
		
	else:
		emit_signal("off", interaction_caller)
		$ButtonClick.play()
		$AnimationPlayer.play_backwards("Button_Press")
