extends Node3D
class_name Checkpoint

# Definición de los 3 tipos de checkpoint
enum CheckpointType {
	FINISH_LINE, # 1. Meta 
	MANDATORY,   # 2. Obligatorio 
	TRACKING     # 3. Seguimiento 
}

@export var type: CheckpointType = CheckpointType.MANDATORY
@export var checkpoint_index: int = 0  

@onready var area_3d: Area3D = $Area3D
@onready var respawn_point: Node3D = $RespawnPoint

func _ready():
	area_3d.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body.has_method("register_checkpoint"):
		var spawn_transform = respawn_point.global_transform
		body.register_checkpoint(type, checkpoint_index, spawn_transform)
