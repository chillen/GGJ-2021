extends Spatial

export var animation_open = "Hinge_Open"
export var is_open = false
export var locked = false

signal open
signal closed


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_open:
		$AnimationPlayer.play(animation_open)
	else:
		$AnimationPlayer.play_backwards(animation_open)
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#	pass
func interaction(interaction):
	if locked:
		# print something to terminal
		# play sound that might sugest locked
		return

	if is_open:
		close()
	else:
		open()


func open():
	if is_open:
		return
	if $AnimationPlayer.is_playing():
		return

	$AnimationPlayer.play(animation_open)
	is_open = true
	emit_signal("open")
	pass


func close():
	if not is_open:
		return
	if $AnimationPlayer.is_playing():
		return

	$AnimationPlayer.play_backwards(animation_open)
	emit_signal("closed")
	is_open = false
	pass
