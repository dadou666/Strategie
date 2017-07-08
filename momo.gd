extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var popo = load("popo.gd")
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_ddd_pressed():
	var p= popo.new()
	get_node("Label").set_text(p.msg)
	
	pass # replace with function body
