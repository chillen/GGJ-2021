extends Spatial

onready var light_maze = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Interactable_interacted(interaction_string, interaction_caller):
	if not light_maze.is_on:
		interaction_caller.terminal_call("This wall looks like it can move. Maybe I should come back later.")
	else:
		interaction_caller.terminal_call("There used to be a wall here.")


func _on_Interactable2_interacted(interaction_string, interaction_caller):
	if not light_maze.is_on:
		interaction_caller.terminal_call("This wall looks like it can move. Maybe I should come back later.")
	else:
		interaction_caller.terminal_call("There used to be a wall here.")
