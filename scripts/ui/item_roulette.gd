extends CanvasLayer

signal item_selected(item_id)

@onready var background = $Control/Background
@onready var item_icon = $Control/Background/ItemIcon
@onready var timer = $Timer
@onready var audio = $RouletteSound

var is_rolling = false
var time_elapsed = 0.0
var roll_duration = 3.0

var item_db = [
	{ "id": "banana", "texture": preload("res://assets/roulette/banana_rulet.png"), "weight": 40 },
	{ "id": "green_shell", "texture": preload("res://assets/roulette/green_shell_rulet.png"), "weight": 30 },
	{ "id": "red_shell", "texture": preload("res://assets/roulette/red_shell_rulet.png"), "weight": 15 },
	{ "id": "false_box", "texture": preload("res://assets/roulette/false_rulet.png"), "weight": 10 },
	{ "id": "mushroom", "texture": preload("res://assets/roulette/fongus1_rulet.png"), "weight": 5 },
	{ "id": "bullet", "texture": preload("res://assets/roulette/bullet_rulet.png"), "weight": 0 },
	{ "id": "star", "texture": preload("res://assets/roulette/stard_rulet.png"), "weight": 0 },
	{ "id": "bomb", "texture": preload("res://assets/roulette/bomb_rulet.png"), "weight": 0 }
]

var final_item_index = 0

func _ready():
	hide()
	background.scale = Vector2.ZERO

func start_roulette():
	show()
	is_rolling = true
	time_elapsed = 0.0
	
	final_item_index = _get_random_item_by_weight()
	
	background.scale = Vector2(0.6, 0.6)
	
	audio.play()
	timer.wait_time = 0.1
	timer.start()

func _process(delta):
	if is_rolling:
		time_elapsed += delta
		if time_elapsed >= roll_duration:
			_stop_roulette()

func _on_timer_timeout():
	if not is_rolling:
		return
	var visual_random = randi() % item_db.size()
	item_icon.texture = item_db[visual_random]["texture"]

func _stop_roulette():
	is_rolling = false
	timer.stop()
	
	item_icon.texture = item_db[final_item_index]["texture"]
	emit_signal("item_selected", item_db[final_item_index]["id"])
	
	await get_tree().create_timer(2.0).timeout
	background.scale = Vector2(0.6, 0.6)

func _get_random_item_by_weight() -> int:
	var total_weight = 0
	for item in item_db:
		total_weight += item["weight"]
		
	var random_val = randi() % total_weight
	var current_weight = 0
	
	for i in range(item_db.size()):
		current_weight += item_db[i]["weight"]
		if random_val < current_weight:
			return i
			
	return 0
