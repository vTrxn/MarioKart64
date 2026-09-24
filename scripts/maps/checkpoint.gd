extends Node3D
class_name Checkpoint

enum CheckpointType {
	FINISH_LINE, # Meta (conteo de vueltas)
	MANDATORY,   # Obligatorio (validación del trazado)
	TRACKING     # Seguimiento (posiciones / respawn)
}

@export var type: CheckpointType = CheckpointType.MANDATORY
@export var checkpoint_index: int = 0  

@onready var area_3d: Area3D = $Area3D
@onready var respawn_point: Node3D = $RespawnPoint

func _ready() -> void:
	area_3d.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("register_checkpoint"):
		var spawn_transform: Transform3D = respawn_point.global_transform if respawn_point else global_transform
		body.register_checkpoint(type, checkpoint_index, spawn_transform)
