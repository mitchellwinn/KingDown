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
			await get_tree().process_frame
		Directory.game_manager.camera_target = Vector3(card.global_position.x,card.global_position.y,4)
		Directory.game_manager.card_effect_resolving = true
		Directory.play_sound("res://audio/sfx/1.wav",0,Directory.game_manager.combo_pitch,0,1)
		Directory.game_manager.combo_pitch += 0.5
		card.get_node("ProcText").text = "GOLD + "+str(amount)
		card.get_node("AnimationPlayer").stop()
		card.get_node("AnimationPlayer").play("proc1")
		card.get_node("AnimationPlayer").seek(0)
		Directory.game_manager.budget+=amount
		print("[ABILITY]gain_gold_in_play("+str(amount)+")")
		await get_tree().create_timer(.10).timeout
		Directory.game_manager.card_effect_resolving = false
		
func _gain_budget_on_promote(amount):
	if card.in_play:
		while Directory.game_manager.card_effect_resolving:
			await get_tree().process_frame
		Directory.game_manager.camera_target = Vector3(card.global_position.x,card.global_position.y,4)
		Directory.game_manager.card_effect_resolving = true
		Directory.play_sound("res://audio/sfx/1.wav",0,Directory.game_manager.combo_pitch,0,1)
		Directory.game_manager.combo_pitch += 0.5
		card.get_node("ProcText").text = "BUDGET + "+str(amount)
		card.get_node("AnimationPlayer").stop()
		card.get_node("AnimationPlayer").play("proc1")
		card.get_node("AnimationPlayer").seek(0)
		Directory.game_manager.budget+=amount
		Directory.game_manager.update_sideboard()
		print("[ABILITY]gain_budget_on_promote("+str(amount)+")")
		await get_tree().create_timer(.40).timeout
		Directory.game_manager.arrange_camera()
		Directory.game_manager.card_effect_resolving = false
#############mult based#######################
func _add_to_mult(amount):
	if amount>0:
		while Directory.game_manager.card_effect_resolving:
			await get_tree().process_frame
		Directory.game_manager.camera_target = Vector3(card.global_position.x,card.global_position.y,4)
		Directory.game_manager.card_effect_resolving = true
		Directory.play_sound("res://audio/sfx/1.wav",0,Directory.game_manager.combo_pitch,0,1)
		Directory.game_manager.combo_pitch += 0.5
		card.get_node("ProcText").text = "MULT + "+str(amount)
		card.get_node("AnimationPlayer").stop()
		card.get_node("AnimationPlayer").play("proc1")
		card.get_node("AnimationPlayer").seek(0)
		Directory.game_manager.mult+=amount
		print("[ABILITY]add_to_mult("+str(amount)+")")
		await get_tree().create_timer(.40).timeout
		Directory.game_manager.card_effect_resolving = false
func _chromatic():
	if !card.in_play and card.area!="baubles":
		return
	var amount = 5
	_add_to_mult(amount)	
func _stim_pill():
	var amount = clamp(0,5,(11-Directory.game_manager.turn)/2)
	_add_to_mult(amount)
func _teamwork():
	var amount = Directory.game_manager.consecutive_attacks*3
	_add_to_mult(amount)
##############################################
func _evade_attack(victim):
	if !victim:
		return
	if Directory.rng.randi_range(1,100)<Directory.game_manager.piece_levels[victim.piece]*20:
		return
	var neighbor = victim.get_tile().get_north_neighbor()
	if !neighbor:
		neighbor = victim.get_tile().get_north_west_neighbor()
	if !neighbor:
		neighbor = victim.get_tile().get_east_neighbor()
	if !neighbor:
		neighbor = victim.get_tile().get_south_west_neighbor()
	if !neighbor:
		neighbor = victim.get_tile().get_south_east_neighbor()
	if !neighbor:
		neighbor = victim.get_tile().get_south_neighbor()
	if !neighbor:
		return
	if true:
		while Directory.game_manager.card_effect_resolving:
			await get_tree().process_frame
		Directory.game_manager.camera_target = Vector3(card.global_position.x,card.global_position.y,4)
		Directory.game_manager.card_effect_resolving = true
		Directory.play_sound("res://audio/sfx/1.wav",0,Directory.game_manager.combo_pitch,0,1)
		Directory.game_manager.combo_pitch += 0.5
		card.get_node("ProcText").text = "MAGICAL EVASION!"
		card.get_node("AnimationPlayer").stop()
		card.get_node("AnimationPlayer").play("proc1")
		card.get_node("AnimationPlayer").seek(0)
		victim.invulnerability+=1
		victim.get_node("StateMachine").state.update_position(neighbor.get_parent())
		print("[ABILITY]_evade_attack")
		await get_tree().create_timer(.40).timeout
		Directory.game_manager.card_effect_resolving = false
		
func _level_up_piece(piece):
	if true:
		while Directory.game_manager.card_effect_resolving:
			await get_tree().process_frame
		Directory.game_manager.camera_target = Vector3(card.global_position.x,card.global_position.y,4)
		Directory.game_manager.card_effect_resolving = true
		Directory.play_sound("res://audio/sfx/1.wav",0,Directory.game_manager.combo_pitch,0,1)
		Directory.game_manager.combo_pitch += 0.5
		card.get_node("ProcText").text = piece+" LEVEL UP!"
		card.get_node("AnimationPlayer").stop()
		card.get_node("AnimationPlayer").play("proc1")
		card.get_node("AnimationPlayer").seek(0)
		Directory.game_manager.piece_levels[piece] = Directory.game_manager.piece_levels[piece]+1
		print("[ABILITY]level_up_piece("+piece+")")
		await get_tree().create_timer(.40).timeout
		Directory.game_manager.card_effect_resolving = false

func connect_signals():
	#rarity proc effects
	match card.rarity:
		1:
			Directory.game_manager.damage_step.connect(_chromatic)
			
	#piece proc effects
	match card.archetype:
		"blue":
			Directory.game_manager.round_end.connect(_gain_gold_in_play.bind(2))
		"plenty":
			match card.piece:
				"pawn":
					promote.connect(_gain_budget_on_promote.bind(20))
	#bauble proc effects
	match card.identifying_name:
		"teamwork":
			Directory.game_manager.damage_step.connect(_teamwork)
		"stim_pill":
			Directory.game_manager.damage_step.connect(_stim_pill)
		"excalibur":
			Directory.game_manager.pawn_promoted.connect(_level_up_piece.bind("knight"))
		"cursed_cloth":
			Directory.game_manager.damage_step_enemy.connect(_evade_attack.bind(Directory.game_manager.boss.get_node("StateMachine").state.attack_target))
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
