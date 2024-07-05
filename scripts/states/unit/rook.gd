extends Unit

var check_mate_escape_iterator = 0

func has_attack():
	attack_target = false
	attack_target = has_horizontal_attack()
	if attack_target:
		return true

func check_attack():
	var enemy
	if moved:
		return
	enemy =  get_first_enemy_north()
	if enemy:
		if await attack(enemy):
			return true
	enemy =  get_first_enemy_south()
	if enemy:
		if await attack(enemy):
			return true
	enemy =  get_first_enemy_west()
	if enemy:
		if await attack(enemy):
			return true
	enemy =  get_first_enemy_east()
	if enemy:
		if await attack(enemy):
			return true
	return false
		
func set_danger_tiles():
	defending_pieces = []
	var safety_bonus = 2
	if moved:
		safety_bonus = 5
	var current_neighbor = card.get_parent().get_child(0).get_north_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=safety_bonus
		current_neighbor = current_neighbor.get_north_neighbor()
		
	current_neighbor = card.get_parent().get_child(0).get_south_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=safety_bonus
		current_neighbor = current_neighbor.get_south_neighbor()
		
	current_neighbor = card.get_parent().get_child(0).get_west_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=safety_bonus
		current_neighbor = current_neighbor.get_west_neighbor()
	
	current_neighbor = card.get_parent().get_child(0).get_east_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == 1 or status_neighbor(current_neighbor) == 2:
		if status_neighbor(current_neighbor) == 1:
			defending_pieces.append(current_neighbor.get_parent().get_child(1))
		current_neighbor.safe -=safety_bonus
		current_neighbor = current_neighbor.get_east_neighbor()

func attack(enemy):
	if moved:
		return
	moved = true
	Directory.game_manager.camera_target = Vector3(enemy.global_position.x,enemy.global_position.y,4)
	Directory.play_sound("res://audio/sfx/cardhit/"+str(Directory.rng.randi_range(1,1))+".mp3",-7,.75,0.1,1)
	await update_position(enemy.get_parent())
	enemy.hp-=Directory.damage_algorithm(card)
	Directory.game_manager.update_sideboard()
	Directory.game_manager.get_node("AnimationPlayer").play("cam_impact_medium")
	Directory.game_manager.get_node("AnimationPlayer").seek(0)
	if enemy.hp<=0:
		enemy.change_area("graveyard")
	await get_tree().create_timer(.5).timeout
	card.change_area("graveyard")
	return true

func move():
	moved = true
	if abort_move():
		return
	if card.get_tile().safe<0 and defending_pieces.size()>0:
		if defending_pieces[0].get_tile():
			if defending_pieces[0].get_tile().safe>=0:
				return
	if Directory.game_manager.boss.get_tile().safe>=2:
		mode = "attack"
	else:
		mode = "defense"
	target = Directory.game_manager.boss
	for _card in Directory.game_manager.live_pieces:
		if !_card.enemy and _card.get_tile().safe>=1 and _card != card:
			target = _card
	print("rook of "+card.get_parent().name+" moves in "+mode+" mode targeting "+str(target)+".")
	east_offset_from_target = card.get_tile().tile_id%5-target.get_tile().tile_id%5
	north_offset_from_target = (card.get_tile().tile_id-1)/5-(target.get_tile().tile_id-1)/5
	
	if north_offset_from_target>0:
		if abs(east_offset_from_target)>abs(north_offset_from_target)+1:
			if east_offset_from_target>0:
				if! await go_direction(true,"west"):
					if! await go_direction(true,"south"):
						if! await go_direction(true,"north"):
							if! await go_direction(true,"east"):
								return #failed to move
			else:
				if! await go_direction(true,"east"):
					if! await go_direction(true,"south"):
						if! await go_direction(true,"north"):
							if! await go_direction(true,"west"):
								return #failed to move
		else:
			if east_offset_from_target>0:
				if! await go_direction(true,"south"):
					if! await go_direction(true,"west"):
						if! await go_direction(true,"east"):
							if! await go_direction(true,"north"):
								return #failed to move
			else:
				if! await go_direction(true,"south"):
					if! await go_direction(true,"east"):
						if! await go_direction(true,"west"):
							if! await go_direction(true,"north"):
								return #failed to move
	else:
		if abs(east_offset_from_target)>abs(north_offset_from_target)+1:
			if east_offset_from_target>0:
				if! await go_direction(true,"west"):
					if! await go_direction(true,"north"):
						if! await go_direction(true,"south"):
							if! await go_direction(true,"east"):
								return #failed to move
			else:
				if! await go_direction(true,"east"):
					if! await go_direction(true,"north"):
						if! await go_direction(true,"south"):
							if! await go_direction(true,"west"):
								return #failed to move
		else:
			if east_offset_from_target>0:
				if! await go_direction(true,"north"):
					if! await go_direction(true,"west"):
						if! await go_direction(true,"east"):
							if! await go_direction(true,"south"):
								return #failed to move
			else:
				if! await go_direction(true,"north"):
					if! await go_direction(true,"east"):
						if! await go_direction(true,"west"):
							if! await go_direction(true,"south"):
								return #failed to move

