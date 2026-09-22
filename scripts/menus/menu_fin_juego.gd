extends Control

@onready var boton_reintentar: Button = $CenterContainer/ContenedorFinJuego/BotonReintentar
@onready var boton_inicio: Button = $CenterContainer/ContenedorFinJuego/BotonInicio

func _ready() -> void:
	hide()
	boton_reintentar.pressed.connect(_on_boton_reintentar_pressed)
	boton_inicio.pressed.connect(_on_boton_inicio_pressed)
	_configurar_navegacion()

func mostrar_menu() -> void:
	get_tree().paused = true
	show()
	boton_reintentar.call_deferred("grab_focus")

func _configurar_navegacion() -> void:
	boton_reintentar.focus_neighbor_bottom = boton_reintentar.get_path_to(boton_inicio)
	boton_reintentar.focus_neighbor_top = boton_reintentar.get_path_to(boton_inicio)
	
	boton_inicio.focus_neighbor_top = boton_inicio.get_path_to(boton_reintentar)
	boton_inicio.focus_neighbor_bottom = boton_inicio.get_path_to(boton_reintentar)

func _on_boton_reintentar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MenuSeleccionPersonaje.tscn")

func _on_boton_inicio_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
