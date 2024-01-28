extends Node2D


var rate = 0. # 0. - 2. Rate of goal (to win : 1.0 +/- nice)
var nice = 0.1 # -> goal +/- 10%
var GOAL = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func move_pointer():
	$Pointer.position.y = 144 * (1 - rate)

func is_in_interval():
	return abs(rate-1.) <= nice

func get_laughing():
	var people = get_node("../../LevelLoader/Level_Base/People").get_children()
	var l = 0
	for p in people:
		if p.is_laughing():
			l += 1
	return l

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_node("../../LevelLoader/Level_Base/People")==null:return
	$Label.text = str(GOAL)
	rate = float(get_laughing()) / GOAL
	move_pointer()
