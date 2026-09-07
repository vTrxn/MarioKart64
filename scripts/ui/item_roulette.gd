extends CanvasLayer

signal item_selected(item_id)

@onready var item_container = $ItemContainer
@onready var item_icon = $ItemContainer/ItemIcon
@onready var timer = $ItemContainer/Timer
@onready var audio = $ItemContainer/RouletteSound

@onready var lap_number_rect: TextureRect = $"LapConter/Lap Number"
@onready var timer_label: Label = $TimerContainer/TimerValue
@onready var position_label: Label = $PositionLabel

const TEX_LAP_1 = preload("res://assets/LapAndTime/Lap1.png")
const TEX_LAP_2 = preload("res://assets/LapAndTime/Lap2.png")
const TEX_LAP_3 = preload("res://assets/LapAndTime/Lap3.png")

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

var race_time: float = 0.0
var is_race_active: bool = false
var current_lap: int = 1
var total_laps: int = 3

func _ready():
	item_container.hide()
	if timer and not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	
	_update_lap_display(1)
	update_position_display(1)

func _process(delta: float):
	if is_rolling:
		time_elapsed += delta
		if time_elapsed >= roll_duration:
			_stop_roulette()
			
	if is_race_active:
		race_time += delta
		_update_timer_display()

func start_race_timer():
	race_time = 0.0
	is_race_active = true

func stop_race_timer():
	is_race_active = false

func _update_timer_display():
	var minutes: int = int(race_time / 60.0)
	var seconds: int = int(race_time) % 60
	var milliseconds: int = int((race_time - int(race_time)) * 100)
	timer_label.text = "\"%02d'%02d\"%02d" % [minutes, seconds, milliseconds]

func advance_lap():
	if current_lap < total_laps:
		current_lap += 1
		_update_lap_display(current_lap)
	else:
		stop_race_timer()
		print("¡Carrera finalizada!")

func _update_lap_display(lap: int):
	current_lap = lap
	match lap:
		1: lap_number_rect.texture = TEX_LAP_1
		2: lap_number_rect.texture = TEX_LAP_2
		3: lap_number_rect.texture = TEX_LAP_3

func update_position_display(pos: int):
	var suffixes = ["st", "nd", "rd", "th"]
	var suffix_index = min(pos - 1, 3)
	position_label.text = "%d%s" % [pos, suffixes[suffix_index]]

func start_roulette():
	item_container.show()
	is_rolling = true
	time_elapsed = 0.0
	
	final_item_index = _get_random_item_by_weight()
	
	if audio:
		audio.play()
		
	_on_timer_timeout()
	timer.wait_time = 0.08
	timer.start()

func _on_timer_timeout():
	if not is_rolling:
		return
	var visual_random = randi() % item_db.size()
	item_icon.texture = item_db[visual_random]["texture"]

func _stop_roulette():
	is_rolling = false
	timer.stop()
	
	if audio:
		audio.stop()
	
	item_icon.texture = item_db[final_item_index]["texture"]
	emit_signal("item_selected", item_db[final_item_index]["id"])

func set_item_texture(tex: Texture2D):
	if item_icon:
		item_icon.texture = tex

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
