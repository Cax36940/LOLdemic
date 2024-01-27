extends Control

enum {NO_BUTTON, CONTROL, CONTAMINATE, BANANA, BUTTON4}
var state = NO_BUTTON
const NB_BUTTONS = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Boutons :
# 1 - Contrôle
# 2 - Contamination
# 3 - Banane ?
# 4 - ?


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func release_buttons(except_index):
	for i in range(1, NB_BUTTONS+1):
		if i!=except_index:
			get_node("Button"+str(i)).button_pressed = false

func get_buttons_states():
	return [$Button1.button_pressed, $Button2.button_pressed, $Button3.button_pressed, $Button4.button_pressed]

func _on_button_pressed(button_index):
	print(button_index)
	release_buttons(button_index)
