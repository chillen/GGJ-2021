extends Spatial

const move_velocity = 0.4

onready var particles : Particles = $Particles

var player_obj : KinematicBody = null

# Called when the node enters the scene tree for the first time.
func _ready():
	particles.emitting = false
	pass # Replace with function body.

func _on_enter(body_id, body, body_shape, local_shape):
	print("test")
	# todo: if player
	if true:
		player_obj = body
		particles.emitting = true
		

func _on_exit(body_id, body, body_shape, local_shape):
	print("test")
	# todo: if player
	if true:
		player_obj = null
		particles.emitting = false

func _physics_process(delta):
	if player_obj:
		player_obj.move_and_collide(Vector3(move_velocity,0,0))
