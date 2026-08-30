extends Area3D

var active = false

@onready var collision = $CollisionShape3D
@onready var model = $Model

func _ready():
	collision.disabled = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func activate():
	active = true
	collision.set_deferred("disabled", false)

func _process(delta):
	if has_node("Model"):
		model.rotate_y(2.0 * delta)

func _on_body_entered(body):
	if not active:
		return
	if body.has_method("false_box_debuff"):
		body.false_box_debuff()
		queue_free()
