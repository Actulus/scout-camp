extends Node

func advance_day():
	GameManager.advance_day()
	_play_transition()
	
func _play_transition():
	# For now just print 
	print("--- Nigh Falls. Day ", GameManager.current_day, " begins ---")
