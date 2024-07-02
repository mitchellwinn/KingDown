extends Node

signal reset_moves
signal round_end

var dealing = false
var phase := "hand"
@export var hand: Node3D
var hand_target_position: Vector3
@export var deck: Node3D
@export var baubles: Node3D
@export var board: Node3D
@export var graveyard: Node3D
@export var commence: Node3D
var hovering_card
var hovering_button
var active_tile
var board_card_count_player:= 0
var camera_target
var boss
var round: int
var budget: int
var quota: int
var turn: int
var gold := 5
var live_pieces: Array
var turn_card
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Directory.game_manager = self
	await get_tree().physics_frame
	var i = 1
	for tile in board.get_children():
		tile.get_child(0).tile_id = i
		i+=1
	camera_target = $Camera3D.global_position
	round = 1
	await get_tree().create_timer(.25).timeout
	start_round()
	
func start_round():
	turn = 1
	$AnimationPlayer.play("UI_in")
	clear_shop()
	create_boss()
	if round == 1:
		create_deck()
	arrange_minimap()
	budget = round*5+20+10*(round/3)
	update_sideboard()
	change_phase("hand")

func update_sideboard():
	quota = clamp(0,boss.hp,9999)
	$Camera3D/Sideboard/Budget.text = str(budget)
	$Camera3D/Sideboard/Budget/a.text = str(budget)
	$Camera3D/Sideboard/Budget/a/a.text = str(budget)
	$Camera3D/Sideboard/Budget/b.text = str(budget)
	#######################
	$Camera3D/Sideboard/Quota.text = str(quota)
	$Camera3D/Sideboard/Quota/a.text = str(quota)
	$Camera3D/Sideboard/Quota/a/a.text = str(quota)
	$Camera3D/Sideboard/Quota/b.text = str(quota)
	#######################
	$Camera3D/Sideboard/Turn.text = str(turn)
	$Camera3D/Sideboard/Turn/a.text = str(turn)
	$Camera3D/Sideboard/Turn/a/a.text = str(turn)
	$Camera3D/Sideboard/Turn/b.text = str(turn)
	#######################

