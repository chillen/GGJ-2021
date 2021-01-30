extends Spatial

export var on = false

func _ready():
	if on:
		$TorchLight.show()
	else:
		$TorchLight.hide()

func _on_Interactable_interacted(interaction_string,interaction_caller):
	if interaction_string == "take":
		interaction_caller.equip_item(self)
		self.rotation_degrees = Vector3(0,0, 0)
		self.translation = Vector3(0,0,0)
	if interaction_string == "drop":
		interaction_caller.de_equip_item(self)
	if interaction_string == "use":
		if on:
			$TorchLight.hide()
		else:
			$TorchLight.show()
		on = !on
	
	
