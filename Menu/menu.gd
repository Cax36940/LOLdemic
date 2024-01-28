extends Control

const LEVEL_LIST = ["hospital", "school", "birthday", "wedding", "ehpad", "cemetery"]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_pressed(level):
	get_parent().level_name = LEVEL_LIST[level]
	get_parent().load_game()
	queue_free()


func _on_quit_button_pressed():
	get_tree().quit()

