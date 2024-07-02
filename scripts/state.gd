extends Node
class_name State

var card: Node3D
var state_machine = null
var moved:= false
# Called when the node enters the scene tree for the first time.

func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func gain_gold_in_play(amount):
	if card.in_play:
		Directory.game_manager.budget+=amount
		print("[ABILITY]gain_gold_in_play("+str(amount)+")")

func connect_signals():
	pass
	
func enter(_msg := {}) -> void:
	state_machine = get_parent()
	Directory.game_manager.reset_moves.connect(_reset_moves)
	card = state_machine.card
	connect_signals()

func exit() -> void:
	pass

func _reset_moves():
	moved = false	

func update_position(parent):
	card.reparent(parent)
	card.target_position = card.get_parent().global_position
