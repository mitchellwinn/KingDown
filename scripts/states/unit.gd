extends State
class_name Unit

var forced = false
var north_offset_from_target
var east_offset_from_target
var mode = "attack"
var defending_pieces
var attack_target
var target

func go_north(start):
	var north_neighbor = card.get_parent().get_child(0).get_north_neighbor()
	if !north_neighbor:
		return false
	if !north_neighbor.safe>=2 and (card.piece == "king") and !forced:
		return false
	if north_neighbor.safe>=1 and (card.piece == "pawn"):
		return false
	if north_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(card.get_parent().get_child(0).get_north_neighbor().get_parent())	
	return true
	
func go_south(start):
	var south_neighbor = card.get_parent().get_child(0).get_south_neighbor()
	if !south_neighbor:
		return false
	if !south_neighbor.safe>=2 and card.piece == "king" and !forced:
		return false
	if south_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(card.get_parent().get_child(0).get_south_neighbor().get_parent())
	return true
	
func go_west(start):
	var west_neighbor = card.get_parent().get_child(0).get_west_neighbor()
	if !west_neighbor:
		return false
	if !west_neighbor.safe>=2 and card.piece == "king" and !forced:
		return false
	if west_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(card.get_parent().get_child(0).get_west_neighbor().get_parent())
	return true
	
func go_east(start):
	var east_neighbor = card.get_parent().get_child(0).get_east_neighbor()
	if !east_neighbor:
		return false
	if !east_neighbor.safe>=2 and card.piece == "king" and !forced:
		return false
	if east_neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(card.get_parent().get_child(0).get_east_neighbor().get_parent())
	return true

func get_neighbor_in_L(dir1,dir2,dir3):
	var card_tile = card.get_tile()
	var neighbor = card_tile.call("get_"+dir1+"_neighbor")
	if !neighbor:
		return
	neighbor = neighbor.call("get_"+dir2+"_neighbor")
	if !neighbor:
		return
	neighbor = neighbor.call("get_"+dir3+"_neighbor")
	if !neighbor:
		return
	return neighbor

func go_north_west(start):
	var neighbor = card.get_parent().get_child(0).get_north_west_neighbor()
	if !neighbor:
		return false
	if !neighbor.safe>=2 and card.piece == "king" and !forced:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(neighbor.get_parent())	
	return true
	
func go_north_east(start):
	var neighbor = card.get_parent().get_child(0).get_north_east_neighbor()
	if !neighbor:
		return false
	if !neighbor.safe>=2 and card.piece == "king" and !forced:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(neighbor.get_parent())	
	return true
	
func go_south_west(start):
	var neighbor = card.get_parent().get_child(0).get_south_west_neighbor()
	if !neighbor:
		return false
	if !neighbor.safe>=2 and card.piece == "king" and !forced:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(neighbor.get_parent())	
	return true
	
func go_south_east(start):
	var neighbor = card.get_parent().get_child(0).get_south_east_neighbor()
	if !neighbor:
		return false
	if !neighbor.safe>=2 and card.piece == "king" and !forced:
		return false
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		return false
	await update_position(neighbor.get_parent())	
	return true

func update_position(parent):
	print("reparenting "+card.display+" to "+str(parent))
	card.reparent(parent)
	#print(card.identifying_name+" update position to "+str(card.get_parent().get_node("Area3D").tile_id))
	card.target_position = card.get_parent().global_position+Vector3(0,0,6)
	
func status_north():
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_north_neighbor()
	if neighbor==null:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0
		
func status_south():
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_south_neighbor()
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0

func status_west():
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_west_neighbor()
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0

func status_east():
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_east_neighbor()
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0

func status_north_west():
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_north_west_neighbor()
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0
		
func status_south_east():
	if !card.get_tile():
		return -1
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_south_east_neighbor()
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0

func status_south_west():
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_south_west_neighbor()
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0

func status_north_east():
	if !card.get_tile():
		return -1
	var neighbor = card.get_tile().get_north_east_neighbor()
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0
		
