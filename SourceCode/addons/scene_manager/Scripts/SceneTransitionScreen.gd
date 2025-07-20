class_name SceneTransitionScreen
extends CanvasLayer

signal transition_in_complete

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var timer: Timer = $Timer

var starting_animation_name: String

func _ready() -> void:
	progress_bar.visible = false;

# Called by SceneManager
func start_transition(animation_name_p: String) -> void:
	if !anim_player.has_animation(animation_name_p):
		push_warning("'%s' animation does not exist" % animation_name_p)
		animation_name_p = "fade_to_black"
	starting_animation_name = animation_name_p
	anim_player.play(animation_name_p)
	
	# Show the progress bar if animation finishes before loading.
	timer.start()

# Called by SceneManager
func finish_transition() -> void:
	if timer:
		timer.stop()
	
	# Create second half animation name.
	var ending_animation_name: String = starting_animation_name.replace("to", "from")
	
	if !anim_player.has_animation(ending_animation_name):
		push_warning("'%s' animation does not exist" % ending_animation_name)
		ending_animation_name = "fade_from_black"
	anim_player.play(ending_animation_name) 
	
	# Wait for final animation to play before we free this scene.
	await anim_player.animation_finished
	queue_free()

func report_midpoint() -> void:
	transition_in_complete.emit()

func update_bar(progress_p: float) -> void:
	progress_bar.value = progress_p

func _on_timer_timeout() -> void:
	progress_bar.visible = true;
