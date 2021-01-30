extends Spatial

onready var animation_player = $"AnimationPlayer"
onready var black_board = get_node("/root/BlackBoard").bb
onready var interactable = get_node("Interactable")
var lit = false setget set_lit


func _ready():
	pass
	# animation_player.seek(0.0, true)


func handle_command(command):
	# todo: probably can light the same pillar 3 times right now
	if command == "light":
		animation_player.play("Activated")
		self.lit = true

		black_board["activated_pillars"] += 1
		if black_board["activated_pillars"] == 1:
			print("test1")

		return true
	return false


func _on_AnimationPlayer_animation_finished(anim_name):
	black_board["activated_pillars"] -= 1


func _on_Interactable_interacted(interaction_string):
	handle_command("light")


func set_lit(val: bool):
	if val:
		interactable.display_text = "The brazier gives off a warm flame."
	else:
		interactable.display_text = "The brazier is warm, but remains unlit."
	lit = val
