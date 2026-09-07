extends CharacterBody3D

@export_group("Fisicas del kart")
@export var max_speed: float = 50.0
@export var acceleration: float = 15.0
@export var friction: float = 8.0
@export var steering_angle: float = 2.5
@export var gravity: float = 20.0

@export_group("Direccion y Giro")
@export var steering_speed: float = 1.2  
@export var steering_smooth: float = 8.0  

@export_group("Derrape")
@export var jump_force: float = 4.0
@export var drift_steering: float = 1.5
@export var boost_multiplier: float = 1.5
@export var boost_duration: float = 1.0
@export var min_drift_time: float = 1.0

@export_group("Checkpoints")
@export var total_mandatory_checkpoints: int = 10 

var current_speed: float = 0.0
var current_steering: float = 0.0
var is_drifting: bool = false
var drift_dir: float = 0.0
var drift_timer: float = 0.0
var boost_timer: float = 0.0

@onready var item_roulette = $Hud

var original_max_speed: float = 0.0
var has_banana_debuff: bool = false
var has_false_box_debuff: bool = false

var item_manager: Node
var original_spring_arm_basis: Basis


var last_mandatory_index: int = 0
var last_visited_checkpoint_index: int = -1
var last_respawn_transform: Transform3D
var checkpoints_passed_in_lap: int = 0

func _ready():
	original_max_speed = max_speed
	last_respawn_transform = global_transform
	
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


func register_checkpoint(type: int, index: int, spawn_transform: Transform3D):
	if index == last_visited_checkpoint_index:
		return
		
	last_visited_checkpoint_index = index
	last_respawn_transform = spawn_transform

	match type:
		0: 
			
			if item_roulette and not item_roulette.is_race_active:
				item_roulette.start_race_timer()
				last_mandatory_index = 0
				checkpoints_passed_in_lap = 0
				print("¡Carrera iniciada!")
				return

			
			if last_mandatory_index >= total_mandatory_checkpoints and checkpoints_passed_in_lap >= (total_mandatory_checkpoints / 2):
				last_mandatory_index = 0
				checkpoints_passed_in_lap = 0
				if item_roulette:
					item_roulette.advance_lap()
					print("¡Vuelta completada!")
			else:
				print("Meta cruzada pero faltan checkpoints: ", last_mandatory_index, "/", total_mandatory_checkpoints)

		1: 
			if index > last_mandatory_index:
				last_mandatory_index = index
				checkpoints_passed_in_lap += 1
				print("Checkpoint validado: ", index, "/", total_mandatory_checkpoints)

		2: 
			pass

func respawn():
	velocity = Vector3.ZERO
	current_speed = 0.0
	is_drifting = false
	drift_timer = 0.0
	boost_timer = 0.0
	
	if last_respawn_transform != Transform3D.IDENTITY:
		
		var original_scale = scale
		
		
		global_position = last_respawn_transform.origin
		global_transform.basis = last_respawn_transform.basis.orthonormalized()
		
		
		scale = original_scale
		
		
		if has_node("SpringArm3D"):
			var spring_arm = get_node("SpringArm3D")
			spring_arm.global_position = global_position
			var current_y_rotation = global_transform.basis.get_euler().y
			var kart_yaw_basis = Basis(Vector3.UP, current_y_rotation)
			spring_arm.global_transform.basis = (kart_yaw_basis * original_spring_arm_basis).orthonormalized()

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
	
	var turn_input :float = Input.get_action_strength("girar_izquierda")-Input.get_action_strength("girar_derecha")
	var acceleration_input :float = Input.get_action_strength("acelerar")-Input.get_action_strength("frenar")
	
	if boost_timer > 0.0:
		boost_timer -= delta
		current_speed = max_speed * boost_multiplier
	else:
		if acceleration_input !=0:
			current_speed = move_toward(current_speed, acceleration_input * max_speed, acceleration * delta)
		else:
			current_speed = move_toward(current_speed, 0.0, friction * delta)
	
	_handle_drift(turn_input,delta)
	
	current_steering = lerp(current_steering, turn_input, steering_smooth * delta)
	
	if abs(current_speed) > 0.1:
		var speed_factor: float = clamp(abs(current_speed) / max_speed, 0.3, 1.0)
		
		if is_drifting:
			var drift_turn: float = (drift_dir * 0.8) + (turn_input * 0.4)
			rotate_y(drift_turn * drift_steering * delta * sign(current_speed))
		else:
			rotate_y(current_steering * steering_speed * speed_factor * delta * sign(current_speed))
	
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
		
		var new_basis = spring_arm.global_transform.basis.slerp(target_basis, 5.0 * delta)
		spring_arm.global_transform.basis = new_basis.orthonormalized()

func _handle_drift(turn_input: float, delta: float):
	if Input.is_action_just_pressed("derrapar") and is_on_floor() and not is_drifting and boost_timer <= 0.0:
		is_drifting = true
		drift_dir = sign(turn_input) if turn_input != 0 else 1.0
		drift_timer = 0.0
		velocity.y = jump_force
		print("¡Derrape Iniciado!")

	if is_drifting:
		if Input.is_action_pressed("derrapar"):
			drift_timer += delta
			print("Tiempo derrapando: ", drift_timer)
		else:
			_end_drift()

func _end_drift():
	if drift_timer >= min_drift_time:
		boost_timer = boost_duration
		print("¡SE ACTIVÓ TURBO!")
	else:
		print("Derrape muy corto, no hubo turbo")
	
	is_drifting = false
	drift_dir = 0.0
	drift_timer = 0.0
