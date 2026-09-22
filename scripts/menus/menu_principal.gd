extends Control

@onready var boton_jugar: Button = $CenterContainer/ContenedoresBotones/BotonJugar
@onready var boton_ajustes: Button = $CenterContainer/ContenedoresBotones/BotonAjustes
@onready var boton_salir: Button = $CenterContainer/ContenedoresBotones/BotonSalir

const ESCENA_AJUSTES = preload("res://scenes/menus/MenuAjustes.tscn")

func _ready() -> void:
	boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	boton_ajustes.pressed.connect(_on_boton_ajustes_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)
	
	_configurar_navegacion()
	boton_jugar.call_deferred("grab_focus")

func _configurar_navegacion() -> void:
	boton_jugar.focus_neighbor_bottom = boton_jugar.get_path_to(boton_ajustes)
	boton_jugar.focus_neighbor_top = boton_jugar.get_path_to(boton_salir)
	
	boton_ajustes.focus_neighbor_top = boton_ajustes.get_path_to(boton_jugar)
	boton_ajustes.focus_neighbor_bottom = boton_ajustes.get_path_to(boton_salir)
	
	boton_salir.focus_neighbor_top = boton_salir.get_path_to(boton_ajustes)
	boton_salir.focus_neighbor_bottom = boton_salir.get_path_to(boton_jugar)

func _on_boton_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/MenuSeleccionPersonaje.tscn")

func _on_boton_ajustes_pressed() -> void:
	var ajustes = ESCENA_AJUSTES.instantiate()
	$CenterContainer.hide()
	add_child(ajustes)
	ajustes.show()
	
	ajustes.tree_exited.connect(func():
		$CenterContainer.show()
		boton_ajustes.call_deferred("grab_focus")
	)
	
	ajustes.tree_exited.connect(func():
		show()
		boton_ajustes.call_deferred("grab_focus")
	)

func _on_boton_salir_pressed() -> void:
	get_tree().quit()
