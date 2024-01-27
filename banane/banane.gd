extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# call le "fall" du joueur qui rentre dans l'area2D et faire proc 1. de laughing sur tout les gens alentours
func _on_area_2d_body_entered(body):
	body.fall()
	queue_free()
