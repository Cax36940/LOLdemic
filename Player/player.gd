@tool
extends CharacterBody2D
@export var MAX_SPEED : int = 50
@export var laughing : float = 0.
@export_enum("Normal", "Child", "Senior", "Ghost") var PERSON_TYPE: int = 0

var speed = 1.
var dx = 0
var dy = 0
var controlled = false
var distance = randf() * PI #pour l'animation, potentiellement à optimiser
var timer = randf() * PI #pour l'animation, potentiellement à optimiser
var fallen = false
var ghost_cooldown = 0.

var CHANGE_MOVE_PROB = 0.01
var LAUGH_TIME = 10. # temps de parcours linéaire de la jauge 2
var SPREAD_RADIUS = 150 # rayon au delà duquel la contagion est impossible
var SPREAD_RATE_COEF = 0.1 # 1/nb de tours pour remplir la jauge 1 avec une contagion max (laughing = 2)
var SPRITE_POSITION_Y = -16 # pour l'animation mais vraiment meh


#///////////////////////////////////////////////////////////

#region

var is_ready : bool = Engine.is_editor_hint()

@export_category("Perso")
@export var init_people_randomly : bool = true
@export var skin_color : Color = Color("f7b08e"):
	set(new_color):
		skin_color = new_color
		if is_ready:
			code["skin_color_r"] = skin_color.r
			code["skin_color_g"] = skin_color.g
			code["skin_color_b"] = skin_color.b
			code = code
			$Sprite/Skin.modulate = skin_color
			
@export_group("Face")
@export var eyer_frame : int = 0 :
	set(new_reye):
		eyer_frame = clamp(new_reye, 0, 19)
		if is_ready:
			code["eyer_frame"] = eyer_frame
			code = code
			$Sprite/Face/EyeR.frame = eyer_frame

@export var eyel_frame : int = 0 :
	set(new_leye):
		eyel_frame = clamp(new_leye, 0, 19)
		if is_ready:
			code["eyel_frame"] = eyel_frame
			code = code
			$Sprite/Face/EyeL.frame = eyel_frame
		
		
@export var eyelash_color : int = 0 :
	set(new_color):
		eyelash_color = clamp(new_color, 0, 4)
		if is_ready:
			code["eyelash_color"] = eyelash_color
			code = code
			$Sprite/Face/EyelashL.frame = eyelash_color
			$Sprite/Face/EyelashR.frame = eyelash_color

@export var mouth_frame : int = 0 :
	set(new_mouth):
		mouth_frame = clamp(new_mouth, 0, 2)
		if is_ready:
			code["mouth_frame"] = mouth_frame
			code = code
			$Sprite/Face/Mouth.frame = mouth_frame

@export_group("Clothes")
@export var neck_frame : int = 0 :
	set(new_neck):
		neck_frame = clamp(new_neck, 0, 9)
		if is_ready:
			code["neck_frame"] = neck_frame
			code = code
			$Sprite/Clothes/Neck.frame = neck_frame
			$Sprite/Clothes/Neck.visible = (shirt_frame == 0 or neck_frame < 2)

@export var neck_color : Color = Color("aaaaaa"):
	set(new_color):
		neck_color = new_color
		if is_ready:
			code["neck_color_r"] = neck_color.r
			code["neck_color_g"] = neck_color.g
			code["neck_color_b"] = neck_color.b
			code = code
			$Sprite/Clothes/Neck.modulate = new_color

@export var hair_frame : int = 0 :
	set(new_frame):
		hair_frame = clamp(new_frame, 0, 3)
		if is_ready:
			code["hair_frame"] = hair_frame
			code = code
			$Sprite/Hair.frame = hair_frame
			update_line()

@export var hair_color : Color = Color("482d00"):
	set(new_color):
		hair_color = new_color
		if is_ready:
			code["hair_color_r"] = hair_color.r
			code["hair_color_g"] = hair_color.g
			code["hair_color_b"] = hair_color.b
			code = code
			$Sprite/Hair.modulate = new_color

		
@export var shirt_frame : int = 0 :
	set(new_frame):
		shirt_frame = clamp(new_frame, 0, 1)
		if is_ready:
			code["shirt_frame"] = shirt_frame
			code = code
			$Sprite/Clothes/Shirt.frame = shirt_frame
			$Sprite/Clothes/Pants.visible = (shirt_frame == 0)
			$Sprite/Clothes/Shoes.visible = (shirt_frame == 0)
			$Sprite/Clothes/Neck.visible = (shirt_frame == 0 or neck_frame < 2)
			update_line()

