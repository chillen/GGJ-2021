extends Spatial

export var number_of_switches_on = 2
var num_current_on = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#print("opening")
	#$WallDoor.open()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func switch_signal(on_off_number):
	num_current_on += on_off_number
	if num_current_on == number_of_switches_on:
		$WallDoor.open()
	else:
		$WallDoor.close()
	print(on_off_number)
	#if on_off_number == -1 :
	#	print("close")
	#	$DoorTemplate2.close()
	#if on_off_number == 1 : 
	#	print("open")
	#	$DoorTemplate2.open()
	
	#$WallDoor/AnimationPlayer.play("Hinge_Up")

	#print(num_current_on)
	#print($WallDoor.is_open)
	#num_current_on += on_off_number
	#if num_current_on == number_of_switches_on:
	#	$WallDoor.open()
	#	print("open")
	#else:
	#	$WallDoor.close()
	#	print("close")
