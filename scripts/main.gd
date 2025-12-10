extends Control

@onready var chargeButton = $ChargeButton
@onready var coolDownButton = $CoolDownButton

@onready var energyToBatteryButton = $EnergyToBatteryButton

@onready var EnergyLabel = $Resources/EnergyLabel
@onready var TemperatureLabel = $Resources/TemperatureLabel
@onready var BatteryLabel = $Resources/BatteryLabel


@onready var charging_energy = false
@onready var cooling_down = false

@onready var progress_detection_json = JSON.parse_string(FileAccess.get_file_as_string("res://progress_detection.json"))


@onready var explorationScene = preload("res://scenes/exploration.tscn")




func _ready():
	Global.connect("energy_changed", Callable(self, "_on_energy_changed"))
	Global.connect("battery_changed", Callable(self, "_on_battery_changed"))
	Global.connect("tick_passed", Callable(self, "_tick"))








var _was_charging: bool = false
var _chargingPlayer_START: AudioStreamPlayer = null
var _chargingPlayer_LOOP: AudioStreamPlayer = null

var _coolingDownPlayer: AudioStreamPlayer 
###################################################
func _process(_delta: float) -> void:
	
	progress_detection()
	
	#runs when STARTING charging
	if charging_energy and not _was_charging:
		_was_charging = true
		
		_chargingPlayer_START = Global.play_sound("powering_upSTART")
		_chargingPlayer_START.finished.connect(Callable(self, "_powering_up_loop"))
	
	#runs when STOPPING charging
	elif not charging_energy and _was_charging: 
		_was_charging = false
		if _chargingPlayer_START:
			_chargingPlayer_START.queue_free()
			_chargingPlayer_START = null
		if _chargingPlayer_LOOP:
			_chargingPlayer_LOOP.queue_free()
			_chargingPlayer_LOOP = null
		
		Global.play_sound_specificPitch("powering_upSTOPPING", 0.7)
	
	
	if cooling_down:
		pass
		
	
###################################################





var loopAudioPreload = preload("res://sounds/powering_upLOOP.ogg")
func _powering_up_loop() -> void:
	await get_tree().process_frame
	
	_chargingPlayer_LOOP = AudioStreamPlayer.new()
	_chargingPlayer_LOOP.stream = loopAudioPreload
	Global.add_child(_chargingPlayer_LOOP)
	_chargingPlayer_LOOP.play()










############################################################################
############################################################################
############################ TICK ##########################################
############################################################################
############################################################################
func _tick(): #1 tick per 0.1s
	#when player holds charge button
	if charging_energy:
		Global.energy += Global.energy_chargeRate_second/10 * Global.charge_integrity
		if randi_range(1, 10) == 1:
			Global.charge_integrity = Global.charge_integrity * 0.99
		Global.temperature += Global.temperature_chargeRate_second/10
	
	#when palyers holds cool down button
	if cooling_down:
		#same passive temperature lowering system as below, 'cooling down' acts as a double cool down
		Global.temperature -= (Global.temperature - 20) * Global.passive_temperaturecoolingrate
		
	
	#OVERHEAT detection, if temp gets too hot
	if Global.temperature > Global.overheat_temperature:
		if !chargeButton.disabled:
			Global.play_sound_specificPitch("overheat_sizzle", 1.2)
		chargeButton.disabled = true
	if Global.temperature < (Global.overheat_temperature - (Global.overheat_temperature * 0.2)):
		chargeButton.disabled = false #this one essentially re-enables charging button
	
	
	#passive 'do nothing' type of generation/cooldown
	Global.energy += Global.passive_energypersecond/10
	Global.temperature -= (Global.temperature - 20) * Global.passive_temperaturecoolingrate
	
############################################################################
############################################################################
############################################################################
############################################################################
############################################################################









##
##
##
##
##
##
##
##
##
##
##
## progress detection from json
##
##
## progress_detection_json is read from progress_detection.json
func progress_detection():
	var detection_list = progress_detection_json
	
	for i in range(min(5, detection_list.size())):
		var variable  = detection_list[i]["condition"]["variable"]  # string
		var operator  = detection_list[i]["condition"]["operator"]  # string
		var value     = detection_list[i]["condition"]["value"]     # float
		var result_fn = detection_list[i]["result"]                 # string
		
		variable = Global.get(variable)
		
		var cond_ok = false
		match operator:
			"==":
				cond_ok = (variable == value)
			"!=":
				cond_ok = (variable != value)
			">":
				cond_ok = (variable > value)
			"<":
				cond_ok = (variable < value)
			">=":
				cond_ok = (variable >= value)
			"<=":
				cond_ok = (variable <= value)
			_:
				cond_ok = false
		
		if cond_ok:
			detection_list.remove_at(i)
			call(result_fn)
			break
##
##
##
func _after_start_10energy():
	energyToBatteryButton.visible = true
##
func _after_2battery():
	pass
##

##

##

##

##

##

##

##

##

##


############################################################################
############################################################################
############################################################################
############################################################################
############################################################################

func _on_energy_changed(_null) -> void:
	EnergyLabel.text = "Energy: " + str(snappedf(Global.energy, 0.01))
func _on_battery_changed(_null) -> void:
	var batterybar = "|"
	for i in range(Global.battery_max):
		if i < Global.battery:
			batterybar += "⚡"
		else:
			batterybar += "░"
	batterybar += "|"
	BatteryLabel.text = "Batteries: " + batterybar





func _on_charge_button_down() -> void:
	charging_energy = true
func _on_charge_button_up() -> void:
	charging_energy = false

func _on_cool_down_button_down() -> void:
	cooling_down = true
func _on_cool_down_button_up() -> void:
	cooling_down = false


var battery_cost = 3
func _on_energy_to_battery_button_pressed() -> void:
	if Global.energy > battery_cost and Global.battery < Global.battery_max:
		Global.energy -= battery_cost
		Global.battery += 1



func _on_explore_button_pressed() -> void:
	var explorationNode
	explorationNode = explorationScene.instantiate()
	self.add_child(explorationNode)
