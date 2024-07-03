extends MeshInstance3D
class_name Card

var game_manager
var enemy
var identifying_name: String
var area: String
var piece: String
var archetype: String
var display: String
var description: String
var capture_value: int
var target_position
var selected:= false
var in_play:= false
var cost: int
var uid: int

var hp: int

# Called when the node enters the scene tree for the first time.
func _ready():
	while Directory.game_manager == null:
		await get_tree().physics_frame
	game_manager = Directory.game_manager

# Called when the node enters the scene tree for the first time.
func initialize():
	var card_list = Directory.read_json("res://scripts/json/cards.json")
	piece = card_list[identifying_name]["piece"]
	archetype = card_list[identifying_name]["archetype"]
	capture_value = card_list[identifying_name]["capture_value"]
	hp = card_list[identifying_name]["hp"]+Directory.game_manager.round*3*exp(Directory.game_manager.round*0.5)
	display = card_list[identifying_name]["display"]
	description = card_list[identifying_name]["description"]
	cost = card_list[identifying_name]["cost"]
	$DescriptionWindow/Name.text = display
	$DescriptionWindow/Description.text = description
	uid = Directory.rng.randi_range(-99999,99999)
	$StateMachine.initialize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !game_manager:
		return
	select_card()
	if !selected and Directory.game_manager.hovering_card != self and $DescriptionWindow.scale.y>0.5:
		$AnimationPlayer.play("description_close")
	global_position = global_position.lerp(target_position,delta*4)
	if selected:
		$SelectOutline.visible = true
		var i =0.5
		for path in $SelectOutline.get_children():
			i+=.25
			path.progress+=delta*(1+i)
		if Input.is_action_just_pressed("select") and game_manager.active_tile:
			play_card()
	else:
		$SelectOutline.visible = false

func play_card():
	if Directory.game_manager.dealing:
		return
	if Directory.game_manager.active_tile.get_parent().name.substr(1,1)!="1":
		return
	if Directory.game_manager.active_tile.get_parent().get_child_count()>1:
		return
	selected = false
	change_area("field")

func get_tile():
	if area!= "field":
		return false
	else:
		return get_parent().get_node("Area3D")

func select_card():
	if enemy:
		return
	if Directory.game_manager.phase != "hand" and Directory.game_manager.phase != "win":
		selected = false
		return
	if Input.is_action_just_pressed("select") and game_manager.hovering_card == self:
		match area:
			"deck":
				pass
				#change_area("hand")
			"hand":
				for path in $SelectOutline.get_children():
					path.progress_ratio = .55
					selected = true
					Directory.play_sound("res://audio/sfx/14.wav",-25,1.45,0.5,1)
			"shop":
				$AnimationPlayer.play("buy")
				for path in $SelectOutline.get_children():
					path.progress_ratio = .55
					selected = true
					Directory.play_sound("res://audio/sfx/14.wav",-25,1.45,0.5,1)
			"field":
				if in_play:
					return
				selected = false
				Directory.game_manager.budget += capture_value
				Directory.game_manager.update_sideboard()
				change_area("hand")
				
	elif Input.is_action_just_pressed("select") and selected:
		if Directory.game_manager.active_tile or Directory.game_manager.hovering_button:
			return
		selected = false

#send cards to new area that can affect their functionality
func change_area(new_area):
	var old_area = area
	#$AnimationPlayer.play("description_close")
	match new_area:
		"deck":
			area = new_area
			in_play = false
			change_sprite("card_back")
			if is_inside_tree():
				if $DescriptionWindow.scale.y>0.5:
					$AnimationPlayer.play("description_close")
				Directory.play_sound("res://audio/sfx/cardflick/"+str(Directory.rng.randi_range(1,8))+".mp3",0,.95,0.05,1)
				reparent(Directory.game_manager.deck)
			else:
				Directory.game_manager.deck.add_child(self)
				global_position = Directory.game_manager.deck.global_position
		"graveyard":
			area = new_area
			in_play = false
			change_sprite("card_back")
			if is_inside_tree():
				for card in Directory.game_manager.live_pieces:
					if card.uid == uid:
						Directory.game_manager.live_pieces.erase(self)
				reparent(Directory.game_manager.graveyard)
				Directory.game_manager.live_pieces.erase(self)
			else:
				Directory.game_manager.graveyard.add_child(self)
		"hand":
			Directory.play_sound("res://audio/sfx/cardflick/"+str(Directory.rng.randi_range(1,8))+".mp3",0,1.15,0.05,1)
			area = new_area
			if Directory.game_manager.live_pieces.has(self):
				in_play = false
				Directory.game_manager.live_pieces.erase(self)
			if old_area == "deck":
				change_sprite(identifying_name)
			reparent(Directory.game_manager.hand)
			
		"baubles":
			selected = false
			if $DescriptionWindow.scale.y>0.5:
					$AnimationPlayer.play("description_close")
			Directory.play_sound("res://audio/sfx/cardflick/"+str(Directory.rng.randi_range(1,8))+".mp3",0,1.15,0.05,1)
			area = new_area
			reparent(Directory.game_manager.baubles)
			
		"field":
			if !enemy:
				Directory.play_sound("res://audio/sfx/cardflick/"+str(Directory.rng.randi_range(1,8))+".mp3",0,.9,0.05,1)
				if Directory.game_manager.budget>=capture_value and area == "hand":
					area = new_area
					Directory.game_manager.budget -= capture_value
					Directory.game_manager.update_sideboard()
					reparent(Directory.game_manager.board.get_node(Directory.game_manager.active_tile.get_parent().name.substr(0,2)))
					Directory.game_manager.live_pieces.append(self)
				else:
					return
			else:
				area = new_area
				print("king to field")
				Directory.game_manager.board.get_node("c4").add_child(self)
				print(get_parent())
				in_play = true
				Directory.game_manager.live_pieces.append(self)
				change_sprite(identifying_name)
				rotation = Vector3(0,0,deg_to_rad(0))
		"shop":
			change_sprite(identifying_name)
			area = new_area
	Directory.game_manager.arrange_board.call_deferred()
	#game_manager.arrange_hand.call_deferred()
	Directory.game_manager.arrange_deck.call_deferred()
	Directory.game_manager.arrange_graveyard.call_deferred()
	Directory.game_manager.arrange_baubles.call_deferred()
func change_sprite(sprite):
	var image = Image.load_from_file("res://sprites/"+sprite+".png")
	var texture = ImageTexture.create_from_image(image)
	get_surface_override_material(0).albedo_texture = texture

func _on_area_3d_mouse_entered():
	#print(self)
	game_manager.hovering_card = self
	match area: 
		"hand", "shop", "baubles":
			if !selected:
				$AnimationPlayer.play("description_open")
				Directory.play_sound("res://audio/hover.wav",-7,.75,0.1,1)


func _on_area_3d_mouse_exited():
	if game_manager.hovering_card == self:
		match area: 
			"hand", "shop", "baubles":
				if !selected:
					$AnimationPlayer.play("description_close")
		game_manager.hovering_card = null

	
