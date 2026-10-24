class_name Options
extends CanvasLayer

@onready var shipButton: Button = $Panel/ShipButton
@onready var musicSlider: HSlider = $Panel/MusicSlider
@onready var sfxSlider: HSlider = $Panel/SfxSlider

const SAVE_PATH: String = "user://Pira2ite.cfg"

var currentShipNumber: int = 0

@export var ship_textures: Array[Texture2D] = []
@export var ship_names: Array[String] = ["N/A"]
@export var missing_ship: String = "WARNING!"
@export var padding: int = 10


func _ready() -> void:
	if musicSlider != null:
		setMusicVolume(musicSlider.value)
	if sfxSlider != null:
		setSfxVolume(sfxSlider.value)
	var menu_music := get_parent().get_node_or_null("Music") as AudioStreamPlayer
	if menu_music != null:
		menu_music.bus = "Music"
	updateShipButtonText()


func setMusicVolume(v: float) -> void:
	_set_bus_volume("Music", v)
	var menu_music := get_parent().get_node_or_null("Music") as AudioStreamPlayer
	if menu_music != null and menu_music.bus != "Music":
		menu_music.bus = "Music"


func setSfxVolume(v: float) -> void:
	_set_bus_volume("SFX", v)


func _set_bus_volume(bus_name: String, v: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")
	if v <= 0.0001:
		AudioServer.set_bus_volume_db(idx, -80.0)
	else:
		AudioServer.set_bus_volume_db(idx, linear_to_db(v))


func backToMenu() -> void:
	var menu := get_parent()
	if menu and menu.has_method("show_main_menu"):
		menu.show_main_menu()
		return
	queue_free()


func cycleShipChoice() -> void:
	var count := ship_textures.size()
	if count <= 0:
		count = ship_names.size()
	if count <= 0:
		return
	currentShipNumber += 1
	if currentShipNumber >= count:
		currentShipNumber = 0
	saveShipChoice()
	updateShipButtonText()


func saveShipChoice() -> void:
	var cf := ConfigFile.new()
	cf.load(SAVE_PATH)
	cf.set_value("data", "shipChoice", currentShipNumber)
	cf.save(SAVE_PATH)


func _ship_choice() -> Variant:
	var cf := ConfigFile.new()
	if cf.load(SAVE_PATH) != OK:
		return null
	if not cf.has_section_key("data", "shipChoice"):
		return null
	return cf.get_value("data", "shipChoice")


func updateShipButtonText() -> void:
	var count := ship_textures.size()
	if count <= 0:
		count = ship_names.size()
	var choice = _ship_choice()
	if choice != null:
		currentShipNumber = int(choice)
	if count > 0 and (currentShipNumber < 0 or currentShipNumber >= count):
		currentShipNumber = 0
	var ship_name := missing_ship
	if currentShipNumber >= 0 and currentShipNumber < ship_names.size():
		ship_name = ship_names[currentShipNumber]
	if shipButton != null:
		shipButton.text = ship_name
