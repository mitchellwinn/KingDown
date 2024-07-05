extends Unit

var check_mate_escape_iterator = 0
var attack_search_iterator = 0

func check_attack():
	if attack_search_iterator == 0:
		print("checking for possible attack from king")
	if attack_search_iterator > 12:
		print("attack search overload")
		attack_search_iterator = 0
		if status_north_west() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_north_west_neighbor().get_parent().get_child(1)
		if status_north_east() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_north_east_neighbor().get_parent().get_child(1)
		if status_south_west() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_south_west_neighbor().get_parent().get_child(1)
		if status_south_east() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_south_east_neighbor().get_parent().get_child(1)
		if status_north() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_north_neighbor().get_parent().get_child(1)
		if status_east() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_east_neighbor().get_parent().get_child(1)
		if status_south() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_south_neighbor().get_parent().get_child(1)
		if status_west() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_west_neighbor().get_parent().get_child(1)		
		return
	attack_search_iterator +=1
	if moved:
		return
	var direction_roll = Directory.rng.randf_range(1.0,100.0)
	if direction_roll>87.5:
		if status_north_west() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_north_west_neighbor().get_parent().get_child(1)
	elif direction_roll>75:
		if status_north_east() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_north_east_neighbor().get_parent().get_child(1)
	elif direction_roll>62.5:
		if status_south_west() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_south_west_neighbor().get_parent().get_child(1)
	elif direction_roll>50:
		if status_south_east() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_south_east_neighbor().get_parent().get_child(1)
	elif direction_roll>37.5:
		if status_north() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_north_neighbor().get_parent().get_child(1)
	elif direction_roll>25:
		if status_east() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_east_neighbor().get_parent().get_child(1)
	elif direction_roll>12.5:
		if status_south() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_south_neighbor().get_parent().get_child(1)
	elif direction_roll>0:
		if status_west() == 1:
			attack_search_iterator = 0
			return card.get_parent().get_child(0).get_west_neighbor().get_parent().get_child(1)
	return check_attack()

func has_attack():
	attack_target = false
	attack_target = check_attack()
	if attack_target:
		print("attack target: "+attack_target.piece)
		return true
	else:
		print("no attack target")

func attack(enemy):
	if moved:
		return
	Directory.game_manager.camera_target = Vector3(enemy.global_position.x,enemy.global_position.y,4)
	if Directory.rng.randi_range(0,-10)>((enemy.get_tile().safe-2)):
		move()
		print("abort attack")
		return
	attack_target = enemy
	var target_position = enemy.get_parent()
	Directory.game_manager.damage_step_enemy.emit()
	await get_tree().create_timer(.1).timeout
	while Directory.game_manager.card_effect_resolving:
		await get_tree().process_frame
	update_position(target_position)
	if enemy.invulnerability>0:
		enemy.invulnerability-=1
	else:
		Directory.play_sound("res://audio/sfx/cardhit/"+str(Directory.rng.randi_range(1,1))+".mp3",-7,.75,0.1,1)
		Directory.game_manager.get_node("AnimationPlayer").play("cam_impact_light")
		Directory.game_manager.get_node("AnimationPlayer").seek(0)
		enemy.change_area("graveyard")
	await get_tree().create_timer(.35).timeout
	Directory.game_manager.arrange_minimap()
	moved = true

func move():
	if check_mate_escape_iterator == 0:
		forced = false
	check_mate_escape_iterator+=1
	if check_mate_escape_iterator>20:
		forced = true
	if check_mate_escape_iterator>30:
		return
		check_mate_escape_iterator = 0
	if moved:
		return
	var direction_roll = Directory.rng.randf_range(1.0,100.0)
	if direction_roll>87.5:
		if !await go_north(true):
			move()
			return
		print("king north")
		check_mate_escape_iterator = 0
	elif direction_roll>75.0:
		if !await go_north_west(true):
			move()
			return
		print("king northW")
		check_mate_escape_iterator = 0
	elif direction_roll>62.5:
		if !await go_west(true):
			move()
			return
		print("king west")
		check_mate_escape_iterator = 0
	elif direction_roll>50:
		if !await go_south_west(true):
			move()
			return
		print("king southW")
		check_mate_escape_iterator = 0
	elif direction_roll>37.5:
		if !await go_south(true):
			move()
			return
		print("king south")
		check_mate_escape_iterator = 0
	elif direction_roll>25:
		if !await go_south_east(true):
			move()
			return
		print("king southE")
		check_mate_escape_iterator = 0
	elif direction_roll>12.5:
		if !await go_east(true):
			move()
			return
		print("king east")
		check_mate_escape_iterator = 0
	elif direction_roll>0:
		if !await go_north_east(true):
			move()
			return
		print("king northE")
		check_mate_escape_iterator = 0
	Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)

func set_danger_tiles():
	card.get_tile().safe+=2
	var current_neighbor = card.get_tile().get_north_west_neighbor()
	if current_neighbor:
		print(current_neighbor.get_parent())
		current_neighbor.safe +=2
		
	current_neighbor = card.get_tile().get_south_west_neighbor()
	if current_neighbor:
		current_neighbor.safe +=2
		
	current_neighbor = card.get_tile().get_south_east_neighbor()
	if current_neighbor:
		current_neighbor.safe +=2
	
	current_neighbor = card.get_tile().get_north_east_neighbor()
	if current_neighbor:
		current_neighbor.safe +=2
	
	current_neighbor = card.get_tile().get_west_neighbor()
	if current_neighbor:
		current_neighbor.safe +=2
		
	current_neighbor = card.get_tile().get_south_neighbor()
	if current_neighbor:
		current_neighbor.safe +=2
		
	current_neighbor = card.get_tile().get_east_neighbor()
	if current_neighbor:
		current_neighbor.safe +=2
	
	current_neighbor = card.get_tile().get_north_neighbor()
	if current_neighbor:
		current_neighbor.safe +=2