func status_neighbor(neighbor):
	
	if !neighbor:
		return -1
	if neighbor.get_parent().get_child_count()>1: #card already occupies tile
		if neighbor.get_parent().get_child(1).enemy:
			return 2
		else:
			return 1
	else:
		return 0

func king_on_diagonal(value):
	var current_neighbor = card.get_parent().get_child(0).get_north_west_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == value:
		current_neighbor = current_neighbor.get_north_west_neighbor()
		
	current_neighbor = card.get_parent().get_child(0).get_south_west_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == value:
		current_neighbor = current_neighbor.get_south_west_neighbor()
		
	current_neighbor = card.get_parent().get_child(0).get_south_east_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == value:
		current_neighbor = current_neighbor.get_south_east_neighbor()
	
	current_neighbor = card.get_parent().get_child(0).get_north_east_neighbor()
	while status_neighbor(current_neighbor) == 0 or status_neighbor(current_neighbor) == value:
		current_neighbor = current_neighbor.get_north_east_neighbor()
	update_position(current_neighbor)
	
func get_first_enemy_direction(direction):
	var current_neighbor = card.get_parent().get_node("Area3D").call("get_"+direction+"_neighbor")
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.call("get_"+direction+"_neighbor")
	return current_neighbor
			
	
func get_first_enemy_north():
	var current_neighbor = card.get_parent().get_node("Area3D").get_north_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_north_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)
			
func get_first_enemy_south():
	var current_neighbor = card.get_parent().get_node("Area3D").get_south_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_south_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)

func get_first_enemy_east():
	var current_neighbor = card.get_parent().get_node("Area3D").get_east_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_east_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)
			
func get_first_enemy_west():
	var current_neighbor = card.get_parent().get_node("Area3D").get_west_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_west_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)
			
func get_first_enemy_north_west():
	var current_neighbor = card.get_parent().get_node("Area3D").get_north_west_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_north_west_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)
			
func get_first_enemy_south_east():
	var current_neighbor = card.get_parent().get_node("Area3D").get_south_east_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_south_east_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)

func get_first_enemy_north_east():
	var current_neighbor = card.get_parent().get_node("Area3D").get_north_east_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_north_east_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)
			
func get_first_enemy_south_west():
	var current_neighbor = card.get_parent().get_node("Area3D").get_south_west_neighbor()
	while status_neighbor(current_neighbor) == 0:
		current_neighbor = current_neighbor.get_south_west_neighbor()
	match status_neighbor(current_neighbor):
		-1:
			return false  #nothing occupying north at all
		1:
			return false #teammate occupying square
		2: 
			return current_neighbor.get_parent().get_child(1)

func attack(neighbor):
	#defined in child classes
	pass

func has_diagonal_attack():
	var enemy
	if moved:
		return
	enemy =  get_first_enemy_north_west()
	if enemy:
		return enemy
	enemy =  get_first_enemy_south_west()
	if enemy:
		return enemy
	enemy =  get_first_enemy_north_east()
	if enemy:
		return enemy
	enemy =  get_first_enemy_south_east()
	if enemy:
		return enemy

func has_L_attack():
	var neighbor = get_neighbor_in_L("north","north","east")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)
	neighbor = get_neighbor_in_L("north","north","west")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)		
	neighbor = get_neighbor_in_L("north","east","east")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)		
	neighbor = get_neighbor_in_L("north","west","west")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)		
	
	neighbor = get_neighbor_in_L("south","south","east")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)
	neighbor = get_neighbor_in_L("south","south","west")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)		
	neighbor = get_neighbor_in_L("south","east","east")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)		
	neighbor = get_neighbor_in_L("south","west","west")
	if status_neighbor(neighbor)==2:
		return neighbor.get_parent().get_child(1)	
	return false

func has_horizontal_attack():
	var enemy
	if moved:
		return
	enemy =  get_first_enemy_north()
	if enemy:
		return enemy
	enemy =  get_first_enemy_south()
	if enemy:
		return enemy
	enemy =  get_first_enemy_west()
	if enemy:
		return enemy
	enemy =  get_first_enemy_east()
	if enemy:
		return enemy
	return false

func abort_move():
	return false
