class_name Menu
extends Node2D

@export var play_scene: PackedScene

@onready var playButton: Button = $UILayer/UI/Buttons/PlayButton
@onready var optionsButton: Button = $UILayer/UI/Buttons/OptionsButton
@onready var creditsButton: Button = $UILayer/UI/Buttons/CreditsButton
@onready var closeButton: Button = $UILayer/UI/Buttons/CloseButton
@onready var creditsPanel: ColorRect = $UILayer/UI/CreditsPanel
@onready var creditsText: Label = $UILayer/UI/CreditsPanel/CreditsClip/CreditsText
@onready var titleLogo: Sprite2D = $TitleLogo
@onready var backdrop: Sprite2D = $Backdrop
@onready var backdrop2: Sprite2D = $Backdrop2
@onready var buttons_root: Control = $UILayer/UI/Buttons
@onready var ui_layer: CanvasLayer = $UILayer
@onready var options: Node = $Options

@export var credits_font_size: int = 22:
	set(value):
		credits_font_size = maxi(value, 1)
		if is_node_ready():
			_apply_credits_font()
			_reflow_credits(true)
@export var credits_margin: float = 0.04:
	set(value):
		credits_margin = maxf(value, 0.0)
		if is_node_ready():
			_reflow_credits(true)
@export var creditsScrollSpeed: float = 0.11
var creditsActive: bool = false
var _credits_height: float = 0.0
@export var menuBgScrollSpeed: float = 20.0
var _leaving: bool = false
var _bg_y: float = 0.0

static var padding: float = 10.0

var _buttons: Array[Button] = []


func _ready() -> void:
	_buttons = [playButton, optionsButton, creditsButton, closeButton]
	_apply_text()
	get_viewport().size_changed.connect(_on_credits_resized)
	if creditsPanel != null:
		creditsPanel.resized.connect(_on_credits_resized)
	_place_backdrop()


func _apply_text() -> void:
	var text := UiText.section("menu")
	var body = text.get("credits_body", [])
	var credits := ""
	if body is Array:
		credits = "\n".join(body)
	elif body is String:
		credits = body
	_set_label(creditsText, credits)
	if creditsText != null:
		_apply_credits_font()
		_reflow_credits(false)


func _apply_credits_font() -> void:
	if creditsText == null:
		return
	creditsText.add_theme_font_size_override("font_size", credits_font_size)
	creditsText.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	creditsText.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT


func _credits_inner_width() -> float:
	if creditsPanel == null:
		return 0.0
	return maxf(creditsPanel.size.x * (1.0 - credits_margin * 2.0), 1.0)


func _measure_credits_height(width: float) -> float:
	if creditsText == null:
		return 0.0
	var font := creditsText.get_theme_font("font")
	if font == null:
		return creditsText.get_minimum_size().y
	return font.get_multiline_string_size(creditsText.text, HORIZONTAL_ALIGNMENT_LEFT, width, credits_font_size).y


func _on_credits_resized() -> void:
	if creditsText == null or not creditsText.visible:
		return
	_reflow_credits(true)


func _reflow_credits(keep_scroll: bool) -> void:
	if creditsText == null or creditsPanel == null:
		return
	var width := _credits_inner_width()
	var top := creditsPanel.size.y
	if keep_scroll:
		top = creditsText.offset_top
	_credits_height = _measure_credits_height(width)
	_place_credits(top)


func _place_credits(top: float) -> void:
	if creditsText == null:
		return
	creditsText.anchor_left = 0.0
	creditsText.anchor_top = 0.0
	creditsText.anchor_right = 1.0
	creditsText.anchor_bottom = 0.0
	var margin := creditsPanel.size.x * credits_margin
	creditsText.offset_left = margin
	creditsText.offset_right = -margin
	creditsText.offset_top = top
	creditsText.offset_bottom = top + _credits_height


func _set_label(node: Node, value: String) -> void:
	if node != null:
		node.set("text", value)


func _process(elapsed: float) -> void:
	if backdrop.texture:
		var tile_h: float = backdrop.texture.get_height() * backdrop.scale.y
		if tile_h > 0.0:
			_bg_y = fmod(_bg_y + menuBgScrollSpeed * elapsed, tile_h)
			_place_backdrop()

	if creditsActive:
		var next_top := creditsText.offset_top - creditsScrollSpeed * creditsPanel.size.y * elapsed
		if next_top + _credits_height < 0.0:
			next_top = creditsPanel.size.y
		_place_credits(next_top)

	if _leaving:
		var dx: float = get_viewport().get_visible_rect().size.x * 0.39 * elapsed
		titleLogo.position.x -= dx
		if buttons_root != null:
			buttons_root.position.x -= dx
		var logo_w: float = 0.0
		if titleLogo.texture:
			logo_w = titleLogo.texture.get_width() * titleLogo.scale.x
		var logo_right: float = titleLogo.position.x + logo_w
		var buttons_right := 0.0
		if buttons_root != null:
			buttons_right = buttons_root.position.x + playButton.position.x + playButton.size.x
		if buttons_right < 0.0 and logo_right < 0.0:
			_leaving = false
			get_tree().change_scene_to_packed(play_scene)


func _place_backdrop() -> void:
	if backdrop.texture == null:
		return
	backdrop.position.y = _bg_y
	backdrop2.position.y = _bg_y - backdrop.texture.get_height() * backdrop.scale.y


func closeGame() -> void:
	get_tree().quit()


func clickPlay() -> void:
	if _leaving:
		return
	if play_scene == null:
		push_warning("Assign play_scene on the menu to the scene Play should open.")
		return
	_leaving = true
	for b in _buttons:
		b.disabled = true


func optionsMenu() -> void:
	if _leaving:
		return
	_show_menu(false)
	if ui_layer != null:
		ui_layer.visible = false
	options.visible = true


func show_main_menu() -> void:
	options.visible = false
	if ui_layer != null:
		ui_layer.visible = true
	_show_menu(true)


func _show_menu(show_menu: bool) -> void:
	titleLogo.visible = show_menu
	for b in _buttons:
		if b == null:
			continue
		b.visible = show_menu
		b.disabled = not show_menu
	if not show_menu:
		if creditsText != null:
			creditsText.visible = false
		if creditsPanel != null:
			creditsPanel.visible = false
		creditsActive = false


func showCredits() -> void:
	creditsText.visible = not creditsText.visible
	creditsPanel.visible = creditsText.visible
	if creditsText.visible:
		_reflow_credits(false)
		creditsActive = true
	else:
		creditsActive = false
