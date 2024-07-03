extends Unit

var check_mate_escape_iterator = 0

func enter(_msg := {}) -> void:
	Directory.game_manager.reset_moves.connect(_reset_moves)
	card = state_machine.card

func has_attack():
	attack_target = false
	attack_target = has_diagonal_attack()
	if attack_target:
		return true

func check_attack():
	var enemy
	if moved:
		return
	enemy =  get_first_enemy_north_west()
	if enemy:
		await attack(enemy)
		return true
	enemy =  get_first_enemy_south_west()
	if enemy:
		await attack(enemy)
		return true
	enemy =  get_first_enemy_north_east()
	if enemy:
		await attack(enemy)
		return true
	enemy =  get_first_enemy_south_east()
	if enemy:
		await attack(enemy)
		return true
		
func set_danger_tiles():
	defending_pieces = []
	var current_neighbor = card.get_parent().get_child(0).get_north_west_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=1
		current_neighbor = current_neighbor.get_north_west_neighbor()
		
	current_neighbor = card.get_parent().get_child(0).get_south_west_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=1
		current_neighbor = current_neighbor.get_south_west_neighbor()
		
	current_neighbor = card.get_parent().get_child(0).get_south_east_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=1
		current_neighbor = current_neighbor.get_south_east_neighbor()
	
	current_neighbor = card.get_parent().get_child(0).get_north_east_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=1
		current_neighbor = current_neighbor.get_north_east_neighbor()

func attack(enemy):
	if moved:
		return
	print("bishop attacks "+str(enemy))
	Directory.game_manager.camera_target = Vector3(enemy.global_position.x,enemy.global_position.y,4)
	Directory.play_sound("res://audio/sfx/cardhit/"+str(Directory.rng.randi_range(1,1))+".mp3",-7,.75,0.1,1)	
	await update_position(enemy.get_parent())
	enemy.hp-=card.capture_value+4
	Directory.game_manager.update_sideboard()
	if enemy.hp<=0:
		enemy.change_area("graveyard")
		Directory.game_manager.get_node("AnimationPlayer").play("cam_impact_medium")
	else:
		Directory.game_manager.get_node("AnimationPlayer").play("cam_impact_light")
	Directory.game_manager.get_node("AnimationPlayer").seek(0)
	await get_tree().create_timer(.5).timeout
	card.change_area("graveyard")

func move():
	moved = true
	if abort_move():
		return
	if card.get_tile().safe<0 and defending_pieces.size()>0:
		if defending_pieces[0].get_tile():
			if defending_pieces[0].get_tile().safe>0:
				print("bishop abort defending")
				return
	if Directory.game_manager.boss.get_tile().safe>=0:
		mode = "attack"
	else:
		mode = "defense"
	target = Directory.game_manager.boss
	for _card in Directory.game_manager.live_pieces:
		if !_card == null:
			continue
		if !_card.enemy and _card.get_tile().safe>=1 and _card != card:
			target = _card
	print("bishop of "+card.get_parent().name+" moves in "+mode+" mode targeting "+str(target.display)+".")
	east_offset_from_target = card.get_tile().tile_id%5-Directory.game_manager.boss.get_tile().tile_id%5
	north_offset_from_target = (card.get_tile().tile_id-1)/5-(Directory.game_manager.boss.get_tile().tile_id-1)/5
	
	#try east or west
	if abs(east_offset_from_target)>abs(north_offset_from_target):
		#try west
		if east_offset_from_target>0:
			if north_offset_from_target>0:
				if! await go_direction(true,"north_west"):
					if! await go_direction(true,"south_west"):
						if! await go_direction(true,"north_east"):
							if! await go_direction(true,"south_east"):
								return #failed to move
			else:
				if! await go_direction(true,"south_west"):
					if! await go_direction(true,"north_west"):
						if! await go_direction(true,"south_east"):
							if! await go_direction(true,"north_east"):
								return #failed to move
		else: #try east
			if north_offset_from_target>0:
				if! await go_direction(true,"north_east"):
					if! await go_direction(true,"south_east"):
						if! await go_direction(true,"north_west"):
							if! await go_direction(true,"south_west"):
								return #failed to move
			else:
				if! await go_direction(true,"south_east"):
					if! await go_direction(true,"north_east"):
						if! await go_direction(true,"south_west"):
							if! await go_direction(true,"north_west"):
								return #failed to move
	else: #go north or south
		#try south
		if north_offset_from_target>0:
			if east_offset_from_target>0:
				if! await go_direction(true,"south_west"):
					if! await go_direction(true,"south_east"):
						if! await go_direction(true,"north_west"):
							if! await go_direction(true,"north_east"):
								return #failed to move
			else:
				if! await go_direction(true,"south_east"):
					if! await go_direction(true,"south_west"):
						if! await go_direction(true,"north_east"):
							if! await go_direction(true,"north_west"):
								return #failed to move
		else: #try north
			if east_offset_from_target>0:
				if! await go_direction(true,"north_west"):
					if! await go_direction(true,"north_east"):
						if! await go_direction(true,"south_west"):
							if! await go_direction(true,"south_east"):
								return #failed to move
			else:
				if! await go_direction(true,"north_east"):	
					if! await go_direction(true,"north_west"):
						if! await go_direction(true,"south_east"):
							if! await go_direction(true,"south_west"):
								return #failed to move
	return true
	
