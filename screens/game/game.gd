extends Control

# =============================================
# ИГРОВОЙ ЭКРАН (с шейдером фона)
# =============================================

const FONT_EMOJI_PATH = "res://assets/fonts/SegoeUiEmoji.ttf"
const FONT_MAIN_PATH = "res://assets/fonts/ofont.ru_HIbiny.ttf"
const SHADER_PATH = "res://shaders/background_gradient.shader"

var emoji_font: DynamicFont = null
var main_font: DynamicFont = null

var background: ColorRect = null
var cookie_button: Button = null
var back_button: Button = null

# Счётчики
var cookies_label: Label = null
var coins_label: Label = null
var clicks_label: Label = null
var cps_label: Label = null

# Эффект клика
var click_effect_label: Label = null
var click_effect_tween: Tween = null

# Авто-сохранение
var autosave_timer: Timer = null


func _ready():
	print("[Game] Запуск")
	load_fonts()
	
	set_anchors_and_margins_preset(Control.PRESET_WIDE)
	rect_min_size = Vector2(540, 960)
	
	# Загружаем сохранение
	SaveManager.load_game()
	
	setup_background()
	setup_top_bar()
	setup_counters()
	setup_cookie()
	setup_click_effect()
	setup_autosave()
	
	update_ui()
	print("[Game] Готово")


func _process(delta):
	GameState.tick(delta)
	update_counters_only()


# =============================================
# ШРИФТЫ
# =============================================
func load_fonts():
	emoji_font = DynamicFont.new()
	var emoji_data = load(FONT_EMOJI_PATH)
	if emoji_data:
		emoji_font.font_data = emoji_data
		emoji_font.use_filter = true
		emoji_font.size = 80
	
	main_font = DynamicFont.new()
	var main_data = load(FONT_MAIN_PATH)
	if main_data:
		main_font.font_data = main_data
		main_font.use_filter = true
		main_font.size = 18


# =============================================
# ФОН (шейдер)
# =============================================
func setup_background():
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(1, 1, 1)
	
	background.anchor_left = 0
	background.anchor_top = 0
	background.anchor_right = 1
	background.anchor_bottom = 1
	background.margin_left = 0
	background.margin_top = 0
	background.margin_right = 0
	background.margin_bottom = 0
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# ★ Шейдер
	var shader = load(SHADER_PATH)
	if shader:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		background.material = mat
		print("[Game] Шейдер фона применён")
	else:
		print("[Game] Шейдер не найден, фон — обычный цвет")
		background.color = Color(0.05, 0.04, 0.13)
	
	add_child(background)
	move_child(background, 0)


# =============================================
# ВЕРХНЯЯ ПАНЕЛЬ
# =============================================
func setup_top_bar():
	back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "← Меню"
	back_button.rect_min_size = Vector2(120, 40)
	back_button.anchor_left = 0
	back_button.anchor_top = 0
	back_button.anchor_right = 0
	back_button.anchor_bottom = 0
	back_button.margin_left = 12
	back_button.margin_top = 12
	back_button.margin_right = 132
	back_button.margin_bottom = 52
	
	style_button(back_button, Color(0.2, 0.2, 0.3), Color(0.4, 0.4, 0.55), 14)
	back_button.connect("pressed", self, "_on_back_pressed")
	add_child(back_button)


