extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	get_tree().paused = true

func _on_boton_continuar_pressed():
	get_tree().paused = false
	queue_free()

func _on_boton_ajustes_pressed():
	var ventana_ajustes = load("res://scenes/menus/MenuAjustes.tscn").instantiate()
	add_child(ventana_ajustes)

func _on_boton_salir_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
