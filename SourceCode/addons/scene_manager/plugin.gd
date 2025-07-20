@tool
extends EditorPlugin

const AUTOLOAD_NAME = "SceneManager"

func _enable_plugin():
	# Register the plugin as an auto load script.
	add_autoload_singleton(AUTOLOAD_NAME, "res://addons/scene_manager/Scripts/SceneManager.gd")

func _disable_plugin():
	# Remove the plugin from auto loading.
	remove_autoload_singleton(AUTOLOAD_NAME)

func _enter_tree():
	# Initialization of the plugin goes here.
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
