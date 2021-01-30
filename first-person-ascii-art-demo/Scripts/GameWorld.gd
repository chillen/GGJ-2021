extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Main/TextAdventure".connect("cutscene", self, "_on_Cutscene_Request")
	
func _on_Cutscene_Request(scene):
	print("test")
	$PlayerAnimations.play("Intro walking")
