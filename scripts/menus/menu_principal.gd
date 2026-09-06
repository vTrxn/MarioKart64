extends Control

func _on_boton_jugar_pressed():
	get_tree().change_scene_to_file("res://SeleccionPersonaje.tscn")

func _on_boton_ajustes_pressed():
	var ventana_ajustes = load("res://scenes/menus/MenuAjustes.tscn").instantiate()
	add_child(ventana_ajustes)


func _on_boton_salir_pressed():
	get_tree().quit()
