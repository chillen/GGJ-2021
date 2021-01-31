extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.connect("parchment_taken", self, "wall_interacted")


func wall_interacted(player):
	player.terminal_call("When I took the notes off of the wall I realized - this is my handwriting, my words. How could this be? What is this book? I must return to the book immediately and banish this invisible foe.")
	self.hide()
	BlackBoard.picked_up_notes = true