@export var shirt_color : Color = Color("a0b8ef"):
	set(new_color):
		shirt_color = new_color
		if is_ready:
			code["shirt_color_r"] = shirt_color.r
			code["shirt_color_g"] = shirt_color.g
			code["shirt_color_b"] = shirt_color.b
			code = code
			$Sprite/Clothes/Shirt.modulate = new_color

@export var pants_frame : int = 0 :
	set(new_frame):
		pants_frame = clamp(new_frame, 0, 1)
		if is_ready:
			code["pants_frame"] = pants_frame
			code = code
			$Sprite/Clothes/Pants.frame = pants_frame
			update_line()

@export var pants_color : Color = Color("101d43"):
	set(new_color):
		pants_color = new_color
		if is_ready:
			code["pants_color_r"] = pants_color.r
			code["pants_color_g"] = pants_color.g
			code["pants_color_b"] = pants_color.b
			code = code
			$Sprite/Clothes/Pants.modulate = new_color

@export_category("Generator")

@export var rand_skin_color : bool = false :
	set(new_state):
		rand_skin_color = new_state
		if new_state:
			skin_color = SKIN_TONES[randi_range(0,19)]
			rand_skin_color = false
			
@export var rand_eye : bool = false :
	set(new_state):
		rand_eye = new_state
		if new_state:
			random_eye()
			rand_eye = false
			
@export var rand_hair_color : bool = false :
	set(new_state):
		rand_hair_color = new_state
		if new_state:
			if $Sprite/Hair.frame == 3 :
				hair_color = Color(1.,1.,1.)
			else :
				hair_color = Color.from_hsv(randf_range(0,1),randf_range(0,1),randf_range(0.2,0.8))
	
			rand_hair_color = false

@export var rand_clothes : bool = false :
	set(new_state):
		rand_clothes = new_state
		if new_state:
			shirt_frame = int(randf_range(0,10)/8)
			shirt_color = Color.from_hsv(randf_range(0,1),randf_range(0,1),randf_range(0,1))
			pants_frame = randi_range(0, 1)
			pants_color = Color.from_hsv(randf_range(0,1),randf_range(0,1),randf_range(0,1))
			neck_frame = randi_range(0,9)
			neck_color = Color.from_hsv(0, 0, randf_range(0.2,0.8))
			rand_clothes = false

@export var rand_people : bool = false :
	set(new_state):
		rand_people = new_state
		if new_state:
			rand_clothes = true
			rand_eye = true
			hair_frame = randi_range(0,3)
			rand_hair_color = true
			rand_skin_color = true
			rand_people = false


@export_category("Export Player")
@export var export_code : String = ""
@export var import_code : String = "" :
	set(new_code):
		var json = JSON.new()
		var error = json.parse(new_code)
		if error == OK:
			var data_received = json.data
			for v in data_received:
				if "skin_color_r" in data_received :
					skin_color.r = data_received["skin_color_r"]
				if "skin_color_g" in data_received :
					skin_color.g = data_received["skin_color_g"]
				if "skin_color_b" in data_received :
					skin_color.b = data_received["skin_color_b"]
					
				if "eyer_frame" in data_received :	
					eyer_frame = data_received["eyer_frame"]
					
				if "eyel_frame" in data_received :	
					eyel_frame = data_received["eyel_frame"]
					
				if "eyelash_color" in data_received :
					eyelash_color = data_received["eyelash_color"]
					
				if "mouth_frame" in data_received :
					mouth_frame = data_received["mouth_frame"]
					
				if "neck_frame" in data_received :
					neck_frame = data_received["neck_frame"]
				if "neck_color_r" in data_received :
					neck_color.r = data_received["neck_color_r"]
				if "neck_color_g" in data_received :
					neck_color.g = data_received["neck_color_g"]
				if "neck_color_b" in data_received :
					neck_color.b = data_received["neck_color_b"]
					
				if "hair_frame" in data_received :
					hair_frame = data_received["hair_frame"]
				if "hair_color_r" in data_received :
					hair_color.r = data_received["hair_color_r"]
				if "hair_color_g" in data_received :
					hair_color.g = data_received["hair_color_g"]
				if "hair_color_b" in data_received :
					hair_color.b = data_received["hair_color_b"]
					
				if "shirt_frame" in data_received :
					shirt_frame = data_received["shirt_frame"]
				if "shirt_color_r" in data_received :
					shirt_color.r = data_received["shirt_color_r"]
				if "shirt_color_g" in data_received :
					shirt_color.g = data_received["shirt_color_g"]
				if "shirt_color_b" in data_received :
					shirt_color.b = data_received["shirt_color_b"]
					
				if "pants_frame" in data_received :
					pants_frame = data_received["pants_frame"]
				if "pants_color_r" in data_received :
					pants_color.r = data_received["pants_color_r"]
				if "pants_color_g" in data_received :
					pants_color.g = data_received["pants_color_g"]
				if "pants_color_b" in data_received :
					pants_color.b = data_received["pants_color_b"]
		else :
			print("JSON Parse Error: ", json.get_error_message(), " in ", code, " at line ", json.get_error_line())

