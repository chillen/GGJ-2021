extends Spatial

export var on = false setget set_on

onready var torchlight = $TorchLight
var state = 0


func _ready():
	if on:
		$TorchLight.show()
	else:
		$TorchLight.hide()
	

	
# Override interactions to only allow it to be picked up, and then turned on
func _on_Interactable_interacted(interaction_string,interaction_caller):
	if interaction_string == "take" or state == 0:
		interaction_caller.equip_item(self)
		self.rotation_degrees = Vector3(0,0, 0)
		self.translation = Vector3(0,0,0)
		state = 1
	if interaction_string == "drop":
		interaction_caller.de_equip_item(self)
	if interaction_string == "use" or state == 1:
		if not on:
			$TorchLight.hide()
		else:
			$TorchLight.show()
		on = !on
		state = 2
	
	
func set_on(val):
	if torchlight:
		if val:
			$TorchLight.show()
		else:
			$TorchLight.hide()
	on = val
			
func _on_RandomTimer_timeout():
	pass # Replace with function body.
