extends Node2D

@export var level_name : String
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(load("res://Menu/menu.tscn").instantiate())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_game():
	$LevelLoader.add_child(load("res://Levels/level_" + level_name + ".tscn").instantiate())
