extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.world = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _exit_tree() -> void:
	Global.world = null

func instance_node(node, location, parent):
	var nodeInstance = node.instance_node()
	parent.add_child(nodeInstance)
	nodeInstance = location