#deprecated
func move_direction_roll():
	if check_mate_escape_iterator == 0:
		forced = false
	check_mate_escape_iterator+=1
	if check_mate_escape_iterator>15:
		check_mate_escape_iterator = 0
		return
	var direction_roll = await Directory.rng.randf_range(1.0,100.0)
	if direction_roll>75.0:
		if !await go_north(true):
			await move_direction_roll()
			return
	elif direction_roll>50:
		if !await go_west(true):
			await move_direction_roll()
			return
	elif direction_roll> 25:
		if !await go_south(true):
			await move_direction_roll()
			return
	elif direction_roll>0:
		if !await go_east(true):
			await move_direction_roll()
			return
	return true
	check_mate_escape_iterator = 0

func go_direction(start,direction):
	if start == false:
		print("rook of "+card.get_parent().name+" has continued moving in the "+direction+" direction!")
	else:
		print("rook of "+card.get_parent().name+" has begun moving in the "+direction+" direction...")
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
		Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
		return true
	if neighbor.safe>=-1 and start:
		if !neighbor.call("get_"+direction+"_neighbor"):
			return
		if !neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor"):
			return
		if !neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor"):
			return
	start = false
	await update_position(neighbor.get_parent())
	if card.get_tile().safe<=-1:
		match mode:
			"attack":#stop on king's tile
				if get_first_enemy_east():
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true
				if get_first_enemy_west():
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true
				if get_first_enemy_south():
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true
				if get_first_enemy_north():
					Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
					return true
			"defense":#stop a tile early
				if target != Directory.game_manager.boss:
					match direction:
						"north":
							if floor((card.get_tile().tile_id)/5.1)==floor(target.get_tile().tile_id/5.1):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
						"south":
							if floor((card.get_tile().tile_id)/5.1)==floor(target.get_tile().tile_id/5.1):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
						"east":
							if floor(card.get_tile().tile_id%5)==floor((target.get_tile().tile_id)%5):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
						"west":
							if floor(card.get_tile().tile_id%5)==floor((target.get_tile().tile_id)%5):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
				else:
					match direction:
						"north":
							if floor((card.get_tile().tile_id+5)/5.1)==floor(target.get_tile().tile_id/5.1):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
						"south":
							if floor((card.get_tile().tile_id-5)/5.1)==floor(target.get_tile().tile_id/5.1):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
						"east":
							if floor((card.get_tile().tile_id+1)%5)==floor((target.get_tile().tile_id)%5):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
						"west":
							if floor((card.get_tile().tile_id-1)%5)==floor((target.get_tile().tile_id)%5):
								Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
								return true
	if call("status_"+direction)==0:
		neighbor = card.get_tile().call("get_"+direction+"_neighbor")
		if !neighbor:
			pass
		elif neighbor.safe<-1:
			await call("go_direction",false,direction)
		elif neighbor.call("get_"+direction+"_neighbor"):
			if neighbor.call("get_"+direction+"_neighbor").safe<-1:
				await call("go_direction",false,direction)
			elif neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor"):
				if neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").safe<-1:
					await call("go_direction",false,direction)
				elif neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor"):
					if neighbor.call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").call("get_"+direction+"_neighbor").safe<0:
						await call("go_direction",false,direction)
	Directory.play_sound("res://audio/sfx/cardslide/"+str(Directory.rng.randi_range(1,8))+".mp3",-15,.75,0.1,1)
	return true

func go_north(start):
	if card.area!="field":
		return
	var north_neighbor = card.get_parent().get_node("Area3D").get_north_neighbor()
	if !north_neighbor:
		return false
	if north_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		moved = true
		return true
	if north_neighbor.safe>=0 and start:
		if !north_neighbor.get_north_neighbor():
			return
		if !north_neighbor.get_north_neighbor().get_north_neighbor():
			return
		if !north_neighbor.get_north_neighbor().get_north_neighbor().get_north_neighbor():
			return
	start = false
	update_position(card.get_parent().get_node("Area3D").get_north_neighbor().get_parent())	
	if card.get_tile().safe<=-1:
		match mode:
			"attack":#stop on king's tile
				if (Directory.game_manager.boss.get_tile().tile_id-1)/5==(card.get_tile().tile_id-1)/5 :
					return true
			"defense":#stop a tile early
				if (Directory.game_manager.boss.get_tile().tile_id-1)/5==(card.get_tile().tile_id+4)/5:
					return true
	if status_north()==0:
		north_neighbor = card.get_parent().get_node("Area3D").get_north_neighbor()
		if north_neighbor.safe<0:
			await go_north(false)
		elif north_neighbor.get_north_neighbor():
			if north_neighbor.get_north_neighbor().safe<0:
				await go_north(false)
			elif north_neighbor.get_north_neighbor().get_north_neighbor():
				if north_neighbor.get_north_neighbor().get_north_neighbor().safe<0:
					await go_north(false)
				elif north_neighbor.get_north_neighbor().get_north_neighbor().get_north_neighbor():
					if north_neighbor.get_north_neighbor().get_north_neighbor().get_north_neighbor().safe<0:
						await go_north(false)
	return true
	
