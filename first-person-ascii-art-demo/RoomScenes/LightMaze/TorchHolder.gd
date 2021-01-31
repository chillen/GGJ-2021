extends MeshInstance

onready var light_maze = get_parent()
onready var hidden_torch = $Torch
onready var torchlight = $Torch/TorchLight
onready var black_board = get_node("/root/BlackBoard")

var torch_placed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hidden_torch.hide()
	pass # Replace with function body.

func _on_Interactable_interacted(interaction_string, interaction_caller):
	if (interaction_string == 'put' or interaction_string == 'place' or 1 == 1) and not torch_placed:
		hidden_torch.show()
		torchlight.show()
		interaction_caller.unequip_torch_to_holder()
		torch_placed = true
		light_maze.turn_on()
		interaction_caller.jump_off()
		black_board.beat_matt_maze = true
		interaction_caller.anime.play("Fidelity_Increase")
		return
	if (interaction_string == 'take' or interaction_string == 'grab' or 1 == 1) and torch_placed:
		hidden_torch.hide()
		interaction_caller.equip_torch_from_holder()
		torch_placed = false
		light_maze.turn_off()
		return
	
