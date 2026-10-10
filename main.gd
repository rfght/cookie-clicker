extends Control

func _ready():
	print("=====================================")
	print("[Main] Старт теста WebView")
	print("=====================================")
	
	# ★ Создаём WebView через код
	print("[1] Создаю WebView...")
	var webview = WebView.new()
	
	if webview == null:
		print("[ERROR] WebView.new() вернул null")
		return
	
	print("[OK] WebView создан")
	print("[2] Растягиваю на весь экран...")
	
	webview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	print("[3] Добавляю в сцену...")
	add_child(webview)
	print("[OK] WebView добавлен")
	
	print("[4] Проверяю файл...")
	var html_path = "res://game/index.html"
	if FileAccess.file_exists(html_path):
		print("[OK] Файл найден: ", html_path)
	else:
		print("[WARN] Файл не найден: ", html_path)
	
	print("[5] Методы WebView:")
	for m in webview.get_method_list():
		print("  - ", m.name)
	
	print("=====================================")
	print("[Main] Готово")
	print("=====================================")
