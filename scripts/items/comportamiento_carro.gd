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

const TEX_MUSHROOM_2 = preload("res://assets/roulette/fongus2_rulet.png")
const TEX_MUSHROOM_1 = preload("res://assets/roulette/fongus1_rulet.png")
const BANANA_SCENE = preload("res://scenes/items/banana.tscn")
const FALSE_BOX_SCENE = preload("res://scenes/items/false_box.tscn")

func _ready() -> void:
	kart = get_parent() as CharacterBody3D
	if kart and kart.has_node("Hud"):
		item_roulette = kart.get_node("Hud")
		if not item_roulette.item_selected.is_connected(_on_item_selected):
			item_roulette.item_selected.connect(_on_item_selected)
	
	if kart:
		original_max_speed = kart.max_speed

func _process(delta: float) -> void:
	if has_mushroom_boost:
		mushroom_boost_time_left -= delta
		if mushroom_boost_time_left <= 0.0:
			has_mushroom_boost = false
			if kart and not kart.has_banana_debuff and not kart.has_false_box_debuff:
				kart.max_speed = original_max_speed

func trigger_item_box() -> bool:
	if item_roulette and not item_roulette.is_rolling:
		if current_item == "":
			item_roulette.start_roulette()
			return true
	return false

func _on_item_selected(item_id: String) -> void:
	if held_item_node:
		held_item_node.queue_free()
		
	current_item = item_id
	
	match item_id:
		"banana":
			banana_uses_left = 1
			_spawn_held_item(BANANA_SCENE)
		"triple_banana":
			banana_uses_left = 3
			_spawn_held_item(BANANA_SCENE)
		"false_box":
			_spawn_held_item(FALSE_BOX_SCENE)
		"mushroom":
			mushroom_uses_left = 1
		"triple_mushroom":
			mushroom_uses_left = 3

func _spawn_held_item(scene: PackedScene) -> void:
	if scene and kart:
		held_item_node = scene.instantiate() as Node3D
		kart.add_child(held_item_node)
		held_item_node.position = Vector3(0, 0.5, 1.5)

func use_item() -> void:
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
				_spawn_held_item(BANANA_SCENE)
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

func _clear_item() -> void:
	current_item = ""
	if item_roulette and item_roulette.has_method("clear_item"):
		item_roulette.clear_item()

func _apply_mushroom_boost() -> void:
	if mushroom_uses_left <= 0:
		return
		
	mushroom_uses_left -= 1
	
	if mushroom_uses_left == 2:
		if item_roulette and item_roulette.has_method("set_item_texture"):
			item_roulette.set_item_texture(TEX_MUSHROOM_2)
	elif mushroom_uses_left == 1:
		if item_roulette and item_roulette.has_method("set_item_texture"):
			item_roulette.set_item_texture(TEX_MUSHROOM_1)
	elif mushroom_uses_left <= 0:
		_clear_item()
			
	if kart:
		kart.has_banana_debuff = false
		kart.has_false_box_debuff = false
		
		mushroom_boost_time_left = 1.5
		var boost_speed = original_max_speed * 1.25
		
		has_mushroom_boost = true
		kart.max_speed = boost_speed
		if kart.current_speed < boost_speed:
			kart.current_speed = boost_speed
