extends Area3D

var active = false
var fall_gravity = 20.0

@onready var collision = $CollisionShape3D
@onready var sprite = $Sprite3D

func _ready():
	collision.disabled = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func activate():
	active = true
	collision.set_deferred("disabled", false)
	
	if has_node("RayCast3D"):
		var raycast = $RayCast3D
		raycast.enabled = true
	else:
		pass

func _process(delta):
	if active and has_node("RayCast3D"):
		var ray = $RayCast3D
		if ray.is_colliding():
			var p = ray.get_collision_point()
			if global_position.y - p.y > 0.2:
				global_position.y -= fall_gravity * delta
			else:
				global_position.y = p.y + 0.2
		else:
			global_position.y -= fall_gravity * delta

func _on_body_entered(body):
	if not active:
		return
	if body.has_method("banana_debuff"):
		body.banana_debuff()
		queue_free()
