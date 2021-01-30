extends OmniLight

var initialFlickerTimer = 0.15
var deviationFlikerTimer = 0.25

var initialLight = 0.75
var deviationLight = 0.6

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
	print("test")

	pass # Replace with function body.
