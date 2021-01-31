extends Spatial

export var animation_open = "Hinge_Open"
export var locked_text = "Does not seem to budge."
export var open_text = "You hear creaking as it opens"
export var close_text = "You hear creaking as it closes"
export var is_open = false
export var locked = false

export var audio: AudioStream = null

signal open
signal closed


func _ready():
	if is_open:
		$AnimationPlayer.play(animation_open)
	else:
		$AnimationPlayer.play_backwards(animation_open)
	pass  # Replace with function body.
	
	$OpeningNoise.stream = audio


func interaction(interaction,interaction_caller):
	if locked:
		interaction_caller.terminal_call(locked_text)
		# print something to terminal
		# play sound that might sugest locked
		return
	if is_open and interaction == "close":
		close()
		interaction_caller.terminal_call(close_text)
		
	elif not is_open and interaction == "open":
		open()
		interaction_caller.terminal_call(open_text)
		


func open():
	if is_open:
		return
	if $AnimationPlayer.is_playing():
		return
	$AnimationPlayer.play(animation_open)
	is_open = true
	emit_signal("open")
	$OpeningNoise.play()
	pass


func close():
	if not is_open:
		return
	if $AnimationPlayer.is_playing():
		return

	$AnimationPlayer.play_backwards(animation_open)
	emit_signal("closed")
	is_open = false
	$OpeningNoise.play()
	pass