func go_south(start):
	if card.area!="field":
		return false
	var south_neighbor = card.get_parent().get_node("Area3D").get_south_neighbor()
	if !south_neighbor:
		return false
	if south_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		moved = true
		return true
	if south_neighbor.safe>=0 and start:
		if !south_neighbor.get_south_neighbor():
			return
		if !south_neighbor.get_south_neighbor().get_south_neighbor():
			return
		if !south_neighbor.get_south_neighbor().get_south_neighbor().get_south_neighbor():
			return
	start = false
	await update_position(south_neighbor.get_parent())
	if card.get_tile().safe<=-1:
		match mode:
			"attack":#stop on king's tile
				if (Directory.game_manager.boss.get_tile().tile_id-1)/5==(card.get_tile().tile_id-1)/5:
					return true
			"defense":#stop a tile early
				if (Directory.game_manager.boss.get_tile().tile_id-1)/5==(card.get_tile().tile_id-6)/5:
					return true
	if status_south()==0:
		south_neighbor = card.get_parent().get_node("Area3D").get_south_neighbor()
		if south_neighbor.get_south_neighbor():
			if south_neighbor.get_south_neighbor().safe<0:
				await go_south(false)
			elif south_neighbor.get_south_neighbor().get_south_neighbor():
				if south_neighbor.get_south_neighbor().get_south_neighbor().safe<0:
					await go_south(false)
				elif south_neighbor.get_south_neighbor().get_south_neighbor().get_south_neighbor():
					if south_neighbor.get_south_neighbor().get_south_neighbor().get_south_neighbor().safe<0:
						await go_south(false)
	return true
	
func go_west(start):
	if card.area!="field":
		return
	var west_neighbor = card.get_parent().get_node("Area3D").get_west_neighbor()
	if !west_neighbor:
		return false
	if west_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		moved = true
		return true
	if west_neighbor.safe>=0 and start:
		if !west_neighbor.get_west_neighbor():
			return
		if !west_neighbor.get_west_neighbor().get_west_neighbor():
			return
		if !west_neighbor.get_west_neighbor().get_west_neighbor().get_west_neighbor():
			return
	start = false
	await update_position(card.get_parent().get_node("Area3D").get_west_neighbor().get_parent())
	if card.get_tile().safe<=-1:
		match mode:
			"attack":#stop on king's tile
				if (Directory.game_manager.boss.get_tile().tile_id)%5==(card.get_tile().tile_id)%5:
					return true
			"defense":#stop a tile early
				if (Directory.game_manager.boss.get_tile().tile_id)%5==(card.get_tile().tile_id+1)%5:
					return true
	if status_west()==0:
		west_neighbor = card.get_parent().get_node("Area3D").get_west_neighbor()
		if west_neighbor:
			if west_neighbor.get_west_neighbor():
				if west_neighbor.get_west_neighbor().safe<0:
					await go_west(false)
				elif west_neighbor.get_west_neighbor().get_west_neighbor():
					if west_neighbor.get_west_neighbor().get_west_neighbor().safe<0:
						await go_west(false)
					elif west_neighbor.get_west_neighbor().get_west_neighbor().get_west_neighbor():
						if west_neighbor.get_west_neighbor().get_west_neighbor().get_west_neighbor().safe<0:
							await go_west(false)
	return true
	
func go_east(start):
	if card.area!="field":
		return
	var east_neighbor = card.get_parent().get_node("Area3D").get_east_neighbor()
	if !east_neighbor:
		return false
	if east_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	if forced:
		moved = true
		return true
	if east_neighbor.safe>=0 and start:
		if !east_neighbor.get_east_neighbor():
			return
		if !east_neighbor.get_east_neighbor().get_east_neighbor():
			return
		if !east_neighbor.get_east_neighbor().get_east_neighbor().get_east_neighbor():
			return
	start = false
	await update_position(card.get_parent().get_node("Area3D").get_east_neighbor().get_parent())
	if card.get_tile().safe<=-1:
		match mode:
			"attack":#stop on king's tile
				if (Directory.game_manager.boss.get_tile().tile_id)%5==(card.get_tile().tile_id)%5:
					return true
			"defense":#stop a tile early
				if (Directory.game_manager.boss.get_tile().tile_id)%5==(card.get_tile().tile_id-1)%5:
					return true
	if status_east()==0:
		east_neighbor = card.get_parent().get_node("Area3D").get_east_neighbor()
		if east_neighbor.get_east_neighbor():
			if east_neighbor.get_east_neighbor().safe<0:
				await go_east(false)
			elif east_neighbor.get_east_neighbor().get_east_neighbor():
				if east_neighbor.get_east_neighbor().get_east_neighbor().safe<0:
					await go_east(false)
				elif east_neighbor.get_east_neighbor().get_east_neighbor().get_east_neighbor():
					if east_neighbor.get_east_neighbor().get_east_neighbor().get_east_neighbor().safe<0:
						await go_east(false)
	return true

	
