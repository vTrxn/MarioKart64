extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _on_boton_sonido_pressed():
	print("Botón de sonido presionado (Decorativo)")


func _on_boton_ayudas_pressed():
	var ventana_ayudas = load("res://scenes/menus/MenuAyudas.tscn") .instantiate()
	add_child(ventana_ayudas)


func _on_boton_volver_pressed():
	queue_free()
