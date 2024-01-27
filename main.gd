extends Node2D

@export var level_name : String
var GOAL = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(load("res://Menu/menu.tscn").instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_game():
	
	$LevelLoader.add_child(load("res://Levels/level_" + level_name + ".tscn").instantiate())
	var interface = load("res://interface/interface.tscn").instantiate()
	GOAL = $LevelLoader.get_node("Level_Base").get_meta("GOAL")
	print(GOAL)
	interface.get_node("Jauge").GOAL = GOAL
	add_child(interface)
