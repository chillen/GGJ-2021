extends StaticBody

const takes_input = true
var display_text = "This is a really awesome tree. No Forest, it really isn't. Perhaps it used to be..."
onready var animation_player = $"../AnimationPlayer"
onready var black_board = get_node("/root/BlackBoard").bb


func _ready():
	pass
	# animation_player.seek(0.0, true)


func handle_command(command):
	# todo: probably can light the same pillar 3 times right now
	if command == "light":
		animation_player.play("Activated")
		
		black_board["activated_pillars"] += 1
		if black_board["activated_pillars"] == 1:
			print("test1")
		
		return true
	return false


func _on_AnimationPlayer_animation_finished(anim_name):
	black_board["activated_pillars"] -= 1
