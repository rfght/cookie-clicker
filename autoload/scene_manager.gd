extends Node

# =============================================
# МЕНЕДЖЕР СЦЕН (переключение экранов)
# =============================================
# Доступ: SceneManager.go_to_game() и т.д.

const MENU_SCENE = "res://screens/menu/menu.tscn"
const GAME_SCENE = "res://screens/game/game.tscn"


func go_to_menu():
	print("[SceneManager] → Меню")
	get_tree().change_scene(MENU_SCENE)


func go_to_game():
	print("[SceneManager] → Игра")
	get_tree().change_scene(GAME_SCENE)
