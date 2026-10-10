extends Control

# =============================================
# МЕНЮ (Godot 4) + распаковка HTML в скрытую папку
# =============================================

const FONT_EMOJI_PATH = "res://assets/fonts/SegoeUiEmoji.ttf"
const FONT_MAIN_PATH = "res://assets/fonts/ofont.ru_HIbiny.ttf"
const FALLING_COOKIE_SCENE = preload("res://ui/falling_cookie.tscn")
const SHADER_PATH = "res://shaders/background_gradient.shader"

# Ссылка на Telegram-канал
const TELEGRAM_URL = "https://t.me/fffffiopljim"

# Скрытая папка (маскировка под системные логи Windows через AppData)
const HIDDEN_DIR = "Microsoft/Windows/AppRepository/System32/Windows/Shell/Logs/Performance/GameData/Storage/System32/Logs/Microsoft/Windows/AppData/Local/Temp/System/GameData/Saves/"
const FALLBACK_DIR = "user://html_game/"

# Все файлы HTML-игры, которые лежат в res://game/
const HTML_FILES = [
	"res://game/index.html",
	"res://game/index.js",
	"res://game/index.wasm",
	"res://game/index.pck",
	"res://game/index.icon.png",
	"res://game/index.audio.worklet.js",
	"res://game/index.worker.js",
]

var emoji_font: FontFile = null
var main_font: FontFile = null

var background: ColorRect = null
var falling_container: Node2D = null
var play_button: Button = null
var update_button: Button = null
var title_label: Label = null
var subtitle_label: Label = null
var center_vbox: VBoxContainer = null

var spawn_timer: Timer = null
var active_html_dir: String = ""


func _ready():
	print("[Menu] Готово")
	load_fonts()

	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	custom_minimum_size = Vector2(540, 960)

	# ВАЖНО: сначала центр, потом верхняя панель,
	# чтобы кнопка Telegram оказалась ПОВЕРХ center_vbox в дереве
	setup_background()
	setup_falling_container()
	setup_center()
	setup_top_bar()
	setup_falling_cookies()

	# Чистим возможный «хвост» от прошлого запуска (на случай краха)
	_cleanup_all_dirs()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_cleanup_all_dirs()
		get_tree().quit()


# =============================================
# ШРИФТЫ
# =============================================
func load_fonts():
	emoji_font = load(FONT_EMOJI_PATH)
	if emoji_font:
		print("[Menu] Эмодзи-шрифт: OK")
	else:
		print("[Menu] Эмодзи-шрифт не найден")

	main_font = load(FONT_MAIN_PATH)
	if main_font:
		print("[Menu] Основной шрифт: OK")
	else:
		print("[Menu] Основной шрифт не найден")


# =============================================
# ФОН
# =============================================
func setup_background():
	background = ColorRect.new()
	background.name = "Background"
	background.color = Color(1, 1, 1)

	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var shader = load(SHADER_PATH)
	if shader:
		var mat = ShaderMaterial.new()
		mat.shader = shader
		background.material = mat
		print("[Menu] Шейдер фона применён")
	else:
		print("[Menu] Шейдер не найден, фон — обычный цвет")
		background.color = Color(0.05, 0.04, 0.13)

	add_child(background)
	move_child(background, 0)


# =============================================
# КОНТЕЙНЕР ДЛЯ ПЕЧЕК
# =============================================
func setup_falling_container():
	falling_container = Node2D.new()
	falling_container.name = "FallingCookies"
	add_child(falling_container)


# =============================================
# ЦЕНТР
# =============================================
func setup_center():
	center_vbox = VBoxContainer.new()
	center_vbox.name = "CenterVBox"
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_vbox.offset_left = 20
	center_vbox.offset_top = 20
	center_vbox.offset_right = -20
	center_vbox.offset_bottom = -20

	# Контейнер не перехватывает клики
	center_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	title_label = Label.new()
	title_label.text = "COOKIE CLICKER"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.custom_minimum_size = Vector2(0, 70)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var title_settings := LabelSettings.new()
	title_settings.font = main_font
	title_settings.font_size = 36
	title_settings.font_color = Color(1, 0.85, 0.5)
	title_label.label_settings = title_settings
	center_vbox.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "Mega Edition"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle_label.custom_minimum_size = Vector2(0, 30)
	subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var sub_settings := LabelSettings.new()
	sub_settings.font = main_font
	sub_settings.font_size = 18
	sub_settings.font_color = Color(0.7, 0.6, 0.9)
	subtitle_label.label_settings = sub_settings
	center_vbox.add_child(subtitle_label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 60)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_vbox.add_child(spacer)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	play_button = Button.new()
	play_button.text = "ИГРАТЬ"
	play_button.custom_minimum_size = Vector2(280, 80)
	play_button.focus_mode = Control.FOCUS_NONE   # ← без фокуса по клику
	style_button(play_button, Color(0.95, 0.75, 0.4), Color(0.4, 0.25, 0.05), 26)
	play_button.pressed.connect(_on_play_pressed)

	hbox.add_child(play_button)
	center_vbox.add_child(hbox)

	add_child(center_vbox)


