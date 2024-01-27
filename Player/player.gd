extends Node2D
@export var MAX_SPEED = 50

var speed = 1. * MAX_SPEED
var dx = 0
var dy = 0
var CHANGE_MOVE_PROB = 0.01
var DELTA_LAUGH = 0.003
var laughing = 0.


# Called when the node enters the scene tree for the first time.
func _ready():
	rand_move()

func rand_move():
	dx = randf()*2 - 1
	dy = randf()*2 - 1

func is_laughing():
	return laughing >= 1.0

func triggered(x):
	if not is_laughing():
		laughing += x # move_towards ?

func get_neighbors():
	return [] # TODO

func laugh():
	for p in get_neighbors():
		p.triggered()
			
		laughing = move_toward(laughing, 2., DELTA_LAUGH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if is_laughing():
		laugh()
	
	# TODO : adapter speed en fonction de laughing
	
	if randf() < CHANGE_MOVE_PROB:
		rand_move()
	position.x += dx * speed * delta
	position.y += dy * speed * delta
