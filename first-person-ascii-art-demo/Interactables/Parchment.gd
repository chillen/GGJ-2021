extends Spatial


export var interact_text = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Interactable_interacted(interaction_string, interaction_caller):
	$AudioStreamPlayer.play()
	hide()
	interaction_caller.terminal_call(interact_text)
