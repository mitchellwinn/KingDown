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
	Directory.play_sound("res://audio/sfx/cardhit/"+str(Directory.rng.randi_range(1,1))+".mp3",-15,.75,0.1,1)
	update_position(enemy.get_parent())
	enemy.hp-=card.capture_value+5
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
		if card.get_tile().get_north_east_neighbor().get_parent().get_child(1).get_node("StateMachine").state.moved:
			return
	if status_north_west()==1:
		if card.get_tile().get_north_west_neighbor().get_parent().get_child(1).get_node("StateMachine").state.moved:
			return
	if await go_north(true):
		Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
	if !first_move and Directory.game_manager.boss.get_parent().get_child(0).tile_id>20:
		await go_north(true)
	first_move = true
	print("pawn move")
