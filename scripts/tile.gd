extends Area3D

var tile_id: int
var safe := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_south_neighbor():
	var neighbor
	if tile_id - 5 > 0 :
		neighbor =  Directory.game_manager.board.get_child(tile_id-6)
	else:
		return 
	#print(neighbor)
	return neighbor.get_child(0) #return the object with the script
	
func get_north_neighbor():
	var neighbor
	if tile_id + 5 <= 25 :
		neighbor =  Directory.game_manager.board.get_child(tile_id+4)
		return neighbor.get_child(0) #return the object with the script
	else:
		return
	#print(neighbor)
	
func get_east_neighbor():
	var neighbor
	if (tile_id+1)%5!=1 and tile_id+1<=25:
		neighbor =  Directory.game_manager.board.get_child(tile_id)
	else:
		return
	#print(neighbor)
	return neighbor.get_child(0) #return the object with the script
	
func get_west_neighbor():
	var neighbor
	if (tile_id - 1)%5!=0 and tile_id-1>1:
		neighbor =  Directory.game_manager.board.get_child(tile_id-2)
	else:
		return
	#print(neighbor)
	return neighbor.get_child(0) #return the object with the script
	
func get_south_west_neighbor():
	var neighbor
	if (tile_id - 6)%5!=0 and tile_id-6>1:
		neighbor =  Directory.game_manager.board.get_child(tile_id-7)
	else:
		return
	#print(neighbor)
	return neighbor.get_child(0) #return the object with the script
	
func get_north_west_neighbor():
	var neighbor
	if (tile_id + 4)%5!=0 and tile_id+4<=25:
		neighbor =  Directory.game_manager.board.get_child(tile_id+3)
	else:
		return
	#print(neighbor)
	return neighbor.get_child(0) #return the object with the script
	
func get_south_east_neighbor():
	var neighbor
	if (tile_id - 4)%5!=1 and tile_id-4>1:
		neighbor =  Directory.game_manager.board.get_child(tile_id-5)
	else:
		return
	#print(neighbor)
	return neighbor.get_child(0) #return the object with the script
	
func get_north_east_neighbor():
	var neighbor
	if (tile_id + 6)%5!=1 and tile_id+6<=25:
		neighbor =  Directory.game_manager.board.get_child(tile_id+5)
	else:
		return
	#print(neighbor)
	return neighbor.get_child(0) #return the object with the script

func _on_mouse_entered():
	Directory.game_manager.active_tile = self
	#print(Directory.game_manager.active_tile.get_parent())


func _on_mouse_exited():
	if Directory.game_manager.active_tile == self:
		Directory.game_manager.active_tile = null
