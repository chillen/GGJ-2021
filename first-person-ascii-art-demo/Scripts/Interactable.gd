extends KinematicBody

export var display_text = "DEFAULT DISPLAY TEXT"
var looking_at = false setget set_looking_at

signal interacted(interaction_string,interaction_caller)


func _ready():
	pass


func interact(interaction_string,interaction_caller):
	emit_signal("interacted", interaction_string,interaction_caller)


func set_looking_at(val: bool):
	$OmniLight.visible = val
	looking_at = val
