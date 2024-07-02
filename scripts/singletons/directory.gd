extends Node

var rng = RandomNumberGenerator.new()
var game_manager
@onready var common_shop_table = read_json("res://scripts/json/common_shop_table.json")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func read_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var finish = json.parse_string(content)
	return finish


func play_sound(path,volume,pitch,pitch_range,timer):
	var sound = load("res://scenes/sound.tscn").instantiate()
	get_node("/root").add_child(sound)
	sound.stream = load(path)
	sound.pitch_scale = pitch+randf_range(-pitch_range,pitch_range)
	sound.volume_db = volume
	sound.play()
	await get_tree().create_timer(timer).timeout
	sound.queue_free()
