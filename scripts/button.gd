extends Area3D

signal toggle

var pressed = false
@export var sprite: Sprite3D
@export var outline: Sprite3D
@export var button_type: String

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("released")
	toggle.connect(_on_toggle)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match button_type:
		"commence":
			if Directory.game_manager.board_card_count_player > 1:
				get_parent().modulate = Color(1,1,1,1)
				if Input.is_action_just_pressed("select") and Directory.game_manager.hovering_button == self and !pressed:
					outline.visible = false
					pressed = true
					toggle.emit()
					Directory.game_manager.change_phase("commencement")
					Directory.play_sound("res://audio/sfx/Change.wav",-5,.75,0.05,1)
			else:
				get_parent().modulate = Color(.5,.5,.5,1)
		"next_round":
			if Directory.game_manager.phase == "win" and !pressed:
				get_parent().modulate = Color(1,1,1,1)
				if Input.is_action_just_pressed("select") and Directory.game_manager.hovering_button == self and !pressed:
					outline.visible = false
					pressed = true
					toggle.emit()
					Directory.play_sound("res://audio/sfx/Change.wav",-5,.75,0.05,1)
					await get_tree().create_timer(.35).timeout
					pressed = false
					toggle.emit()
					await get_tree().create_timer(.15).timeout
					Directory.game_manager.start_round()
			else:
				get_parent().modulate = Color(.5,.5,.5,1)
		"buy":
			pass
			if Directory.game_manager.gold >= get_parent().cost:
				sprite.modulate = Color(1,1,1,1)
				if Input.is_action_just_pressed("select") and Directory.game_manager.hovering_button == self and !pressed and get_parent().selected and get_parent().area == "shop":
					outline.visible = false
					pressed = true
					toggle.emit()
					Directory.play_sound("res://audio/sfx/Change.wav",-5,.75,0.05,1)
					await get_tree().create_timer(.25).timeout
					Directory.game_manager.gold -= get_parent().cost
					Directory.game_manager.update_gold()
					match get_parent().piece:
						"bauble":
							get_parent().change_area("baubles")
						_:
							get_parent().selected = false
							get_parent().change_area("deck")
			else:
				sprite.modulate = Color(.5,.5,.5,1)


func _on_toggle():
	if pressed and $AnimationPlayer.current_animation != "pressed":
		$AnimationPlayer.play("pressed")
	elif !pressed and $AnimationPlayer.current_animation != "released":
		$AnimationPlayer.play("released")


func _on_mouse_entered():
	if pressed:
		return
	Directory.game_manager.hovering_button = self
	outline.visible = true
	#print(Directory.game_manager.active_tile.get_parent())

func _on_mouse_exited():
	outline.visible = false
	if Directory.game_manager.hovering_button == self:
		Directory.game_manager.hovering_button = null