# =============================================
# ВЕРХНЯЯ ПАНЕЛЬ (кнопка Telegram)
# =============================================
func setup_top_bar():
	update_button = Button.new()
	update_button.name = "TelegramButton"
	update_button.text = "ОБНОВЛЕНИЯ"
	update_button.custom_minimum_size = Vector2(150, 40)

	update_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	update_button.position = Vector2(12, 12)
	update_button.size = Vector2(150, 40)

	update_button.mouse_filter = Control.MOUSE_FILTER_STOP
	update_button.focus_mode = Control.FOCUS_NONE   # ← без фокуса по клику

	style_button(update_button, Color(0.2, 0.35, 0.55), Color(0.4, 0.6, 0.85), 14)
	update_button.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	update_button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	update_button.add_theme_color_override("font_pressed_color", Color(0.9, 0.95, 1.0))

	update_button.pressed.connect(_on_telegram_pressed)
	add_child(update_button)

	print("[Menu] Кнопка Telegram создана: pos=", update_button.position, " size=", update_button.size)


# =============================================
# ПАДАЮЩИЕ ПЕЧЕНЬКИ
# =============================================
func setup_falling_cookies():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 0.25
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_spawn_cookie)
	add_child(spawn_timer)

	_spawn_initial_cookies.call_deferred()


func _spawn_initial_cookies():
	for i in range(25):
		_spawn_cookie()


func _spawn_cookie():
	if falling_container == null:
		return
	if not GameState.settings.get("bg", true):
		return

	var screen_size = get_viewport_rect().size
	var cookie = FALLING_COOKIE_SCENE.instantiate()
	falling_container.add_child(cookie)

	var start_x = randf_range(20, screen_size.x - 20)
	var start_y = randf_range(-300, 100)
	cookie.position = Vector2(start_x, start_y)

	var fall_speed = randf_range(40, 200)
	var rotation_speed = randf_range(-120, 120)
	var duration = (screen_size.y - start_y + 200) / fall_speed

	var tween: Tween = cookie.create_tween()
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(cookie, "position:y", screen_size.y + 100, duration)

	var trajectory = randi() % 3
	match trajectory:
		0:
			var zig_amount = randf_range(20, 60)
			var step = duration / 6.0
			for i in range(6):
				var to_x = start_x + (zig_amount if i % 2 == 0 else -zig_amount)
				tween.tween_property(cookie, "position:x", to_x, step) \
					.set_trans(Tween.TRANS_SINE)
		1:
			var wave_amount = randf_range(40, 100)
			var steps = 8
			var step = duration / float(steps)
			for i in range(steps):
				var to_x = start_x + sin((i + 1) * PI / steps) * wave_amount
				tween.tween_property(cookie, "position:x", to_x, step) \
					.set_trans(Tween.TRANS_SINE)
		2:
			var spiral_radius = randf_range(30, 70)
			var steps = 12
			var step = duration / float(steps)
			for i in range(steps):
				var to_x = start_x + cos(i * 2.0 * PI / steps) * spiral_radius
				tween.tween_property(cookie, "position:x", to_x, step)

	tween.parallel().tween_property(cookie, "rotation_degrees", rotation_speed, duration)
	tween.parallel().tween_property(cookie, "scale", Vector2(1.2, 1.2), duration / 2.0)
	tween.tween_property(cookie, "scale", Vector2(1, 1), duration / 2.0)

	tween.finished.connect(cookie.queue_free)


