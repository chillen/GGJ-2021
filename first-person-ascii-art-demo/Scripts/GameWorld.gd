extends Spatial

onready var player_handle: KinematicBody = $"Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Main/TextAdventure".connect("cutscene", self, "_on_Cutscene_Request")
	
func _on_Cutscene_Request(scene):
	
	print("cutscene request ", scene)
	
	match scene:
		
		"intro_walking":
			$PlayerAnimations.play("Intro walking")
		
		"ext_door_to_ante_camp":
			$PlayerAnimations.play("EnterTemple")
			yield($PlayerAnimations, "animation_finished")
			player_handle.user_input_state = player_handle.UserInputMode.FP_FREE_LOOK
			$"/root/Main/FirstPersonViewport/GameWorld/EntryRoom/DoorTemplate".close()
			
		"ante_camp_to_ante_w_brazier":
			$"Player".transform = $"ANTE_W_BRAZIER".transform
			
		"ante_camp_to_ante_e_brazier":
			$"Player".transform = $"ANTE_E_BRAZIER".transform

		"ante_w_brazier_to_ante_camp":
			$"Player".transform = $"ANTE_CAMP".transform

		"ante_w_brazier_to_ante_e_brazier":
			$"Player".transform = $"ANTE_E_BRAZIER".transform

		"ante_e_brazier_to_ante_camp":
			$"Player".transform = $"ANTE_CAMP".transform

		"ante_e_brazier_to_ante_w_brazier":
			$"Player".transform = $"ANTE_W_BRAZIER".transform
