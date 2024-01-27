extends CharacterBody2D
@export var MAX_SPEED : int = 50
@export var laughing : float = 0.

var speed = 1.
var dx = 0
var dy = 0
var controlled = false
var distance = randf() * PI #pour l'animation, potentiellement à optimiser
var timer = randf() * PI #pour l'animation, potentiellement à optimiser
var fallen = false

var CHANGE_MOVE_PROB = 0.01
var LAUGH_TIME = 10. # temps de parcours linéaire de la jauge 2
var SPREAD_RADIUS = 150 # rayon au delà duquel la contagion est impossible
var SPREAD_RATE_COEF = 0.04 # 1/nb de tours pour remplir la jauge 1 avec une contagion max (laughing = 2)
var SPRITE_POSITION_Y = -16 # pour l'animation mais vraiment meh



# Called when the node enters the scene tree for the first time.
func _ready():
	rand_move()

func uncontrol():
	controlled = false

func fall():
	fallen = true
	rotation = PI / 2
	laughing = 0.
	timer = 0. # techniquement inutile right now si il se relève jamais
	laugh(1.)

func dist(p):
	return sqrt((p.position.x-position.x)**2 + (p.position.y-position.y)**2)

func dist2(p):
	# Pas de sqrt, optimisation tu connais
	return (p.position.x-position.x)**2 + (p.position.y-position.y)**2


func rand_move():
	dx = randf()*2 - 1
	dy = randf()*2 - 1

func is_laughing():
	return laughing >= 1.

func triggered(rate):
	if not is_laughing() and not controlled and not fallen:
		laughing = move_toward(laughing, 2., rate)

func get_neighbors():
	var neigh = []
	for p in get_node("..").get_children():
		if p != self and dist2(p) <= SPREAD_RADIUS**2:
			neigh.append(p)
	return neigh

func laugh(rate):
	for p in get_neighbors():
		p.triggered(rate)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if not fallen:
		if not is_laughing():
			# Blanc -> magenta
			$Sprite2D.rotation = 0.1 * sin(distance * 2 )
			# modulate = Color(1., min(1.-laughing, 1.), 1.)
		else:
			# Jaune -> noir
			# modulate = Color(max(2.-laughing, 0.), max(2.-laughing, 0.), 0.)
			timer += delta
			$Sprite2D.position.y = SPRITE_POSITION_Y + 4 * sin(timer * laughing * 10)
			
			laugh((laughing-1) * SPREAD_RATE_COEF)
			laughing = move_toward(laughing, 2., delta / LAUGH_TIME)
			speed = 2-laughing # 1.0 - 0.0 (laugh++ -> speed--)


	# ------------------------------ MOVEMENT ----------------------------------
		if controlled:
			var input_direction = Input.get_vector("left", "right", "up", "down")
			move_and_collide(input_direction * speed * MAX_SPEED * delta)
		elif not laughing >= 2:
			if randf() < CHANGE_MOVE_PROB:
				rand_move()
			distance += sqrt(dx**2 + dy**2) * delta
			move_and_collide(Vector2(dx * speed * MAX_SPEED * delta, dy * speed * MAX_SPEED * delta))


func _on_area_2d_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton and event.pressed):
		var main = get_node("/root/World")
		if main.is_input_contaminate():
			if laughing < 1.:
				laughing = 1.
			else:
				laughing = 0.
				timer = 0.
		if main.is_input_control(self):
			speed = 1.
			laughing = 0.
			timer = 0
			controlled = true