func move_direction_roll(): #deprecated
	if moved:
		return
	if check_mate_escape_iterator == 0:
		forced = false
	check_mate_escape_iterator+=1
	if check_mate_escape_iterator>15:
		forced = true
		check_mate_escape_iterator = 0
	if moved:
		return
	var direction_roll = Directory.rng.randf_range(1.0,100.0)
	if forced:
		if !await go_north_west(true):
			if !await go_north_east(true):
				if !await go_south_west(true):
					if !await go_south_east(true):
						check_mate_escape_iterator = 0
						return true
						
	if direction_roll>75.0:
		if !await go_north_west(true):
			await move_direction_roll()
			return
	elif direction_roll>50:
		if !await go_north_east(true):
			await move_direction_roll()
			return
	elif direction_roll> 25:
		if !await go_south_west(true):
			await move_direction_roll()
			return
	elif direction_roll>0:
		if !await go_south_east(true):
			await move_direction_roll()
			return
	check_mate_escape_iterator = 0

func go_direction(start,direction):
	if start == false:
		print("bishop of "+card.get_parent().name+" has continued moving in the "+direction+" direction!")
	else:
		print("bishop of "+card.get_parent().name+" has begun moving in the "+direction+" direction...")
	if card.area!="field":
		return
	var neighbor = card.get_tile().call("get_"+direction+"_neighbor")
	if !neighbor:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
		moved = true
		return true
		print("bishop forced in place")
	if neighbor.safe>=0 and start:
		if !neighbor.call("get_"+direction+"_neighbor"):
			return 
		if neighbor.call("get_"+direction+"_neighbor").safe>=0:
			return 
		
	start = false
	await update_position(neighbor.get_parent())	
	if card.get_tile().safe<=-1:
		if target == Directory.game_manager.boss:
			if king_on_diagonal(2):
				Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
				return true
		else:
			var ally = get_first_enemy_direction("north_west")
			if ally:
				if !ally.enemy and ally.safe>=0:
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true
			ally = get_first_enemy_direction("north_east")
			if ally:
				if !ally.enemy and ally.safe>=0:
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true
			ally = get_first_enemy_direction("south_west")
			if ally:
				if !ally.enemy and ally.safe>=0:
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true
			ally = get_first_enemy_direction("south_east")
			if ally:
				if !ally.enemy and ally.safe>=0:
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true

				
	if call("status_"+direction)==0:
		neighbor = card.get_tile().call("get_"+direction+"_neighbor")
		if !neighbor:
			pass
		elif neighbor.safe<0:
			await call("go_direction",false,direction)
		elif neighbor.call("get_"+direction+"_neighbor"):
			if neighbor.call("get_"+direction+"_neighbor").safe<0:
				await call("go_direction",false,direction)
			elif neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor"):
				if neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").safe<0:
					await call("go_direction",false,direction)
				elif neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor"):
					if neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").safe<0:
						await call("go_direction",false,direction)
	Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
	return true

func go_north_west(start):
	if card.area!="field":
		return
	var neighbor = card.get_parent().get_node("Area3D").get_north_west_neighbor()
	if !neighbor:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		await update_position(neighbor.get_parent())
		return true
	if neighbor.safe>=0 and start:
		if !neighbor.get_north_west_neighbor():
			return
		if !neighbor.get_north_west_neighbor().get_north_west_neighbor():
			return
	await update_position(neighbor.get_parent())	
	if card.get_tile().safe<=-1 and neighbor.get_north_west_neighbor():
		match mode:
			"attack":
				if status_north_west() == 0:
					if await king_on_diagonal(1) == false and neighbor.get_north_west_neighbor().safe<=0:
						await go_north_west(false)
						return true
	if status_north_west()==0:
		if neighbor.get_north_west_neighbor():
			if neighbor.get_north_west_neighbor().safe<0:
				await go_north_west(false)
			elif neighbor.get_north_west_neighbor().get_north_west_neighbor():
				if neighbor.get_north_west_neighbor().get_north_west_neighbor().safe<0:
					await go_north_west(false)
				elif neighbor.get_north_west_neighbor().get_north_west_neighbor().get_north_west_neighbor():
					if neighbor.get_north_west_neighbor().get_north_west_neighbor().get_north_west_neighbor().safe<0:
						await go_north_west(false)
	return true
	
