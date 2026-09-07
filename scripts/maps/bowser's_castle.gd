extends Node3D

var escena_pausa = preload("res://scenes/menus/MenuPausa.tscn")

func _unhandled_input(event):
	if event.is_action_pressed("pausa"):
		_abrir_menu_pausa()

func _abrir_menu_pausa():
	if not has_node("MenuPausa"):
		var instancia_pausa = escena_pausa.instantiate()
		instancia_pausa.name = "MenuPausa"
		add_child(instancia_pausa)
