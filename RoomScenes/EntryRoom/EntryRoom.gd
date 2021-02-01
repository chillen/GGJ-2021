extends Spatial

export var number_of_switches_on = 2
var num_current_on = 0
var  a = false
var  b = false
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
func check_door_open():
	if a and b :
		$WallDoor.open_non_interaction()
		#yield(get_tree().create_timer(10),"timeout")
		


func check_door_close():
	if not a and not b:
		$WallDoor.close_non_interaction()
		

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


func _on_FirePedestal_off():
	a = false
	check_door_close()


func _on_FirePedestal_on():
	a = true
	check_door_open()


func _on_FirePedestal2_off():
	b = false
	check_door_close()


func _on_FirePedestal2_on():
	b = true
	check_door_open()


func _on_Hallway_body_shape_entered(body_id, body, body_shape, local_shape):
	a = false
	b = false
	check_door_close()
	pass # Replace with function body.
