extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Interactable_interacted(interaction_string, interaction_caller):
	if (interaction_string == "light" or 1 == 1) and \
		not interaction_caller.item_in_inventory == null and \
		interaction_caller.item_in_inventory.is_in_group("fire"):
			
		
		interaction_caller.item_in_inventory.on = true
		return true