func _process(delta):
	arrange_hand()
	if phase == "win":
		arrange_shop()
	$Camera3D.global_position = $Camera3D.global_position.lerp(camera_target,delta*4)
	hand.global_position = hand.global_position.lerp(hand_target_position,delta*4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("fullscreen"):
		match DisplayServer.window_get_mode():
			DisplayServer.WINDOW_MODE_FULLSCREEN:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func arrange_camera():
	match phase:
		"hand":
			camera_target = Vector3(0,-2,4)
		"commencement":
			camera_target = (Vector3(0,0.0,4)+Vector3(turn_card.target_position.x,turn_card.global_position.y,4))/2
			if attacking:
				camera_target = (Vector3(turn_card.target_position.x,turn_card.global_position.y,4)+ Vector3(boss.target_position.x,turn_card.global_position.y,4))/2
		"win":
			camera_target = Vector3(0,-2,4)

func create_boss():
	boss = spawn_card("king_canute","field",true)

func create_deck():
	var i = 0
	while i<52:
		var num = Directory.rng.randi_range(1,100)
		if num>66:
			spawn_card("blue_pawn","deck",false)
		elif num>33:
			spawn_card("blue_rook","deck",false)
		elif num>0:
			spawn_card("blue_bishop","deck",false)
		i+=1
	i=0
	await get_tree().create_timer(.35).timeout
	var reverse_deck = deck.get_children()
	reverse_deck.reverse()
	for card in reverse_deck:
		card.change_area("hand")
		i+=1
		if i>6:
			break
		await get_tree().create_timer(.05).timeout

func spawn_card(card,area,enemy):
	var _card = load("res://scenes/card.tscn").instantiate()
	_card.identifying_name = card
	_card.enemy = enemy
	if area!="shop":
		_card.change_area(area)
		_card.initialize()
	return _card

func change_phase(new_phase):
	phase = new_phase
	match new_phase:
		"commencement":
			await reset_safe_tiles()
			await set_safe_tiles()
			await commencement(true)
		"hand":
			arrange_camera()
			dealing = true
			await get_tree().create_timer(.35).timeout
			while hand.get_child_count()<7:
				deck.get_child(deck.get_child_count()-1).change_area("hand")
				await get_tree().create_timer(.35).timeout
			dealing = false
			commence.pressed = false
			commence._on_toggle()
		"win":
			round_end.emit()
			arrange_camera()
			gold+=round*1.3+budget
			$AnimationPlayer.play("UI_out")
			populate_shop()
			round += 1
			for card in live_pieces:
				live_pieces.erase(card)
				if card.enemy:
					card.queue_free()
				else:
					card.change_area("deck")
			for card in hand.get_children():
				card.change_area("deck")
				await get_tree().create_timer(.075).timeout
			for card in graveyard.get_children():
				if card.enemy:
					card.queue_free()
				else:
					card.change_area("deck")
				await get_tree().create_timer(.075).timeout

func clear_shop():
	if $ShopConstants/NextRound.visible:
		$ShopConstants/AnimationPlayer.play("UI_out")
	for child in $Shop.get_children():
		if child.name == "GoldPile":
			continue
		for child2 in child.get_children():
			child2.queue_free()
	
func update_gold():
	var i = 0
	for gold in $Shop/GoldPile.get_children():
		gold.queue_free()
	while i< gold:
		var coin = load("res://scenes/gold.tscn").instantiate()
		$Shop/GoldPile.add_child(coin)
		coin.global_position = $Shop/GoldPile.global_position+Vector3(Directory.rng.randf_range(-0.05,0.05),0.05*i,.1*i)
		i+=1
	$GoldLabel.text =  "x"+str(gold).pad_zeros(6)
	$GoldLabel/a.text =  "x"+str(gold).pad_zeros(6)
	$GoldLabel/a/a.text =  "x"+str(gold).pad_zeros(6)
	$GoldLabel/b.text =  "x"+str(gold).pad_zeros(6)

func populate_shop():
	clear_shop()
	$ShopConstants/AnimationPlayer.play("UI_in")
	update_gold()
	for child in $Shop.get_children():
		if child.name == "GoldPile":
			continue
		var randomnum = Directory.rng.randi_range(1,Directory.common_shop_table.keys( ).size())
		var card = await spawn_card(Directory.common_shop_table[str(randomnum)],"shop",false)
		card.identifying_name = Directory.common_shop_table[str(randomnum)]
		print(card.identifying_name + " added to shop")
		child.add_child(card)
		card.initialize()
		card.get_node("StateMachine").state.update_position.call_deferred(child)
		card.change_area("shop")

func commencement(enemy: bool):
	await get_tree().create_timer(.35).timeout
	reset_moves.emit()
	arrange_minimap()
	live_pieces.sort_custom(sort_live_pieces)
	for card in live_pieces:
		card.in_play = true
		if card.enemy != enemy:
			card.get_node("StateMachine").state.attack_target = false
			continue
		turn_card = card
		arrange_camera()
		await get_tree().create_timer(.25).timeout
		#var can_attack = await card.get_node("StateMachine").state.check_attack()
		if card.get_node("StateMachine").state.attack_target:
			attacking = true
			arrange_camera()
			card.get_node("StateMachine").state.attack(card.get_node("StateMachine").state.attack_target)
		elif card.get_node("StateMachine").state.has_attack():
			attacking = true
			arrange_camera()
			card.get_node("StateMachine").state.attack(card.get_node("StateMachine").state.attack_target)
			await get_tree().create_timer(.35).timeout
		if !card.get_node("StateMachine").state.attack_target:
			attacking = false
			if !card.get_node("StateMachine").state.moved:
				await card.get_node("StateMachine").state.move()
				arrange_camera()
				if !card.enemy:
					await reset_safe_tiles()
					await set_safe_tiles()
		if boss.hp<=0:
			await get_tree().create_timer(.5).timeout
			change_phase("win")
			return
	arrange_minimap()
	if enemy:
		await reset_safe_tiles()
		await set_safe_tiles()
		await commencement(false)
		return
	await get_tree().create_timer(.15).timeout
	turn+=1
	update_sideboard()
	if Input.is_action_pressed("select"):
		pass
	else:
		for card in hand.get_children():
			if card.capture_value<=budget:
				change_phase("hand")
				return
	await commencement(true)
	
func arrange_minimap():
	var i =0
	while i<25:
		if board.get_child(i).get_child_count()>1:
			$Camera3D/Minimap.get_child(i).visible = true
			$Camera3D/Minimap.get_child(i).texture = load("res://sprites/miniatures/"+board.get_child(i).get_child(1).identifying_name+".png")
		else:
			$Camera3D/Minimap.get_child(i).visible = false
		i+=1

func sort_live_pieces(a,b):
	if a.get_node("StateMachine").state.has_attack() and !b.get_node("StateMachine").state.has_attack():
		return true
	return false
	

func reset_safe_tiles():
	for tile in board.get_children():
		await get_tree().process_frame
		tile.get_child(0).safe = 0

func set_safe_tiles():
	for tile in board.get_children():
		await get_tree().process_frame
		if tile.get_child(1):
			await tile.get_child(1).get_node("StateMachine").state.set_danger_tiles()
	debug_safety_tiles(false)
	await get_tree().create_timer(.1).timeout

func debug_safety_tiles(onOff):
	for tile in board.get_children():
		tile.get_node("Area3D/Safe").visible = onOff
		tile.get_node("Area3D/Safe").text = str(tile.get_node("Area3D").safe)
	
func set_safe_tiles_enemy():
	for tile in board.get_children():
		if tile.get_child(1):
			if tile.get_child(1).enemy:
				await tile.get_child(1).get_node("StateMachine").state.set_danger_tiles()
	await get_tree().create_timer(.1).timeout
	
func arrange_board():
	for card in live_pieces:
		card.target_position = card.get_tile().global_position+Vector3(0,0,6)
	board_card_count_player = live_pieces.size()

func arrange_deck():
	var i = 0
	#reversed_deck.reverse()
	for card in deck.get_children():
		card.target_position = deck.global_position+Vector3(0,.001*i,.1*i-20)
		i+=1

func arrange_baubles():
	var i = 0
	#reversed_deck.reverse()
	for card in baubles.get_children():
		card.target_position = baubles.global_position+Vector3(0,1*i,.1*i-20)
		i+=1
		
func arrange_graveyard():
	var i = 0
	for card in graveyard.get_children():
		card.target_position = graveyard.global_position+Vector3(0,.001*i,.1*i-20)
		i+=1

func arrange_hand():
	var i = 0
	hand_target_position = Vector3(-.8/2.0*(float(hand.get_child_count()-1)-float(clamp(hand.get_child_count()-1,0,8))/1/5.75),-3.25,3)
	for card in hand.get_children():
		if card.selected:
			card.target_position = hand_target_position+Vector3(.8*i-float(clamp(hand.get_child_count()-1,0,8))/1/14.0,.15,-.01*i)
		elif hovering_card == null:
			card.target_position = hand_target_position+Vector3(.8*i-float(clamp(hand.get_child_count()-1,0,8))/1/14.0,0,-.01*i)
		elif hovering_card == card:
			card.target_position = hand_target_position+Vector3(.8*i-float(clamp(hand.get_child_count()-1,0,8))/1/14.0,.1,-.01*i)
		elif hovering_card != card:
			card.target_position = hand_target_position+Vector3(.8*i-float(clamp(hand.get_child_count()-1,0,8))/1/14.0,0,-.01*i)
		i+=1
		
func arrange_shop():
	hand_target_position = Vector3(-.8/2.0*(float(hand.get_child_count()-1)-float(clamp(hand.get_child_count()-1,0,8))/1/5.75),-3.25,3)
	for child in $Shop.get_children():
		if child.name == "GoldPile":
			continue
		var i = 0
		for card in child.get_children():
			if card.selected:
				card.target_position = child.global_position+Vector3(0,.15,-.01*i)
			elif hovering_card == null:
				card.target_position = child.global_position+Vector3(0,0,-.01*i)
			elif hovering_card == card:
				card.target_position = child.global_position+Vector3(0,.1,-.01*i)
			elif hovering_card != card:
				card.target_position = child.global_position+Vector3(0,0,-.01*i)
			i+=1
