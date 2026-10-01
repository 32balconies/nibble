extends ProgressBar

@export var duration: float = 2.0
var target: float = 100.0
var tween: Tween

func start_charge():
	if not visible:
		target = 100
		visible = true
		update_charge()

func update_charge():
	if tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "value", target, duration)
	tween.finished.connect(_on_tween_finished)
	
func get_charge():
	if tween:
		tween.kill()
		tween = null		
	return value
	
func reset_charge():
	value = 0
	visible = false
	
func _on_tween_finished() -> void:
	match value:
		100.0: target = 0.0
		0.0: target = 100.0
	print("%s reached! Setting target to %s" % [value, target])
	update_charge()
