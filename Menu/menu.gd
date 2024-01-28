extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_pressed(level):
	get_parent().level_name = get_node("/root/World").LEVEL_LIST[level]
	get_parent().load_game()
	get_node("../Menu_music").playing = false
	queue_free()


func _on_quit_button_pressed():
	get_tree().quit()

