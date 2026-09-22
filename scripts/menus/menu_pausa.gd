extends Control

@onready var boton_continuar: Button = $CenterContainer/ContenedorPausa/BotonContinuar
@onready var boton_ajustes: Button = $CenterContainer/ContenedorPausa/BotonAjustes
@onready var boton_salir: Button = $CenterContainer/ContenedorPausa/BotonSalir

const ESCENA_AJUSTES = preload("res://scenes/menus/MenuAjustes.tscn")

func _ready() -> void:
	hide()
	boton_continuar.pressed.connect(_on_boton_continuar_pressed)
	boton_ajustes.pressed.connect(_on_boton_ajustes_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)
	_configurar_navegacion()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausa") or event.is_action_pressed("ui_cancel"):
		# Si está abierto el menú de ajustes, no despausa el juego desde aquí
		if has_node("MenuAjustes"):
			return
			
		if get_tree().paused:
			despausar()
		else:
			pausar()

func pausar() -> void:
	get_tree().paused = true
	show()
	boton_continuar.call_deferred("grab_focus")

func despausar() -> void:
	get_tree().paused = false
	hide()

func _configurar_navegacion() -> void:
	boton_continuar.focus_neighbor_bottom = boton_continuar.get_path_to(boton_ajustes)
	boton_continuar.focus_neighbor_top = boton_continuar.get_path_to(boton_salir)
	
	boton_ajustes.focus_neighbor_top = boton_ajustes.get_path_to(boton_continuar)
	boton_ajustes.focus_neighbor_bottom = boton_ajustes.get_path_to(boton_salir)
	
	boton_salir.focus_neighbor_top = boton_salir.get_path_to(boton_ajustes)
	boton_salir.focus_neighbor_bottom = boton_salir.get_path_to(boton_continuar)

func _on_boton_continuar_pressed() -> void:
	despausar()

func _on_boton_ajustes_pressed() -> void:
		var ajustes = ESCENA_AJUSTES.instantiate()
		$CenterContainer.hide()
		add_child(ajustes)
		ajustes.show()
		ajustes.tree_exited.connect(func():
			$CenterContainer.show()
			boton_ajustes.call_deferred("grab_focus")
)

func _on_boton_salir_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