func go_south_west(start):
	if card.area!="field":
		return
	var neighbor = card.get_parent().get_node("Area3D").get_south_west_neighbor()
	if !neighbor:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		await update_position(neighbor.get_parent())
		return true
	if neighbor.safe>=0 and start:
		if !neighbor.get_south_west_neighbor():
			return
		if !neighbor.get_south_west_neighbor().get_south_west_neighbor():
			return
	await update_position(neighbor.get_parent())	
	if card.get_tile().safe<=-1 and neighbor.get_south_west_neighbor():
		match mode:
			"attack":
				if status_south_west() == 0:
					if await king_on_diagonal(1) == false and neighbor.get_south_west_neighbor().safe<=0 :
						await go_south_west(false)
						return true
	if status_south_west()==0:
		if neighbor.get_south_west_neighbor():
			if neighbor.get_south_west_neighbor().safe<0:
				await go_south_west(false)
			elif neighbor.get_south_west_neighbor().get_south_west_neighbor():
				if neighbor.get_south_west_neighbor().get_south_west_neighbor().safe<0:
					await go_south_east(false)
				elif neighbor.get_south_west_neighbor().get_south_west_neighbor().get_south_west_neighbor():
					if neighbor.get_south_west_neighbor().get_south_west_neighbor().get_south_west_neighbor().safe<0:
						await go_south_west(false)
	return true
	
func go_north_east(start):
	if card.area!="field":
		return
	var neighbor = card.get_tile().get_north_east_neighbor()
	if !neighbor:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		await update_position(neighbor.get_parent())
		return true
	if neighbor.safe>=1 and start:
		if !neighbor.get_north_east_neighbor():
			return
		if !neighbor.get_north_east_neighbor().get_north_east_neighbor():
			return 
	await update_position(neighbor.get_parent())	
	if card.get_tile().safe<=-1 and neighbor.get_north_east_neighbor():
		match mode:
			"attack":
				if status_north_east() == 0:
					if await king_on_diagonal(1) == true and neighbor.get_north_east_neighbor().safe<=0:
						return true
	if status_north_east()==0:
		if neighbor.get_north_east_neighbor():
			if neighbor.get_north_east_neighbor().safe<0:
				await go_north_east(false)
			elif neighbor.get_north_east_neighbor().get_north_east_neighbor():
				if neighbor.get_north_east_neighbor().get_north_east_neighbor().safe<0:
					await go_north_east(false)
				elif neighbor.get_north_east_neighbor().get_north_east_neighbor().get_north_east_neighbor():
					if neighbor.get_north_east_neighbor().get_north_east_neighbor().get_north_east_neighbor().safe<0:
						await go_north_east(false)
	return true
	
func go_south_east(start):
	if card.area!="field":
		return
	var neighbor = card.get_parent().get_node("Area3D").get_south_east_neighbor()
	if !neighbor:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		await update_position(neighbor.get_parent())
		return true
	if neighbor.safe>=0 and start:
		if !neighbor.get_south_east_neighbor():
			return
		if !neighbor.get_south_east_neighbor().get_south_east_neighbor():
			return
	await update_position(neighbor.get_parent())	
	if card.get_tile().safe<=-1 and neighbor.get_south_east_neighbor():
		match mode:
			"attack":
				if status_north_east() == 0:
					if await king_on_diagonal(1) == false and neighbor.get_south_east_neighbor().safe<=0:
						await go_south_east(false)
						return true
	if status_south_east()==0:
		if neighbor.get_south_east_neighbor():
			if neighbor.get_south_east_neighbor().safe<0:
				await go_south_east(false)
			elif neighbor.get_south_east_neighbor().get_south_east_neighbor():
				if neighbor.get_south_east_neighbor().get_south_east_neighbor().safe<0:
					await go_south_east(false)
				elif neighbor.get_south_east_neighbor().get_south_east_neighbor().get_south_east_neighbor():
					if neighbor.get_south_east_neighbor().get_south_east_neighbor().get_south_east_neighbor().safe<0:
						await go_south_east(false)
	return true
