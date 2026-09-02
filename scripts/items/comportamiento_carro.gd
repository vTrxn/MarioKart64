extends Node
class_name ComportamientoCarro

var kart: CharacterBody3D
var item_roulette: CanvasLayer

var current_item: String = ""
var held_item_node: Node3D = null

var mushroom_uses_left: int = 0
var banana_uses_left: int = 0

var has_mushroom_boost: bool = false
var mushroom_boost_time_left: float = 0.0

var original_max_speed: float = 0.0

func _ready():
	kart = get_parent()
	if kart.has_node("ItemRoulette"):
		item_roulette = kart.get_node("ItemRoulette")
		item_roulette.connect("item_selected", Callable(self, "_on_item_selected"))
	original_max_speed = kart.max_speed

func _process(delta: float):
	if has_mushroom_boost:
		mushroom_boost_time_left -= delta
		if mushroom_boost_time_left <= 0.0:
			has_mushroom_boost = false
			if not kart.has_banana_debuff and not kart.has_false_box_debuff:
				kart.max_speed = original_max_speed

func trigger_item_box() -> bool:
	if item_roulette and not item_roulette.is_rolling:
		if current_item == "":
			item_roulette.start_roulette()
			return true
	return false

func _on_item_selected(item_id: String):
	print("Item selected: ", item_id)
	if held_item_node:
		held_item_node.queue_free()
	current_item = item_id
	
	if item_id == "banana":
		banana_uses_left = 1
		_spawn_held_banana()
	elif item_id == "triple_banana":
		banana_uses_left = 3
		_spawn_held_banana()
	elif item_id == "false_box":
		var false_box_scene = preload("res://scenes/items/false_box.tscn")
		if false_box_scene:
			held_item_node = false_box_scene.instantiate()
			kart.add_child(held_item_node)
			held_item_node.position = Vector3(0, 0.5, 1.5)
	elif item_id == "mushroom":
		mushroom_uses_left = 1
	elif item_id == "triple_mushroom":
		mushroom_uses_left = 3

func _spawn_held_banana():
	var banana_scene = preload("res://scenes/items/banana.tscn")
	if banana_scene:
		held_item_node = banana_scene.instantiate()
		kart.add_child(held_item_node)
		held_item_node.position = Vector3(0, 0.5, 1.5)

func use_item():
	if current_item == "":
		return
		
	if current_item in ["banana", "triple_banana", "false_box"] and held_item_node:
		var item = held_item_node
		kart.remove_child(item)
		kart.get_parent().add_child(item)
		
		item.global_transform = kart.global_transform
		item.global_position = kart.global_position + (kart.global_transform.basis.z * 1.5) + Vector3(0, 0.5, 0)
		
		if item.has_method("activate"):
			item.activate()
			
		held_item_node = null
		
		if current_item in ["banana", "triple_banana"]:
			banana_uses_left -= 1
			if banana_uses_left > 0:
				_spawn_held_banana()
			else:
				_clear_item()
		else:
			_clear_item()
				
	elif current_item in ["mushroom", "triple_mushroom"]:
		_apply_mushroom_boost()
	else:
		if held_item_node:
			held_item_node.queue_free()
			held_item_node = null
		_clear_item()

func _clear_item():
	current_item = ""
	if item_roulette and item_roulette.has_method("clear_item"):
		item_roulette.clear_item()

func _apply_mushroom_boost():
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
		_clear_item()
			
	kart.has_banana_debuff = false
	kart.has_false_box_debuff = false
	
	mushroom_boost_time_left = 1.5
	var boost_speed = original_max_speed * 1.25
	
	if not has_mushroom_boost:
		has_mushroom_boost = true
		kart.max_speed = boost_speed
		if kart.current_speed < boost_speed:
			kart.current_speed = boost_speed
