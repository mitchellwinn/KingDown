extends Node
class_name StateMachine

signal transitioned(state_name)

@export var card: Node3D
var state


# Called when the node enters the scene tree for the first time.
func initialize():
	for child in get_children():
		child.state_machine = self
	state = get_node(card.piece)
	state.enter()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	state.handle_input(event)
	
func _process(delta: float) -> void:
	state.update(delta)
	
func _physics_process(delta: float) -> void:
	state.physics_update(delta)
	
func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	if not has_node(target_state_name):
		return
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	emit_signal("transitioned", state.name)
