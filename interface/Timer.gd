extends Node2D

const TOTAL_TIME = 5.
const DECREASE_RATE = TOTAL_TIME / 2 # decrease 2x faster


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str(int(TOTAL_TIME))+"s"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $"../Jauge".is_in_interval():
		$TimerBar.value += delta / TOTAL_TIME
	else:
		$TimerBar.value -= delta / DECREASE_RATE
