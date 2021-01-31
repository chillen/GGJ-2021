extends OmniLight

export var initialFlickerTimer = 0.25
export var deviationFlikerTimer = 0.15

export var initialLight = 2
export var deviationLight = 0.3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	timer()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func timer():
	$RandomTimer.wait_time = rand_range(initialFlickerTimer-deviationFlikerTimer,initialFlickerTimer+deviationFlikerTimer)
	$RandomTimer.start()

func _on_RandomTimer_timeout():
	timer()
	self.light_energy = rand_range(initialLight-deviationLight,initialLight+deviationLight)

	pass # Replace with function body.