var code : Dictionary = {} :
	set(new_code):
		code = new_code
		export_code = JSON.stringify(code)

const SKIN_TONES = [
	Color(1.0, 0.87, 0.73),    # Light skin tone
	Color(0.96, 0.78, 0.56),   # Medium-light skin tone
	Color(0.84, 0.61, 0.42),   # Medium skin tone
	Color(0.72, 0.48, 0.33),   # Medium-dark skin tone
	Color(0.59, 0.29, 0.0),    # Brown skin tone
	Color(0.47, 0.24, 0.0),    # Dark brown skin tone
	Color(0.95, 0.76, 0.56),    # Pale skin tone
	Color(0.90, 0.72, 0.56),   # Peach skin tone
	Color(0.80, 0.56, 0.45),   # Light peach skin tone
	Color(0.70, 0.44, 0.34),   # Light brown skin tone
	Color(0.60, 0.35, 0.24),   # Medium-brown skin tone
	Color(0.50, 0.25, 0.0),    # Dark tan skin tone
	Color(0.40, 0.20, 0.0),    # Deep tan skin tone
	Color(1.0, 0.80, 0.60),    # Tan skin tone
	Color(0.90, 0.72, 0.53),   # Warm tan skin tone
	Color(0.80, 0.60, 0.40),   # Olive skin tone
	Color(0.70, 0.40, 0.20),   # Golden brown skin tone
	Color(0.60, 0.30, 0.0),    # Rich brown skin tone
	Color(0.50, 0.25, 0.25),   # Rosy brown skin tone
	Color(0.40, 0.20, 0.20)    # Deep rosy brown skin tone
]

var eyelash_r_pos : Vector2 = Vector2(3.5,-2.5)
var eyelash_l_pos : Vector2 = Vector2(-3.5,-2.5)


const EYE_LIST = [[1, 2, 3, 4], [5, 7], [6], [8], [9, 10, 11, 12], [13, 14], [0, 16, 17], [18, 19]]
const EYELASH_L = [[0,1,2,3,4,5,6,7,8,9,10,11,12,14,18,19],[13],[15, 17],[16]]
const EYELASH_L_POS = [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,1)]
const EYELASH_R = [[0,1,2,3,4,5,6,7,8,9,10,11,12,13,18,19],[14],[15, 16],[17]]
const EYELASH_R_POS = [Vector2(0,0),Vector2(-1,0),Vector2(0,1),Vector2(-1,1)]

func random_eye():
	eyel_frame = randi_range(0, 19)
		
	if eyel_frame == 15:
		eyer_frame = randi_range(0, 19)
	else:
		for l in EYE_LIST:
			if eyel_frame in l:
				eyer_frame = l[randi() % l.size()]
				
	
	eyelash_color = int(exp(randf_range(0,1.79))-1)
	
	

	if eyelash_color != 0:
		for i in range(4) :
			if eyel_frame in EYELASH_L[i]:
				$Sprite/Face/EyelashL.position = eyelash_l_pos + EYELASH_L_POS[i]
			if eyer_frame in EYELASH_R[i]:
				$Sprite/Face/EyelashR.position = eyelash_r_pos + EYELASH_R_POS[i]

	

func update_line():
	$Sprite/Black.frame = 3 * shirt_frame + (hair_frame % 3)
	$Sprite/White.frame = 3 * shirt_frame + (hair_frame % 3)


#endregion


#////////////////////////////////////////////////////////////

# Called when the node enters the scene tree for the first time.
func _ready():
	is_ready = true
	import_code = export_code
	rand_people = init_people_randomly and not Engine.is_editor_hint()
	if PERSON_TYPE == 1:
		MAX_SPEED = 80
		SPREAD_RATE_COEF = 0.2
		CHANGE_MOVE_PROB = 0.02
		scale = Vector2(1.8, 1.8)
	elif PERSON_TYPE == 2:
		MAX_SPEED = 30
		CHANGE_MOVE_PROB = 0.006
	elif PERSON_TYPE == 3:
		ghost_init()
	rand_move()

