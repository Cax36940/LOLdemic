extends Node2D

@export var level_name : String
enum {NO_BUTTON, CONTROL, CONTAMINATE, BANANA, BUTTON4}
var GOAL = 0
var interface = null
var controlled_player = null
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(load("res://Menu/menu.tscn").instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_input_control(player):
	# Initiate control
	if controlled_player != null or interface.state != CONTROL:
		return false
	controlled_player = player
	return true

func uncontrol():
	# Unpress control button
	if controlled_player != null:
		controlled_player.uncontrol()
		controlled_player = null

func is_input_contaminate():
	# Initiate contamination
	return interface.state == CONTAMINATE


func load_game():
	$LevelLoader.add_child(load("res://Levels/level_" + level_name + ".tscn").instantiate())
	interface = load("res://interface/interface.tscn").instantiate()
	GOAL = $LevelLoader.get_node("Level_Base").get_meta("GOAL")
	interface.get_node("Jauge").GOAL = GOAL
	add_child(interface)
