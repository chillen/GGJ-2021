extends Spatial

onready var lectern = $Lectern
onready var tp_pose = $PlayerTPLocation
onready var boulders = $boulder_pile
onready var boulder_messager = $Messages/BoulderObserve

var boulder_forgot_msg_sent = false
var boulder_forgot = false
var boulders_removed = false
var boulders_messaged_once = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_WalkAwayTrigger_body_shape_entered(body_id, body, body_shape, local_shape):
	if lectern.read_once and not boulders_removed:
		body.global_transform = tp_pose.global_transform
		body.anime.play_backwards("Fidelity_Increase")
		$Messages/LecturnMessage.queue_free()
		#body.ascii_art.colour_fidelity = 0.25
		#body.ascii_art.palette_usage = 0
		boulders_removed = true
		boulders.visible = false
		body.terminal_call("What.. happened. I read the book and.. Its all.. Hazy... Different.")
		boulder_forgot = true
		boulder_messager.text = "There... Was there something here before? My memory fails me."
		
		lectern.teleported_away = true
		
		# Turn off collisions
		boulders.get_node("StaticBody").collision_layer = 0
		boulders.get_node("StaticBody").collision_mask = 0

func _on_BoulderObserve_body_shape_entered(body_id, body, body_shape, local_shape):
	if boulder_forgot and not boulder_forgot_msg_sent and boulders_messaged_once:
		body.terminal_call("There... Was there something here before? My memory fails me.")
		boulder_forgot_msg_sent = true
	if not boulder_forgot:
		boulders_messaged_once = true
