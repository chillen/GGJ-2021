extends Spatial

export var on = false

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
		interaction_caller.terminal_call("You pick up the torch, it is greased in oil.")
	if interaction_string == "drop":
		interaction_caller.de_equip_item(self)
	if interaction_string == "use" or state == 1:
		if on and 0 == 1:
			$TorchLight.hide()
		else:
			$TorchLight.show()
			interaction_caller.terminal_call("You take the Flint in your pocket and light the torch.")
		on = !on
		state = 2
	
	


func _on_RandomTimer_timeout():
	pass # Replace with function body.
