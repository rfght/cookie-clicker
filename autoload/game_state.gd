extends Node

# =============================================
# ИГРОВОЕ СОСТОЯНИЕ (печеньки, монеты, апгрейды)
# =============================================
# Доступ: GameState.cookies, GameState.coins, и т.д.
# Из любой сцены!

var cookies: int = 0
var total_cookies: int = 0
var coins: int = 0
var clicks: int = 0
var click_power: int = 1
var cps: int = 0

var player_level: int = 1
var player_xp: int = 0

var money: int = 0
var total_money: int = 0
var money_clicks: int = 0
var money_click_power: int = 1
var money_cps: int = 0

# Скины
var active_skin: int = 0
var owned_skins: Array = [0]

# Апгрейды
var upgrades: Array = []
var money_upgrades: Array = []

# Достижения
var achievements: Array = []

# Настройки
var settings: Dictionary = {
	"numbers": true,
	"crumbs": true,
	"bg": true,
	"sound": true,
	"vibration": true,
	"bot_speed": 1.0,
	"click_vol": 60,
	"music_vol": 80,
	"music_track": 0
}


func _ready():
	print("[GameState] Инициализация")
	init_upgrades()
	init_money_upgrades()


func init_upgrades():
	upgrades = [
		{"id": 0, "name": "Сила клика +1", "base": 15, "count": 0, "type": "click", "val": 1},
		{"id": 1, "name": "Помощник пекаря", "base": 50, "count": 0, "type": "cps", "val": 1},
		{"id": 2, "name": "Бабушка", "base": 200, "count": 0, "type": "cps", "val": 5},
		{"id": 3, "name": "Ферма", "base": 500, "count": 0, "type": "cps", "val": 20},
		{"id": 4, "name": "Пекарня", "base": 2000, "count": 0, "type": "cps", "val": 80},
		# ... добавим все 15 позже
	]


func init_money_upgrades():
	money_upgrades = [
		{"id": 0, "name": "Сила клика +1", "base": 50, "count": 0, "type": "mclick", "val": 1},
		{"id": 1, "name": "Кассовый аппарат", "base": 200, "count": 0, "type": "mcps", "val": 5},
		# ... добавим позже
	]


# =============================================
# КЛИК ПО ПЕЧЕНЬКЕ
# =============================================
func click_cookie():
	var gain = click_power
	cookies += gain
	total_cookies += gain
	coins += 1
	clicks += 1
	player_xp += 1
	check_level()
	return gain


func click_money():
	var gain = money_click_power
	money += gain
	total_money += gain
	money_clicks += 1
	return gain


# =============================================
# АВТО-ПЕЧЕНЬКИ (вызывается из _process)
# =============================================
func tick(delta: float):
	if cps > 0:
		var auto = cps * delta
		cookies += auto
		total_cookies += auto
	
	if money_cps > 0:
		money += money_cps * delta
		total_money += money_cps * delta


# =============================================
# УРОВНИ
# =============================================
func xp_for_level(lvl: int) -> int:
	return int(floor(100 * pow(1.08, lvl - 1)))


func check_level():
	if player_level >= 1000:
		return
	var needed = xp_for_level(player_level)
	while player_xp >= needed and player_level < 1000:
		player_xp -= needed
		player_level += 1
		needed = xp_for_level(player_level)
		# TODO: показать попап "Уровень N"


# =============================================
# ФОРМАТИРОВАНИЕ ЧИСЕЛ (1234 → 1.2K)
# =============================================
func fmt(n: float) -> String:
	if n < 1000:
		return str(int(n))
	if n < 1e6:
		return "%.1fK" % (n / 1e3)
	if n < 1e9:
		return "%.1fM" % (n / 1e6)
	if n < 1e12:
		return "%.1fB" % (n / 1e9)
	return "%.1fT" % (n / 1e12)
