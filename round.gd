extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
func _process(delta):
	var left_pos = get_node("Sprite").get_pos()
	if (Input.is_action_pressed("ui_down")):
		left_pos.y+=5
		get_node("Label").set_text("Down")
	if (Input.is_action_pressed("ui_up")):
		left_pos.y-=5
		get_node("Label").set_text("Up")
	get_node("Sprite").set_pos(left_pos)

