extends CharacterBody3D

@export_group("Fisicas del kart")
@export var max_speed: float = 20.0
@export var acceleration: float = 15.0
@export var friction: float = 8.0
@export var steering_angle: float = 2.5
@export var gravity: float = 20.0

var current_speed: float = 0.0
@onready var item_roulette = $ItemRoulette

func _ready():
	if item_roulette:
		item_roulette.connect("item_selected", Callable(self, "_on_item_selected"))

func _on_item_selected(item_id):
	print("Item seleccionado: ", item_id)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE:
			if item_roulette and not item_roulette.is_rolling:
				item_roulette.start_roulette()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
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
