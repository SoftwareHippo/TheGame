extends Node

signal finished_loading_scene
signal content_finished_loading(content_p)
signal content_invalid(content_path_p: String)
signal content_failed_to_load(cintent_path_p: String)

var loading_screen: SceneTransitionScreen
var _loading_screen_scene: PackedScene = preload("res://addons/scene_manager/Scenes/SceneTransitionScreen.tscn")
var _transition: String
var _content_path: String
var _load_progress_timer: Timer

var is_host: bool

func _ready() -> void:
	self.connect("content_finished_loading", on_content_finished_loading)
	self.connect("content_invalid", on_content_invalid)
	self.connect("content_failed_to_load", on_content_failed_to_load)

func load_new_scene(content_path_p: String, transition_type_p: String="fade_to_black") -> void:
	_transition = transition_type_p
	
	# Add a SceneTransitionScreen
	loading_screen = _loading_screen_scene.instantiate() as SceneTransitionScreen
	get_tree().root.add_child(loading_screen)
	loading_screen.start_transition(transition_type_p)
	_load_content(content_path_p)

func _load_content(content_path_p: String) -> void:
	if loading_screen != null:
		await loading_screen.transition_in_complete
	
	_content_path = content_path_p
	var loader = ResourceLoader.load_threaded_request(content_path_p)
	if not ResourceLoader.exists(content_path_p) or loader == null:
		content_invalid.emit(content_path_p)
		return
	
	_load_progress_timer = Timer.new()
	_load_progress_timer.wait_time = 0.1
	_load_progress_timer.timeout.connect(monitor_load_status)
	get_tree().root.add_child(_load_progress_timer)
	_load_progress_timer.start()

func monitor_load_status() -> void:
	var load_progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_content_path, load_progress)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			content_invalid.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if loading_screen != null:
				loading_screen.update_bar(load_progress[0] * 100)
		ResourceLoader.THREAD_LOAD_FAILED:
			content_failed_to_load.emit(_content_path)
			_load_progress_timer.stop()
			return
		ResourceLoader.THREAD_LOAD_LOADED:
			_load_progress_timer.stop()
			_load_progress_timer.queue_free()
			
			content_finished_loading.emit(ResourceLoader.load_threaded_get(_content_path).instantiate())
			return

func on_content_failed_to_load(path_p: String) -> void:
	printerr("error: Failed to load resource '%s'" % [path_p])

func on_content_invalid(path_p: String) -> void:
	printerr("error: Cannot load resource: '%s'" % [path_p])

func on_content_finished_loading(content_p) -> void:
	var outgoing_scene = get_tree().current_scene
	
	# Pass LevelDataHandoff if moving between levels.
	
	# remove the old scene.
	outgoing_scene.queue_free()
	
	# Add and set the new scene to current
	get_tree().root.call_deferred("add_child", content_p)
	get_tree().set_deferred("current_scene", content_p)
	
	if loading_screen != null:
		loading_screen.finish_transition()
		
		# Wait for SceneTransitionScreen's transition to finsh playing
		await loading_screen.anim_player.animation_finished
		loading_screen = null
		
		# Finished loading the new scene.
		emit_signal("finished_loading_scene")
