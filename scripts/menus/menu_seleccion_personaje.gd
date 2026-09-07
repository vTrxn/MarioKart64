extends Control

var personaje_seleccionado: String = ""

@onready var contenedor_personajes = $TextureRect/ContenedorPersonajes
@onready var boton_continuar = $TextureRect/BotonContinuar

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if boton_continuar:
		boton_continuar.disabled = true
	
	if contenedor_personajes:
		for boton in contenedor_personajes.get_children():
			if boton is Button:
				boton.pressed.connect(func(): _seleccionar_personaje(boton.name))


func _seleccionar_personaje(nombre_personaje: String):
	personaje_seleccionado = nombre_personaje
	print("Has seleccionado a: ", personaje_seleccionado)
	
	if boton_continuar:
		boton_continuar.disabled = false


func _on_boton_continuar_pressed():
	if personaje_seleccionado != "":
		print("El juego se iniciara con el personaje: ", personaje_seleccionado)
		get_tree().change_scene_to_file("res://scenes/menus/MenuSeleccionMapa.tscn")


func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/MenuPrincipal.tscn")
