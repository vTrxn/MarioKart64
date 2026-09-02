extends CharacterBody3D

@export_group("Fisicas del kart")
@export var max_speed: float = 20.0
@export var acceleration: float = 15.0
@export var friction: float = 8.0
@export var steering_angle: float = 2.5
@export var gravity: float = 20.0

var current_speed: float = 0.0
@onready var item_roulette = $ItemRoulette

var original_max_speed: float = 0.0
var has_banana_debuff: bool = false
var has_false_box_debuff: bool = false

var item_manager: Node

var original_spring_arm_basis: Basis

func _ready():
	original_max_speed = max_speed
	
	item_manager = preload("res://scripts/items/comportamiento_carro.gd").new()
	item_manager.name = "ComportamientoCarro"
	add_child(item_manager)
	
	if has_node("SpringArm3D"):
		var spring_arm = get_node("SpringArm3D")
		original_spring_arm_basis = spring_arm.transform.basis
		spring_arm.set_as_top_level(true)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if item_manager.has_method("trigger_item_box"):
				item_manager.trigger_item_box()
			
	if event.is_action_pressed("usar_item"):
		if item_manager.has_method("use_item"):
			item_manager.use_item()

func trigger_item_box() -> bool:
	if item_manager.has_method("trigger_item_box"):
		return item_manager.trigger_item_box()
	return false

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

func _physics_process(delta: float) -> void:
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
	
	if has_node("SpringArm3D"):
		var spring_arm = get_node("SpringArm3D")
		spring_arm.global_position = global_position
		
		var current_y_rotation = global_transform.basis.get_euler().y
		var kart_yaw_basis = Basis(Vector3.UP, current_y_rotation)
		var target_basis = kart_yaw_basis * original_spring_arm_basis
		
		var new_basis = spring_arm.global_transform.basis.slerp(target_basis, 15.0 * delta)
		spring_arm.global_transform.basis = new_basis.orthonormalized()
