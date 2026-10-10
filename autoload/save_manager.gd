extends Node

# =============================================
# МЕНЕДЖЕР СОХРАНЕНИЙ
# =============================================
# Доступ: SaveManager.save_game(), SaveManager.load_game()

const SAVE_PATH = "user://save.cfg"


func save_game():
	var cfg = ConfigFile.new()
	
	# === Основные ресурсы ===
	cfg.set_value("resources", "cookies", GameState.cookies)
	cfg.set_value("resources", "total_cookies", GameState.total_cookies)
	cfg.set_value("resources", "coins", GameState.coins)
	cfg.set_value("resources", "clicks", GameState.clicks)
	cfg.set_value("resources", "click_power", GameState.click_power)
	cfg.set_value("resources", "cps", GameState.cps)
	
	# === Деньги ===
	cfg.set_value("money", "money", GameState.money)
	cfg.set_value("money", "total_money", GameState.total_money)
	cfg.set_value("money", "money_clicks", GameState.money_clicks)
	cfg.set_value("money", "money_click_power", GameState.money_click_power)
	cfg.set_value("money", "money_cps", GameState.money_cps)
	
	# === Уровень ===
	cfg.set_value("level", "player_level", GameState.player_level)
	cfg.set_value("level", "player_xp", GameState.player_xp)
	
	# === Скины ===
	cfg.set_value("skins", "active_skin", GameState.active_skin)
	cfg.set_value("skins", "owned_skins", GameState.owned_skins)
	
	# === Апгрейды ===
	cfg.set_value("upgrades", "cookies", GameState.upgrades)
	cfg.set_value("upgrades", "money", GameState.money_upgrades)
	
	# === Настройки ===
	cfg.set_value("settings", "data", GameState.settings)
	
	# === Ачивки ===
	cfg.set_value("achievements", "list", GameState.achievements)
	
	var err = cfg.save(SAVE_PATH)
	if err == OK:
		print("[SaveManager] Сохранено: ", SAVE_PATH)
	else:
		print("[SaveManager] Ошибка сохранения: ", err)


func load_game():
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	
	if err != OK:
		print("[SaveManager] Сохранение не найдено — новый старт")
		return false
	
	# === Ресурсы ===
	GameState.cookies = cfg.get_value("resources", "cookies", 0)
	GameState.total_cookies = cfg.get_value("resources", "total_cookies", 0)
	GameState.coins = cfg.get_value("resources", "coins", 0)
	GameState.clicks = cfg.get_value("resources", "clicks", 0)
	GameState.click_power = cfg.get_value("resources", "click_power", 1)
	GameState.cps = cfg.get_value("resources", "cps", 0)
	
	# === Деньги ===
	GameState.money = cfg.get_value("money", "money", 0)
	GameState.total_money = cfg.get_value("money", "total_money", 0)
	GameState.money_clicks = cfg.get_value("money", "money_clicks", 0)
	GameState.money_click_power = cfg.get_value("money", "money_click_power", 1)
	GameState.money_cps = cfg.get_value("money", "money_cps", 0)
	
	# === Уровень ===
	GameState.player_level = cfg.get_value("level", "player_level", 1)
	GameState.player_xp = cfg.get_value("level", "player_xp", 0)
	
	# === Скины ===
	GameState.active_skin = cfg.get_value("skins", "active_skin", 0)
	GameState.owned_skins = cfg.get_value("skins", "owned_skins", [0])
	
	# === Апгрейды ===
	var saved_upg = cfg.get_value("upgrades", "cookies", [])
	if saved_upg is Array and saved_upg.size() > 0:
		GameState.upgrades = saved_upg
	var saved_mupg = cfg.get_value("upgrades", "money", [])
	if saved_mupg is Array and saved_mupg.size() > 0:
		GameState.money_upgrades = saved_mupg
	
	# === Настройки ===
	var saved_settings = cfg.get_value("settings", "data", null)
	if saved_settings is Dictionary:
		GameState.settings = saved_settings
	
	# === Ачивки ===
	var saved_ach = cfg.get_value("achievements", "list", [])
	if saved_ach is Array:
		GameState.achievements = saved_ach
	
	print("[SaveManager] Загружено: cookies=", GameState.cookies,
		", coins=", GameState.coins,
		", level=", GameState.player_level)
	return true


func has_save() -> bool:
	var file = File.new()
	return file.file_exists(SAVE_PATH)


func delete_save():
	var dir = Directory.new()
	if dir.file_exists(SAVE_PATH):
		dir.remove(SAVE_PATH)
		print("[SaveManager] Сохранение удалено")
