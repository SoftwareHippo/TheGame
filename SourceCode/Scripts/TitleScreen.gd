extends Control

@export var GameSceneToLoad : PackedScene;

func _on_start_game_button_pressed():
	print("Start the game already!")
	
	# Load the specified game scene.
	if GameSceneToLoad:
		SceneManager.load_new_scene(GameSceneToLoad.resource_path, "fade_to_black")

func _on_exit_game_button_pressed():
	# Exit Game
	get_tree().quit()
