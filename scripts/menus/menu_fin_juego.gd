extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func _on_boton_reintentar_pressed():
	get_tree().paused = false
	print("Seleccion Personaje")
	get_tree().change_scene_to_file("res://scenes/menus/MenuSeleccionPersonaje.tscn")

func _on_boton_inicio_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
