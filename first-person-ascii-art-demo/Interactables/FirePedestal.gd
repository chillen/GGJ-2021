extends Spatial

onready var animation_player = $"AnimationPlayer"
onready var black_board = get_node("/root/BlackBoard").bb
onready var interactable = get_node("Interactable")
onready var particles = get_node("PedestalParticles")

export var lit = false setget set_lit

signal on
signal off


func _ready():
	pass
	# animation_player.seek(0.0, true)


func handle_command(command,interaction_caller):
	# todo: probably can light the same pillar 3 times right now

	print(interaction_caller.item_in_inventory)
	if command == "light" and \
		not interaction_caller.item_in_inventory == null and \
		interaction_caller.item_in_inventory.is_in_group("fire") and \
		interaction_caller.item_in_inventory.get("on") == true:
			
		animation_player.play("Activated")
		self.lit = true
		
		emit_signal("on")
		
		#black_board["activated_pillars"] += 1
		#if black_board["activated_pillars"] == 1:
		#	print("test1")
		
		return true
	return false


func _on_AnimationPlayer_animation_finished(anim_name):
	#black_board["activated_pillars"] -= 1
	emit_signal("off")


func _on_Interactable_interacted(interaction_string,interaction_caller):
	handle_command("light",interaction_caller)


func set_lit(val: bool):
	if interactable:
		if val:
			interactable.display_text = "The brazier gives off a warm flame."
		else:
			interactable.display_text = "The brazier is warm, but remains unlit."
	lit = val
	if particles:
		particles.emitting = val
