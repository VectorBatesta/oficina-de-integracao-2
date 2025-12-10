extends RichTextLabel


var MAX_TEMP := Global.overheat_temperature
var BAR_LENGTH: int = -1




func _ready() -> void:
	self.bbcode_enabled = true
	Global.connect("temperature_changed", Callable(self, "_on_temperature_changed"))
	Global.connect("overheatTemp_changed", Callable(self, "_on_overheat_changed"))
	
	_on_temperature_changed(Global.temperature)
	_on_overheat_changed(Global.overheat_temperature)




func _on_overheat_changed(newoverheat_temp) -> void:
	BAR_LENGTH = newoverheat_temp / 10



func _on_temperature_changed(temperature: float) -> void:
	var percentageTemp: float = temperature / Global.overheat_temperature
	var filled := int(round(percentageTemp * BAR_LENGTH))
	var empty := BAR_LENGTH - filled
	
	#texto vai ficar assim [███░░░░░]
	var bar := "["
	for i in range(filled):
		bar += "█"
	for i in range(empty):
		bar += "░"
	bar += "]"
	
	#color buckets pra diferentes thresholds de temp
	var color := "#2B8CFF"    # cold/readable blue
	if percentageTemp >= 0.8:
		color = "#FF3B3B"    # hot -> red
	elif percentageTemp >= 0.4:
		color = "#FFC34D"    # warm -> orange
	
	#texto final
	self.bbcode_text = "[color=%s]%s %d °C[/color]" % [color, bar, temperature]