# =============================================
# СЧЁТЧИКИ
# =============================================
func setup_counters():
	var vbox = VBoxContainer.new()
	vbox.name = "CountersVBox"
	vbox.anchor_left = 0
	vbox.anchor_top = 0
	vbox.anchor_right = 1
	vbox.anchor_bottom = 0
	vbox.margin_left = 0
	vbox.margin_top = 70
	vbox.margin_right = 0
	vbox.margin_bottom = 240
	vbox.alignment = BoxContainer.ALIGN_CENTER
	
	# === Печеньки ===
	cookies_label = Label.new()
	cookies_label.align = Label.ALIGN_CENTER
	cookies_label.rect_min_size = Vector2(0, 60)
	var f1 = DynamicFont.new()
	if main_font and main_font.font_data:
		f1.font_data = main_font.font_data
	f1.size = 42
	f1.use_filter = true
	cookies_label.add_font_override("font", f1)
	cookies_label.add_color_override("font_color", Color(1, 0.9, 0.6))
	vbox.add_child(cookies_label)
	
	# === Монеты ===
	coins_label = Label.new()
	coins_label.align = Label.ALIGN_CENTER
	coins_label.rect_min_size = Vector2(0, 30)
	var f2 = DynamicFont.new()
	if main_font and main_font.font_data:
		f2.font_data = main_font.font_data
	f2.size = 22
	f2.use_filter = true
	coins_label.add_font_override("font", f2)
	coins_label.add_color_override("font_color", Color(1, 0.85, 0.4))
	vbox.add_child(coins_label)
	
	# === /сек ===
	cps_label = Label.new()
	cps_label.align = Label.ALIGN_CENTER
	cps_label.rect_min_size = Vector2(0, 24)
	var f3 = DynamicFont.new()
	if main_font and main_font.font_data:
		f3.font_data = main_font.font_data
	f3.size = 16
	f3.use_filter = true
	cps_label.add_font_override("font", f3)
	cps_label.add_color_override("font_color", Color(0.6, 0.8, 0.6))
	vbox.add_child(cps_label)
	
	# === Клики ===
	clicks_label = Label.new()
	clicks_label.align = Label.ALIGN_CENTER
	clicks_label.rect_min_size = Vector2(0, 24)
	var f4 = DynamicFont.new()
	if main_font and main_font.font_data:
		f4.font_data = main_font.font_data
	f4.size = 14
	f4.use_filter = true
	clicks_label.add_font_override("font", f4)
	clicks_label.add_color_override("font_color", Color(0.7, 0.6, 0.9))
	vbox.add_child(clicks_label)
	
	add_child(vbox)


# =============================================
# ПЕЧЕНЬКА
# =============================================
func setup_cookie():
	cookie_button = Button.new()
	cookie_button.name = "CookieButton"
	cookie_button.text = "🍪"
	cookie_button.rect_min_size = Vector2(280, 280)
	
	cookie_button.anchor_left = 0.5
	cookie_button.anchor_top = 0.5
	cookie_button.anchor_right = 0.5
	cookie_button.anchor_bottom = 0.5
	cookie_button.margin_left = -140
	cookie_button.margin_top = -140
	cookie_button.margin_right = 140
	cookie_button.margin_bottom = 140
	
	if emoji_font:
		cookie_button.add_font_override("font", emoji_font)
	
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.95, 0.75, 0.4)
	normal.border_color = Color(0.4, 0.25, 0.05)
	normal.set_border_width_all(4)
	normal.set_corner_radius_all(140)
	cookie_button.add_stylebox_override("normal", normal)
	
	var hover = normal.duplicate()
	hover.bg_color = Color(1.0, 0.85, 0.5)
	cookie_button.add_stylebox_override("hover", hover)
	
	var pressed = normal.duplicate()
	pressed.bg_color = Color(0.85, 0.65, 0.3)
	cookie_button.add_stylebox_override("pressed", pressed)
	
	cookie_button.connect("pressed", self, "_on_cookie_pressed")
	add_child(cookie_button)


# =============================================
# ЭФФЕКТ КЛИКА
# =============================================
func setup_click_effect():
	click_effect_label = Label.new()
	click_effect_label.visible = false
	click_effect_label.align = Label.ALIGN_CENTER
	click_effect_label.rect_min_size = Vector2(200, 60)
	
	click_effect_label.anchor_left = 0.5
	click_effect_label.anchor_top = 0.5
	click_effect_label.anchor_right = 0.5
	click_effect_label.anchor_bottom = 0.5
	click_effect_label.margin_left = -100
	click_effect_label.margin_top = -200
	click_effect_label.margin_right = 100
	click_effect_label.margin_bottom = -140
	
	var f = DynamicFont.new()
	if main_font and main_font.font_data:
		f.font_data = main_font.font_data
	f.size = 32
	f.use_filter = true
	click_effect_label.add_font_override("font", f)
	click_effect_label.add_color_override("font_color", Color(1, 0.9, 0.4))
	
	add_child(click_effect_label)


