extends Area3D

@export var fall_gravity: float = 20.0

var active: bool = false

@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var sprite: Sprite3D = $Sprite3D
@onready var raycast: RayCast3D = $RayCast3D if has_node("RayCast3D") else null

func _ready() -> void:
	collision.disabled = true
	body_entered.connect(_on_body_entered)

func activate() -> void:
	active = true
	collision.set_deferred("disabled", false)
	if raycast:
		raycast.enabled = true

func _physics_process(delta: float) -> void:
	if not active:
		return
		
	if raycast and raycast.is_colliding():
		var impact_point = raycast.get_collision_point()
		if global_position.y - impact_point.y > 0.2:
			global_position.y -= fall_gravity * delta
		else:
			global_position.y = impact_point.y + 0.2
	else:
		global_position.y -= fall_gravity * delta

func _on_body_entered(body: Node3D) -> void:
	if not active:
		return
		
	if body.has_method("banana_debuff"):
		body.banana_debuff()
		queue_free()
