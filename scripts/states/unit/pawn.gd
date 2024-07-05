extends Unit

var first_move = false

func has_attack():
	attack_target = false
	var tile
	if status_north_west() == 2:
		tile = card.get_parent().get_child(0).get_north_west_neighbor()
	elif status_north_east() == 2:
		tile = card.get_parent().get_child(0).get_north_east_neighbor()
	else:
		attack_target = null
		return false
	if tile.get_parent().get_child(1).piece == "king":
		attack_target = tile.get_parent().get_child(1)
	if attack_target:
		return true
		
func check_attack():
	print(str(status_north_west())+","+str(status_north_east()))
	if status_north_west() == 2:
		attack(card.get_parent().get_child(0).get_north_west_neighbor())
		return true
	elif status_north_east() == 2:
		await attack(card.get_parent().get_child(0).get_north_east_neighbor())
		return true

func attack(enemy):
	Directory.game_manager.camera_target = Vector3(enemy.global_position.x,enemy.global_position.y,4)
	Directory.play_sound("res://audio/sfx/cardhit/"+str(Directory.rng.randi_range(1,1))+".mp3",-15,.75,0.1,1)
	update_position(enemy.get_parent())
	enemy.hp-=Directory.damage_algorithm(card)
	Directory.game_manager.update_sideboard()
	Directory.game_manager.get_node("AnimationPlayer").play("cam_impact_light")
	Directory.game_manager.get_node("AnimationPlayer").seek(0)
	if enemy.hp<=0:
		enemy.change_area("graveyard")
	await get_tree().create_timer(.5).timeout
	card.change_area("graveyard")

func set_danger_tiles():
	defending_pieces = []
	if status_north_east() != -1:
		card.get_parent().get_child(0).get_north_east_neighbor().safe -=1
		if status_north_east() == 2:
			defending_pieces.append(card.get_tile().get_north_east_neighbor().get_parent().get_child(1))
	if status_north_west() != -1:
		card.get_parent().get_child(0).get_north_west_neighbor().safe -=1
		if status_north_west() == 2:
			defending_pieces.append(card.get_tile().get_north_west_neighbor().get_parent().get_child(1))

func move():
	moved = true
	if abort_move():
		return
	if status_north_east()==1:
		var protecting = card.get_tile().get_north_east_neighbor().get_parent().get_child(1).get_node("StateMachine").state
		if protecting.moved and protecting.card.get_tile().safe>=0:
			return
	if status_north_west()==1:
		var protecting = card.get_tile().get_north_west_neighbor().get_parent().get_child(1).get_node("StateMachine").state
		if protecting.moved and protecting.card.get_tile().safe>=0:
			return
	if await go_north(true):
		Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
	if !first_move and Directory.game_manager.boss.get_parent().get_child(0).tile_id>20:
		await go_north(true)
	first_move = true
	print("pawn move")
	if card.get_tile().tile_id>20:
		promotion()

func promotion():
	promote.emit()
	Directory.game_manager.pawn_promoted.emit()
	await get_tree().create_timer(.5).timeout
	while Directory.game_manager.card_effect_resolving:
		await await get_tree().create_timer(.25).timeout
	Directory.play_sound("res://audio/sfx/create.wav",-15,1,0.1,1)
	for promoted_card in Directory.game_manager.deck.get_children():
		if promoted_card.piece == "queen":
			match card.archetype:
				"plenty":
					await get_tree().create_timer(1).timeout
			print("found queen to promote")
			Directory.game_manager.active_tile = card.get_tile()
			card.change_area("graveyard")
			promoted_card.change_area("field")
			promoted_card.get_node("StateMachine").state.moved = true
			Directory.game_manager.camera_target = Vector3(Directory.game_manager.active_tile.global_position.x,Directory.game_manager.active_tile.global_position.y,4)
			Directory.game_manager.arrange_board()
			return
	card.change_area("graveyard")
	print("no queen in deck")