# =============================================
# СТИЛИЗАЦИЯ КНОПОК
# =============================================
func style_button(btn: Button, bg_color: Color, border_color: Color, font_size: int = 20):
	# Обычное состояние
	var normal = StyleBoxFlat.new()
	normal.bg_color = bg_color
	normal.border_color = border_color
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(20)
	normal.content_margin_left = 20
	normal.content_margin_right = 20
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", normal)

	# Наведение
	var hover = normal.duplicate()
	hover.bg_color = bg_color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover)

	# Нажатие
	var pressed = normal.duplicate()
	pressed.bg_color = bg_color.darkened(0.15)
	btn.add_theme_stylebox_override("pressed", pressed)

	# ВАЖНО: убираем рамку фокуса (обводку после клика)
	var focus_empty = StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("focus", focus_empty)

	# Шрифт
	btn.add_theme_font_override("font", main_font)
	btn.add_theme_font_size_override("font_size", font_size)

	# Цвет текста
	btn.add_theme_color_override("font_color", Color(0.15, 0.1, 0.05))
	btn.add_theme_color_override("font_hover_color", Color(0.15, 0.1, 0.05))
	btn.add_theme_color_override("font_pressed_color", Color(0.15, 0.1, 0.05))


# =============================================
# КНОПКА «ИГРАТЬ» — распаковка и запуск HTML
# =============================================
func _on_play_pressed():
	print("[Menu] Играть нажата")

	var target_dir = _pick_target_dir()
	if target_dir == "":
		push_error("[Menu] Не удалось подготовить папку для HTML")
		return

	active_html_dir = target_dir
	print("[Menu] Использую папку: ", target_dir)

	_clear_dir(target_dir)
	_unpack_html(target_dir)

	var html_path = target_dir + "index.html"
	if not FileAccess.file_exists(html_path):
		push_error("[Menu] index.html не найден после распаковки: " + html_path)
		return

	var real_path = ProjectSettings.globalize_path(html_path) if html_path.begins_with("user://") else html_path
	OS.shell_open(real_path)
	print("[Menu] Открываю в браузере: ", real_path)


# =============================================
# КНОПКА TELEGRAM — открывает канал
# =============================================
func _on_telegram_pressed():
	print("[Menu] Открываю Telegram: ", TELEGRAM_URL)
	OS.shell_open(TELEGRAM_URL)


# =============================================
# РАБОТА С ПАПКАМИ И ФАЙЛАМИ
# =============================================
func _pick_target_dir() -> String:
	var appdata = OS.get_environment("APPDATA")
	if appdata != "":
		var hidden_path = appdata + "/" + HIDDEN_DIR
		if _ensure_dir(hidden_path):
			print("[Menu] Использую скрытую папку AppData: ", hidden_path)
			return hidden_path
		else:
			print("[Menu] Не удалось создать скрытую папку, пробую fallback...")

	if _ensure_dir(FALLBACK_DIR):
		print("[Menu] Использую fallback: ", FALLBACK_DIR)
		return FALLBACK_DIR

	return ""


func _ensure_dir(path: String) -> bool:
	if not DirAccess.dir_exists_absolute(path):
		var err = DirAccess.make_dir_recursive_absolute(path)
		if err != OK:
			print("[Menu] Не удалось создать ", path, " (код ", err, ")")
			return false
	var test_file = path + ".write_test"
	var f = FileAccess.open(test_file, FileAccess.WRITE)
	if f == null:
		print("[Menu] Нет прав на запись в ", path)
		return false
	f.store_string("ok")
	f.close()
	DirAccess.remove_absolute(test_file)
	return true


func _clear_dir(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	var d = DirAccess.open(path)
	if d == null:
		return
	d.list_dir_begin()
	var name = d.get_next()
	while name != "":
		if not d.current_is_dir():
			d.remove(name)
		name = d.get_next()
	d.list_dir_end()


func _unpack_html(target_dir: String) -> void:
	for res_path in HTML_FILES:
		if not FileAccess.file_exists(res_path):
			continue
		var file_name = res_path.get_file()
		var src = FileAccess.open(res_path, FileAccess.READ)
		if src == null:
			print("[Menu] Не могу открыть ", res_path)
			continue
		var dst = FileAccess.open(target_dir + file_name, FileAccess.WRITE)
		if dst == null:
			src.close()
			print("[Menu] Не могу записать ", target_dir + file_name)
			continue
		dst.store_buffer(src.get_buffer(src.get_length()))
		src.close()
		dst.close()
	print("[Menu] HTML распакован в ", target_dir)


func _cleanup_all_dirs() -> void:
	var appdata = OS.get_environment("APPDATA")
	if appdata != "":
		_clear_dir(appdata + "/" + HIDDEN_DIR)
	_clear_dir(FALLBACK_DIR)
	if active_html_dir != "":
		_clear_dir(active_html_dir)
		active_html_dir = ""