func show_click_effect(amount):
	click_effect_label.text = "+" + GameState.fmt(amount) + " 🍪"
	click_effect_label.visible = true
	click_effect_label.modulate = Color(1, 1, 1, 1)
	
	# Останавливаем старый tween
	if click_effect_tween:
		click_effect_tween.stop_all()
		click_effect_tween.queue_free()
		click_effect_tween = null
	
	click_effect_tween = Tween.new()
	add_child(click_effect_tween)
	
	var start_y = -140
	var end_y = -240
	
	click_effect_tween.interpolate_property(
		click_effect_label, "rect_position:y",
		start_y, end_y, 0.8,
		Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	click_effect_tween.interpolate_property(
		click_effect_label, "modulate:a",
		1.0, 0.0, 0.8,
		Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	click_effect_tween.connect("tween_all_completed",
		self, "_on_click_effect_done")
	click_effect_tween.start()


func _on_click_effect_done():
	click_effect_label.visible = false


# =============================================
# АВТО-СОХРАНЕНИЕ
# =============================================
func setup_autosave():
	autosave_timer = Timer.new()
	autosave_timer.wait_time = 10.0
	autosave_timer.autostart = true
	autosave_timer.connect("timeout", self, "_on_autosave")
	add_child(autosave_timer)


func _on_autosave():
	print("[Game] Авто-сохранение...")
	SaveManager.save_game()


# =============================================
# ОБНОВЛЕНИЕ UI
# =============================================
func update_ui():
	update_counters_only()


func update_counters_only():
	if cookies_label:
		cookies_label.text = GameState.fmt(GameState.cookies) + " 🍪"
	if coins_label:
		coins_label.text = GameState.fmt(GameState.coins) + " 🪙"
	if cps_label:
		cps_label.text = GameState.fmt(GameState.cps) + "/сек"
	if clicks_label:
		clicks_label.text = "Кликов: " + GameState.fmt(GameState.clicks)


# =============================================
# КЛИК ПО ПЕЧЕНЬКЕ
# =============================================
func _on_cookie_pressed():
	var gain = GameState.click_cookie()
	show_click_effect(gain)
	update_counters_only()
	animate_cookie_press()


func animate_cookie_press():
	if cookie_button == null:
		return
	
	var tween = Tween.new()
	add_child(tween)
	
	tween.interpolate_property(cookie_button, "modulate",
		Color(1, 1, 1, 1), Color(1.2, 1.1, 0.9, 1), 0.06,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(cookie_button, "modulate",
		Color(1.2, 1.1, 0.9, 1), Color(1, 1, 1, 1), 0.1,
		Tween.TRANS_SINE, Tween.EASE_OUT, 0.06)
	
	tween.connect("tween_all_completed", tween, "queue_free")
	tween.start()


# =============================================
# НАЗАД В МЕНЮ
# =============================================
func _on_back_pressed():
	print("[Game] Сохранение перед выходом...")
	SaveManager.save_game()
	SceneManager.go_to_menu()


# =============================================
# СТИЛИЗАЦИЯ КНОПОК
# =============================================
func style_button(btn: Button, bg_color: Color, border_color: Color, font_size: int = 20):
	var normal = StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.border_color = border_color
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(20)
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	btn.add_stylebox_override("normal", normal)
	
	var hover = normal.duplicate()
	hover.bg_color = bg_color.lightened(0.15)
	btn.add_stylebox_override("hover", hover)
	
	var pressed = normal.duplicate()
	pressed.bg_color = bg_color.darkened(0.15)
	btn.add_stylebox_override("pressed", pressed)
	
	var font = DynamicFont.new()
	if main_font and main_font.font_data:
		font.font_data = main_font.font_data
	font.size = font_size
	font.use_filter = true
	btn.add_font_override("font", font)
	
	btn.add_color_override("font_color", Color(1, 1, 1))
	btn.add_color_override("font_color_hover", Color(1, 1, 1))
	btn.add_color_override("font_color_pressed", Color(1, 1, 1))
