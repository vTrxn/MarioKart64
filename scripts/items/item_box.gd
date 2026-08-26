extends Area3D

@onready var model = $Model
@onready var collision_shape = $CollisionShape3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	model.rotate_y(2.0 * delta)

func _on_body_entered(body):
	if body.has_method("trigger_item_box"):
		if body.trigger_item_box():
			_disable_box()

func _disable_box():
	model.hide()
	collision_shape.set_deferred("disabled", true)
	
	await get_tree().create_timer(3.0).timeout
	
	model.show()
	collision_shape.set_deferred("disabled", false)
