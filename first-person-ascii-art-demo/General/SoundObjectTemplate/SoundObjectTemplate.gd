extends Area
signal Sound

export (AudioStreamSample) var fidelity_1
export (AudioStreamSample) var fidelity_2

export var distort_pitch = 0.1
var initial_pitch = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	initial_pitch = $AudioStream.pitch_scale
	pass  # Replace with function body.


# gets state of object entering
# plays audio snippet
# randomizes pitch
func _on_Object_body_shape_entered(body_id, body, body_shape, area_shape):
	#print(body.get("audio_state"))
	if not $AudioStream.playing:
		$AudioStream.pitch_scale = rand_range(
			max(0, initial_pitch - distort_pitch), initial_pitch + distort_pitch
		)
		#print($AudioStream.pitch_scale)
		if body.get("audio_state") == 1:
			$AudioStream.stream = fidelity_1
		if body.get("audio_state") == 2:
			$AudioStream.stream = fidelity_2
		$AudioStream.play()
