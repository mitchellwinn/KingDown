extends Node
class_name State

var card: Node3D
var state_machine = null
var moved:= false

signal promote
# Called when the node enters the scene tree for the first time.

func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func _gain_gold_in_play(amount):
	if card.in_play:
		while Directory.game_manager.card_effect_resolving:
			await get_tree().physics_frame
		Directory.game_manager.camera_target = Vector3(card.global_position.x,card.global_position.y,4)
		Directory.game_manager.card_effect_resolving = true
		Directory.play_sound("res://audio/sfx/1.wav",-5,Directory.game_manager.combo_pitch,0,1)
		Directory.game_manager.combo_pitch += 0.5
		card.get_node("AnimationPlayer").play("proc1")
		Directory.game_manager.budget+=amount
		print("[ABILITY]gain_gold_in_play("+str(amount)+")")
		await get_tree().create_timer(.20).timeout
		Directory.game_manager.card_effect_resolving = false
		Directory.game_manager.reset_combo_counter()
		
func _gain_budget_on_promote(amount):
	if card.in_play:
		while Directory.game_manager.card_effect_resolving:
			await get_tree().physics_frame
		Directory.game_manager.camera_target = Vector3(card.global_position.x,card.global_position.y,4)
		Directory.game_manager.card_effect_resolving = true
		Directory.play_sound("res://audio/sfx/1.wav",-5,Directory.game_manager.combo_pitch,0,1)
		Directory.game_manager.combo_pitch += 0.5
		card.get_node("AnimationPlayer").play("proc1")
		Directory.game_manager.budget+=amount
		print("[ABILITY]gain_gold_in_play("+str(amount)+")")
		await get_tree().create_timer(.20).timeout
		Directory.game_manager.card_effect_resolving = false
		Directory.game_manager.reset_combo_counter()

func connect_signals():
	match card.archetype:
		"blue":
			Directory.game_manager.round_end.connect(_gain_gold_in_play.bind(2))
		"plenty":
			match card.piece:
				"pawn":
					promote.connect(_gain_budget_on_promote.bind(20))
	
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
