extends SpotLight3D

@export var actuation_percentage: float = 0.8

func execute(_percentage: float) -> void:
	# or just use this if you want to change the intensity of the light, make sure the light is visible
	# light_energy = (_percentage*100.0)
	if _percentage < actuation_percentage:
		visible = false 
	else: 
		visible = true  
