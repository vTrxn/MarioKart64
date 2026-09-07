extends Control

var mapa_seleccionado: String = ""

@onready var contenedor_mapas = $TextureRect/ContenedorMapas
@onready var boton_continuar = $TextureRect/BotonContinuar

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if boton_continuar:
		boton_continuar.disabled = true
	
	if contenedor_mapas:
		for boton in contenedor_mapas.get_children():
			if boton is Button:
				boton.pressed.connect(func(): _seleccionar_mapa(boton.name))


func _seleccionar_mapa(nombre_mapa: String):
	mapa_seleccionado = nombre_mapa
	print("Mapa seleccionado: ", mapa_seleccionado)
	
	if boton_continuar:
		boton_continuar.disabled = false


func _on_boton_continuar_pressed():
	if mapa_seleccionado != "":
		print("Cargando el mapa: ", mapa_seleccionado)
		get_tree().change_scene_to_file("res://scenes/maps/Bowser's_Castle.tscn")
		
		

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/MenuSeleccionPersonaje.tscn")
