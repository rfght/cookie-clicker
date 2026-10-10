extends Node2D

# =============================================
# ПАДАЮЩАЯ ПЕЧЕНЬКА (с эффектами) — Godot 4
# =============================================

const FONT_EMOJI_PATH = "res://assets/fonts/SegoeUiEmoji.ttf"

var label: Label = null
var base_alpha: float = 1.0
var flicker_tween: Tween = null

var COOKIE_VARIANTS = [
	{"color": Color(1.0, 1.0, 1.0)},
	{"color": Color(1.0, 0.85, 0.6)},
	{"color": Color(0.75, 0.55, 0.35)},
	{"color": Color(1.0, 0.7, 0.4)},
	{"color": Color(0.95, 0.95, 1.0)},
	{"color": Color(1.0, 0.9, 0.5)},
	{"color": Color(1.0, 0.6, 0.8)},
	{"color": Color(0.6, 1.0, 0.7)},
]

var GLOW_COLOR = Color(1.0, 0.8, 0.4, 0.7)


func _ready():
	var font_size := int(randf_range(28, 60))
	var font: FontFile = load(FONT_EMOJI_PATH)
	var variant = COOKIE_VARIANTS[randi() % COOKIE_VARIANTS.size()]

	label = Label.new()
	label.text = "🍪"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var settings := LabelSettings.new()
	settings.font = font
	settings.font_size = font_size
	settings.font_color = variant["color"]

	if randf() > 0.5:
		settings.outline_size = 2
		settings.outline_color = GLOW_COLOR

	label.label_settings = settings

	label.size = Vector2(font_size, font_size)
	label.position = Vector2(-font_size / 2.0, -font_size / 2.0)

	add_child(label)

	base_alpha = randf_range(0.25, 0.55)
	modulate = Color(1, 1, 1, base_alpha)

	if randf() > 0.4:
		start_flicker()


func start_flicker():
	if flicker_tween and flicker_tween.is_valid():
		flicker_tween.kill()

	flicker_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var flicker_min = base_alpha * 0.5
	var flicker_max = base_alpha * 1.3
	var cycle = randf_range(1.2, 2.8)

	flicker_tween.tween_property(self, "modulate:a", flicker_min, cycle)
	flicker_tween.tween_property(self, "modulate:a", flicker_max, cycle)
	flicker_tween.tween_property(self, "modulate:a", base_alpha, cycle)
