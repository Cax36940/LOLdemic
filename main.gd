extends Node2D

@export var level_name : String
enum {NO_BUTTON, CONTROL, CONTAMINATE, BANANA, BUTTON4}
var GOAL = 0
var interface = null
var controlled_player = null
var level = null
var pause = false
var score = 1000.
const SCORE_PER_SEC = -10.
var num_control = 0
var num_contaminate = 0
var num_banana = 0
var score_has_started = false # true when the player makes his first action

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(load("res://Menu/menu.tscn").instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if score_has_started:
		score += delta * SCORE_PER_SEC

func _input(event):
	if event.is_action_released("escape"):
		pause_unpause()
	if event is InputEventMouseButton and event.pressed:
		place_banana(event.position)


func update_score_control():
	# score loss when the player controls a person
	score -= 40
	num_control += 1
	score_has_started = true

func update_score_contaminate():
	# score loss when the player contaminates a person
	# No loss for first contamination
	if num_contaminate != 0:
		score -= 40
	num_contaminate += 1
	score_has_started = true

func update_score_banana():
	# score loss when the player places a banana
	score -= 50
	num_banana += 1
	score_has_started = true

func place_banana(pos):
	if interface != null and interface.state == BANANA:
		var banana = load("res://banane/banane.tscn").instantiate()
		level.add_child(banana)
		banana.position = pos
		interface.button_press(BANANA)
		update_score_banana()

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
	update_score_control()
	return true

func uncontrol():
	# Unpress control button
	if controlled_player != null:
		controlled_player.uncontrol()
		controlled_player = null

func is_input_contaminate():
	# Initiate contamination
	if interface.state == CONTAMINATE:
		update_score_contaminate()
		return true
	else:
		return false


func load_game():
	level = load("res://Levels/level_" + level_name + ".tscn").instantiate()
	$LevelLoader.add_child(level)
	level.name = "Level_Base"
	level.get_node("Background").scale = Vector2(1.11, 1.11)
	interface = load("res://interface/interface.tscn").instantiate()
	GOAL = $LevelLoader.get_node("Level_Base").get_meta("GOAL")
	interface.get_node("Jauge").GOAL = GOAL
	add_child(interface)
