extends CanvasLayer

signal item_selected(item_id)

@onready var background = $Control/Background
@onready var item_icon = $Control/Background/ItemIcon
@onready var timer = $Timer

@export var valid_items: Array[Texture2D] = []

var is_rolling = false
var roll_count = 0
var max_rolls = 20
var final_item = 0

func _ready():

	hide()

func start_roulette():
	if valid_items.is_empty():
		print("Error: No has asignado ninguna textura en valid_items")
		return
		
	show()
	is_rolling = true
	roll_count = 0
	final_item = randi() % valid_items.size()
	
	timer.wait_time = 0.1
	timer.start()

func _on_timer_timeout():
	if not is_rolling:
		return
		
	roll_count += 1
	
	if roll_count >= max_rolls:
		timer.stop()
		is_rolling = false
		item_icon.texture = valid_items[final_item]
		emit_signal("item_selected", final_item)
	else:
		var random_item = randi() % valid_items.size()
		item_icon.texture = valid_items[random_item]

func hide_roulette():
	hide()
