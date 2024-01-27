extends Control

enum {NO_BUTTON, CONTROL, CONTAMINATE, BANANA, BUTTON4}
var state = NO_BUTTON
const NB_BUTTONS = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(1, NB_BUTTONS+1):
		get_node("Button"+str(i)).focus_mode = FOCUS_NONE


# Boutons :
# 1 - Contrôle
# 2 - Contamination
# 3 - Banane
# 4 - ?


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _input(event):
	var button_index = 0
	if (event.is_action_released("num0")):
		if state != NO_BUTTON:
			button_index = state
	for i in range(1, NB_BUTTONS+1):
		if (event.is_action_released("num"+str(i))):
			button_index = i
			break
	if button_index:
		var b = get_node("Button"+str(button_index))
		b.button_pressed = not b.button_pressed
		button_press(button_index)

func release_buttons(except_index):
	for i in range(1, NB_BUTTONS+1):
		if i!=except_index:
			get_node("Button"+str(i)).button_pressed = false

func get_buttons_states():
	return [$Button1.button_pressed, $Button2.button_pressed, $Button3.button_pressed, $Button4.button_pressed]

func button_press(button_index):
	if get_node("Button"+str(button_index)).button_pressed == true:
		state = button_index
	else:
		state = NO_BUTTON
	release_buttons(button_index)


func _on_button_pressed(button_index):
	button_press(button_index)


func _on_button_1_toggled(toggled_on):
	if toggled_on == false:
		get_node("/root/World").uncontrol()
