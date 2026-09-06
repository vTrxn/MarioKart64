extends CanvasLayer

signal item_selected(item_id)

@onready var item_container = $ItemContainer
@onready var item_icon = $ItemContainer/ItemIcon
@onready var timer = $ItemContainer/Timer
@onready var audio = $ItemContainer/RouletteSound

var is_rolling = false
var time_elapsed = 0.0
var roll_duration = 2.5

var item_db = [
	{ "id": "banana", "texture": preload("res://assets/roulette/banana_rulet.png"), "weight": 20 },
	{ "id": "triple_banana", "texture": preload("res://assets/roulette/bananas_rulet.png"), "weight": 20 },
	{ "id": "green_shell", "texture": preload("res://assets/roulette/green_shell_rulet.png"), "weight": 0 },
	{ "id": "red_shell", "texture": preload("res://assets/roulette/red_shell_rulet.png"), "weight": 0 },
	{ "id": "false_box", "texture": preload("res://assets/roulette/false_rulet.png"), "weight": 20 },
	{ "id": "mushroom", "texture": preload("res://assets/roulette/fongus1_rulet.png"), "weight": 20 },
	{ "id": "triple_mushroom", "texture": preload("res://assets/roulette/fongus3_rulet.png"), "weight": 20 },
	{ "id": "bullet", "texture": preload("res://assets/roulette/bullet_rulet.png"), "weight": 0 },
	{ "id": "star", "texture": preload("res://assets/roulette/stard_rulet.png"), "weight": 0 },
	{ "id": "bomb", "texture": preload("res://assets/roulette/bomb_rulet.png"), "weight": 0 }
]

var final_item_index = 0

func _ready():
	item_container.hide()
	if timer and not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

func start_roulette():
	item_container.show()
	is_rolling = true
	time_elapsed = 0.0
	
	final_item_index = _get_random_item_by_weight()
	
	# 🔊 Inicia el sonido de la ruleta
	if audio:
		audio.play()
		
	_on_timer_timeout()
	timer.wait_time = 0.08
	timer.start()
	
	
func _process(delta):
	if is_rolling:
		time_elapsed += delta
		if time_elapsed >= roll_duration:
			_stop_roulette()

func _on_timer_timeout():
	if not is_rolling:
		return
	# Cambia las imágenes aleatoriamente durante la ruleta
	var visual_random = randi() % item_db.size()
	item_icon.texture = item_db[visual_random]["texture"]

func _stop_roulette():
	is_rolling = false
	timer.stop()
	
	# 🔇 Detiene el sonido al fijar el ítem final
	if audio:
		audio.stop()
	
	item_icon.texture = item_db[final_item_index]["texture"]
	emit_signal("item_selected", item_db[final_item_index]["id"])


func _get_random_item_by_weight() -> int:
	var total_weight = 0
	for item in item_db:
		total_weight += item["weight"]
		
	if total_weight == 0:
		return 0
		
	var random_val = randi() % total_weight
	var current_weight = 0
	
	for i in range(item_db.size()):
		current_weight += item_db[i]["weight"]
		if random_val < current_weight:
			return i
			
	return 0

func clear_item():
	item_container.hide()
	item_icon.texture = null
