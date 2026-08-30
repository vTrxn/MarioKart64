extends CharacterBody3D

@export_group("Fisicas del kart")
@export var max_speed: float = 20.0
@export var acceleration: float = 15.0
@export var friction: float = 8.0
@export var steering_angle: float = 2.5
@export var gravity: float = 20.0

var current_speed: float = 0.0
@onready var item_roulette = $ItemRoulette

var current_item: String = ""
var held_item_node: Node3D = null
var original_max_speed: float = 0.0
var has_banana_debuff: bool = false
var has_false_box_debuff: bool = false

var mushroom_uses_left: int = 0
var has_mushroom_boost: bool = false
var mushroom_boost_time_left: float = 0.0

var banana_uses_left: int = 0

func _ready():
	original_max_speed = max_speed
	if item_roulette:
		item_roulette.connect("item_selected", Callable(self, "_on_item_selected"))

func _on_item_selected(item_id):
	print("Item selected: ", item_id)
	if held_item_node:
		held_item_node.queue_free()
	current_item = item_id
	if item_id == "banana":
		banana_uses_left = 1
		var banana_scene = preload("res://scenes/items/banana.tscn")
		if banana_scene:
			held_item_node = banana_scene.instantiate()
			add_child(held_item_node)
			held_item_node.position = Vector3(0, 0.5, 1.5)
	elif item_id == "triple_banana":
		banana_uses_left = 3
		var banana_scene = preload("res://scenes/items/banana.tscn")
		if banana_scene:
			held_item_node = banana_scene.instantiate()
			add_child(held_item_node)
			held_item_node.position = Vector3(0, 0.5, 1.5)
	elif item_id == "false_box":
		var false_box_scene = preload("res://scenes/items/false_box.tscn")
		if false_box_scene:
			held_item_node = false_box_scene.instantiate()
			add_child(held_item_node)
			held_item_node.position = Vector3(0, 0.5, 1.5)
	elif item_id == "mushroom":
		mushroom_uses_left = 1
	elif item_id == "triple_mushroom":
		mushroom_uses_left = 3

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			trigger_item_box()
			
	if event.is_action_pressed("usar_item"):
		use_item()

func use_item():
	if current_item == "":
		return
		
	if current_item in ["banana", "triple_banana", "false_box"] and held_item_node:
		var item = held_item_node
		remove_child(item)
		get_parent().add_child(item)
		
		item.global_transform = global_transform
		item.global_position = global_position + (global_transform.basis.z * 1.5) + Vector3(0, 0.5, 0)
		
		if item.has_method("activate"):
			item.activate()
			
		held_item_node = null
		
		if current_item in ["banana", "triple_banana"]:
			banana_uses_left -= 1
			if banana_uses_left > 0:
				var banana_scene = preload("res://scenes/items/banana.tscn")
				if banana_scene:
					held_item_node = banana_scene.instantiate()
					add_child(held_item_node)
					held_item_node.position = Vector3(0, 0.5, 1.5)
			else:
				current_item = ""
				if item_roulette and item_roulette.has_method("clear_item"):
					item_roulette.clear_item()
		else:
			current_item = ""
			if item_roulette and item_roulette.has_method("clear_item"):
				item_roulette.clear_item()
				
	elif current_item in ["mushroom", "triple_mushroom"]:
		apply_mushroom_boost()
	else:
		if held_item_node:
			held_item_node.queue_free()
			held_item_node = null
			
		current_item = ""
		
		if item_roulette and item_roulette.has_method("clear_item"):
			item_roulette.clear_item()

func banana_debuff():
	if has_banana_debuff:
		return
	has_banana_debuff = true
	
	var target_speed = original_max_speed * 0.25
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "max_speed", target_speed, 1.0)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "current_speed", current_speed * 0.25, 1.0)
	
	await tween.finished
	
	max_speed = original_max_speed
	has_banana_debuff = false

func false_box_debuff():
	if has_banana_debuff or has_false_box_debuff:
		return
	has_false_box_debuff = true
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "max_speed", 0.0, 0.3)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self, "current_speed", 0.0, 0.3)
	
	velocity.y = 15.0
	
	await get_tree().create_timer(1.5).timeout
	
	max_speed = original_max_speed
	has_false_box_debuff = false

func apply_mushroom_boost():
	if mushroom_uses_left <= 0:
		return
		
	mushroom_uses_left -= 1
	
	if mushroom_uses_left == 2:
		var tex = preload("res://assets/roulette/fongus2_rulet.png")
		if item_roulette and item_roulette.has_method("set_item_texture"):
			item_roulette.set_item_texture(tex)
	elif mushroom_uses_left == 1:
		var tex = preload("res://assets/roulette/fongus1_rulet.png")
		if item_roulette and item_roulette.has_method("set_item_texture"):
			item_roulette.set_item_texture(tex)
	elif mushroom_uses_left <= 0:
		current_item = ""
		if item_roulette and item_roulette.has_method("clear_item"):
			item_roulette.clear_item()
			
	has_banana_debuff = false
	has_false_box_debuff = false
	
	mushroom_boost_time_left = 1.5
	var boost_speed = original_max_speed * 1.25
	
	if not has_mushroom_boost:
		has_mushroom_boost = true
		max_speed = boost_speed
		if current_speed < boost_speed:
			current_speed = boost_speed

func trigger_item_box() -> bool:
	if item_roulette and not item_roulette.is_rolling:
		if current_item == "":
			item_roulette.start_roulette()
			return true
	return false

func _physics_process(delta: float) -> void:
	if has_mushroom_boost:
		mushroom_boost_time_left -= delta
		if mushroom_boost_time_left <= 0.0:
			has_mushroom_boost = false
			if not has_banana_debuff and not has_false_box_debuff:
				max_speed = original_max_speed
				
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0.0:
		velocity.y = 0.0
	
	var turn_input := Input.get_action_strength("girar_izquierda")-Input.get_action_strength("girar_derecha")
	var acceleration_input := Input.get_action_strength("acelerar")-Input.get_action_strength("frenar")
	if acceleration_input !=0:
		current_speed = move_toward(current_speed, acceleration_input * max_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, friction * delta)
	
	if abs(current_speed) > 0.1:
		rotate_y(turn_input * steering_angle * delta * sign(current_speed))
	
	var forward_dir := -transform.basis.z
	var horrizontal_velocity := forward_dir * current_speed
	
	velocity.x = horrizontal_velocity.x
	velocity.z = horrizontal_velocity.z
	
	move_and_slide()