func ghost_init():
	MAX_SPEED = 25
	CHANGE_MOVE_PROB = 0.002
	modulate = Color("#adadad8f")
	import_code = '{"eyel_frame":4,"eyelash_color":0,"eyer_frame":4,"hair_color_b":0.678431391716003,"hair_color_g":0.678431391716003,"hair_color_r":0.678431391716003,"hair_frame":2,"mouth_frame":0,"neck_color_b":0.678431391716003,"neck_color_g":0.678431391716003,"neck_color_r":0.678431391716003,"neck_frame":2,"pants_color_b":0.678431391716003,"pants_color_g":0.678431391716003,"pants_color_r":0.678431391716003,"pants_frame":1,"shirt_color_b":0.678431391716003,"shirt_color_g":0.678431391716003,"shirt_color_r":0.678431391716003,"shirt_frame":0,"skin_color_b":0.678431391716003,"skin_color_g":0.678431391716003,"skin_color_r":0.678431391716003}'
	rand_eye = true
	hair_frame = randi_range(0, 2)
	shirt_frame = randi_range(0, 1)

func uncontrol():
	$Sprite/White.visible = false
	controlled = false

func fall():
	fallen = true
	rotation = PI / 2
	laughing = 0.
	timer = 0. # techniquement inutile right now si il se relève jamais
	$CPUParticles2D.visible = false
	laugh(3., false)

func dist(p):
	return sqrt((p.position.x-position.x)**2 + (p.position.y-position.y)**2)

func dist2(p):
	# Pas de sqrt, optimisation tu connais
	return (p.position.x-position.x)**2 + (p.position.y-position.y)**2

func player_is_visible(p):
	var raycast = load("res://Player/raycast.tscn").instantiate()
	add_child(raycast)
	raycast.add_exception(self)
	raycast.position = Vector2(0, -10)
	raycast.target_position = p.position - position
	raycast.force_raycast_update()
	var collide = raycast.get_collider() == p
	raycast.queue_free()
	return collide

func r0_coef(d2):
	return exp(-2*d2/(SPREAD_RADIUS**2))


func rand_move():
	dx = randf()*2 - 1
	dy = randf()*2 - 1

func is_laughing():
	return laughing >= 1.

func triggered(rate):
	if PERSON_TYPE != 3 and not controlled and not fallen:
		if rate > 0 and not is_laughing() and ghost_cooldown <= 0.1:
			laughing = move_toward(laughing, 2., rate)
		elif rate < 0:
			ghost_cooldown = 1.
			laughing = move_toward(laughing, 0., -rate)

func get_neighbors(check_visible=true):
	var neigh = []
	for p in get_node("..").get_children():
		if p != self and dist2(p) <= SPREAD_RADIUS**2:
			if not check_visible or player_is_visible(p):
				neigh.append(p)
	return neigh

func laugh(rate, check_visible=true):
	for p in get_neighbors(check_visible):
		var d2 = dist2(p)
		p.triggered(rate * r0_coef(d2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	ghost_cooldown = move_toward(ghost_cooldown, 0., delta)
	# Affichage en avant des players les plus en bas
	z_index = int(position.y) 
	if not Engine.is_editor_hint():
		if not fallen:
			$CPUParticles2D.visible = is_laughing()
			if not is_laughing():
				# Blanc -> magenta
				#modulate = Color(1., min(1.-laughing, 1.), 1.)
				$Sprite.rotation = 0.1 * sin(distance * 2 )

			else:
				# Jaune -> noir
				#modulate = Color(max(2.-laughing, 0.), max(2.-laughing, 0.), 0.)
				timer += delta
				$Sprite.position.y = SPRITE_POSITION_Y + 4 * sin(timer * minf(laughing, 1.3) * 5)
			
				laugh((laughing-1) * SPREAD_RATE_COEF)
				laughing = move_toward(laughing, 2., delta / LAUGH_TIME)
				speed = 2-laughing # 1.0 - 0.0 (laugh++ -> speed--)
			
			if PERSON_TYPE == 3: # Ghost
				laugh(-0.2 * SPREAD_RATE_COEF)


		# ------------------------------ MOVEMENT ----------------------------------
			if controlled:
				var input_direction = Input.get_vector("left", "right", "up", "down")
				move_and_collide(input_direction * speed * MAX_SPEED * delta)
			elif not laughing >= 2:
				if randf() < CHANGE_MOVE_PROB:
					rand_move()
				distance += sqrt(dx**2 + dy**2) * delta
				move_and_collide(Vector2(dx * speed * MAX_SPEED * delta, dy * speed * MAX_SPEED * delta))


func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if (event is InputEventMouseButton and event.pressed and not fallen):
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
			$Sprite/White.visible = true
			distance = 0
