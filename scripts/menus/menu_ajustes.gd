extends Control

@onready var boton_sonido: Button = $TextureRect/BotonSonido
@onready var boton_ayudas: Button = $TextureRect/BotonAyudas
@onready var boton_volver: Button = $TextureRect/BotonVolver

const ESCENA_AYUDAS = preload("res://scenes/menus/MenuAyudas.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Conexión de señales de botones
	if boton_sonido: boton_sonido.pressed.connect(_on_boton_sonido_pressed)
	if boton_ayudas: boton_ayudas.pressed.connect(_on_boton_ayudas_pressed)
	if boton_volver: boton_volver.pressed.connect(_on_boton_volver_pressed)
	
	_configurar_navegacion()
	
	# Dar el foco al primer botón para teclado/mando al abrir el menú
	if boton_sonido:
		boton_sonido.call_deferred("grab_focus")

func _configurar_navegacion() -> void:
	if not (boton_sonido and boton_ayudas and boton_volver):
		return
		
	boton_sonido.focus_neighbor_bottom = boton_sonido.get_path_to(boton_ayudas)
	boton_sonido.focus_neighbor_top = boton_sonido.get_path_to(boton_volver)
	
	boton_ayudas.focus_neighbor_top = boton_ayudas.get_path_to(boton_sonido)
	boton_ayudas.focus_neighbor_bottom = boton_ayudas.get_path_to(boton_volver)
	
	boton_volver.focus_neighbor_top = boton_volver.get_path_to(boton_ayudas)
	boton_volver.focus_neighbor_bottom = boton_volver.get_path_to(boton_sonido)

func _on_boton_sonido_pressed() -> void:
	print("Botón de sonido")

func _on_boton_ayudas_pressed() -> void:
	var ajustes = ESCENA_AYUDAS.instantiate()
	add_child(ajustes)
	ajustes.show()
	ajustes.tree_exited.connect(func():
		show()
	)


func _on_boton_volver_pressed() -> void:
	# Al destruirse, dispara automáticamente la señal 'tree_exited' 
	# que escucha el MenuPrincipal o MenuPausa para reaparecer
	queue_free()
