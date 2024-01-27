extends Node2D

@export var level_name : String
enum {NO_BUTTON, CONTROL, CONTAMINATE, BANANA, BUTTON4}
var GOAL = 0
var interface = null
var controlled_player = null
var level = null
var pause = false
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(load("res://Menu/menu.tscn").instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_released("escape"):
		pause_unpause()
	if event is InputEventMouseButton and event.pressed:
		print(event.position)
		place_banana(event.position)

func place_banana(pos):
	print(interface==null)
	if interface != null and interface.state == BANANA:
		level.add_child(load("res://banane/banane.tscn").instantiate())
		interface.button_press(BANANA)

func pause_unpause():
	pause = not pause
	$LevelLoader.get_tree().paused = pause
	interface.get_tree().paused = pause
	if pause:
		add_child(load("res://Menu/escape.tscn").instantiate())
	else:
		get_node("Escape").queue_free()

func restart():
	pause_unpause()
	interface.queue_free()
	level.queue_free()
	level.tree_exited.connect(load_game)

func quit_level():
	pause_unpause()
	interface.queue_free()
	level.queue_free()
	add_child(load("res://Menu/menu.tscn").instantiate())

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
	level = load("res://Levels/level_" + level_name + ".tscn").instantiate()
	$LevelLoader.add_child(level)
	level.name = "Level_Base"
	interface = load("res://interface/interface.tscn").instantiate()
	GOAL = $LevelLoader.get_node("Level_Base").get_meta("GOAL")
	interface.get_node("Jauge").GOAL = GOAL
	add_child(interface)
