extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_boton_volver_pressed():
	queue_free() 
