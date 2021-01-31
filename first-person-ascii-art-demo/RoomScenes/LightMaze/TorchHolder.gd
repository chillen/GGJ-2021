extends MeshInstance

onready var light_maze = get_parent()
onready var hidden_torch = $Torch
onready var torchlight = $Torch/TorchLight

var torch_placed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hidden_torch.hide()
	pass # Replace with function body.

func _on_Interactable_interacted(interaction_string, interaction_caller):
	if (interaction_string == 'put' or interaction_string == 'place') and not torch_placed:
		hidden_torch.show()
		torchlight.show()
		interaction_caller.unequip_torch_to_holder()
		torch_placed = true
		light_maze.turn_on()
		interaction_caller.jump_off()
		return
	if (interaction_string == 'take' or interaction_string == 'grab') and torch_placed:
		hidden_torch.hide()
		interaction_caller.equip_torch_from_holder()
		torch_placed = false
		light_maze.turn_off()
		return
	
