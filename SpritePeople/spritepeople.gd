@tool
extends Node2D

@export_category("Perso")
@export var skin_color : Color = Color("f7b08e"):
	set(new_color):
		skin_color = new_color
		$Sprite/Skin.modulate = new_color

		
@export_group("Face")
@export var eyer_frame : int = 0 :
	set(new_reye):
		eyer_frame = clamp(new_reye, 0, 19)
		$Sprite/Face/EyeR.frame = eyer_frame

@export var eyel_frame : int = 0 :
	set(new_leye):
		eyel_frame = clamp(new_leye, 0, 19)
		$Sprite/Face/EyeL.frame = eyel_frame
		
		
@export var eyelash_color : int = 0 :
	set(new_color):
		eyelash_color = clamp(new_color, 0, 4)
		$Sprite/Face/EyelashL.frame = eyelash_color
		$Sprite/Face/EyelashR.frame = eyelash_color

@export var mouth_frame : int = 0 :
	set(new_mouth):
		mouth_frame = clamp(new_mouth, 0, 2)
		$Sprite/Face/Mouth.frame = mouth_frame

@export_group("Clothes")
@export var neck_frame : int = 0 :
	set(new_neck):
		neck_frame = clamp(new_neck, 0, 9)
		$Sprite/Clothes/Neck.frame = neck_frame
		$Sprite/Clothes/Neck.visible = (shirt_frame == 0 or neck_frame < 2)

@export var neck_color : Color = Color("aaaaaa"):
	set(new_color):
		neck_color = new_color
		$Sprite/Clothes/Neck.modulate = new_color

@export var hair_frame : int = 0 :
	set(new_frame):
		hair_frame = clamp(new_frame, 0, 3)
		$Sprite/Hair.frame = hair_frame
		update_line()

@export var hair_color : Color = Color("482d00"):
	set(new_color):
		hair_color = new_color
		$Sprite/Hair.modulate = new_color

		
@export var shirt_frame : int = 0 :
	set(new_frame):
		shirt_frame = clamp(new_frame, 0, 1)
		$Sprite/Clothes/Shirt.frame = shirt_frame
		$Sprite/Clothes/Pants.visible = (shirt_frame == 0)
		$Sprite/Clothes/Shoes.visible = (shirt_frame == 0)
		$Sprite/Clothes/Neck.visible = (shirt_frame == 0 or neck_frame < 2)
		update_line()

@export var shirt_color : Color = Color("a0b8ef"):
	set(new_color):
		shirt_color = new_color
		$Sprite/Clothes/Shirt.modulate = new_color

@export var pants_frame : int = 0 :
	set(new_frame):
		pants_frame = clamp(new_frame, 0, 1)
		$Sprite/Clothes/Pants.frame = pants_frame
		update_line()

@export var pants_color : Color = Color("101d43"):
	set(new_color):
		pants_color = new_color
		$Sprite/Clothes/Pants.modulate = new_color

@export_category("Generator")

@export var rand_skin_color : bool = false :
	# Update speed and reset the rotation.
	set(new_state):
		rand_skin_color = new_state
		if new_state:
			skin_color = SKIN_TONES[randi_range(0,19)]
			print(skin_color)
			rand_skin_color = false
			
@export var rand_eye : bool = false :
	# Update speed and reset the rotation.
	set(new_state):
		rand_eye = new_state
		if new_state:
			random_eye()
			rand_eye = false
			
@export var rand_hair_color : bool = false :
	# Update speed and reset the rotation.
	set(new_state):
		rand_hair_color = new_state
		if new_state:
			if $Sprite/Hair.frame == 3 :
				hair_color = Color(1.,1.,1.)
			else :
				hair_color = Color.from_hsv(randf_range(0,1),randf_range(0,1),randf_range(0.2,0.8))
	
			rand_hair_color = false

@export var rand_clothes : bool = false :
	# Update speed and reset the rotation.
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
	# Update speed and reset the rotation.
	set(new_state):
		rand_people = new_state
		if new_state:
			rand_clothes = true
			rand_eye = true
			hair_frame = randi_range(0,3)
			rand_hair_color = true
			rand_skin_color = true
			rand_people = false

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

func _ready():
	rand_people = true

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

