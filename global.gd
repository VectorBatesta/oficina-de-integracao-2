extends Node

############################## signals
signal energy_changed(energy)
signal battery_changed(battery)

signal temperature_changed(temperature)

signal overheatTemp_changed(overheat_temperature)




signal tick_passed()
##############################

const SAVE_LOCATION = "user://savegame.save"





var is_new_game: bool = true
############################################################
####### game variables #####################################
############################################################
@export var energy: float = 0.0:
	set(value):
		energy = value
		energy = clamp(energy, 0, energy_max)
		emit_signal("energy_changed", value)
@export var energy_max: float = 100.0

@export var battery: int = 0:
	set(value):
		battery = value
		#battery = clamp(battery, 0, battery_max)
		emit_signal("battery_changed", value)
@export var battery_max: int = 3



@export var temperature: float = 20:
	set(value):
		temperature = value
		emit_signal("temperature_changed", value)
@export var overheat_temperature: float = 80:
	set(value):
		overheat_temperature = value
		emit_signal("overheatTemp_changed", value)

@export var passive_energypersecond: float = 0.0
@export var passive_temperaturecoolingpersecond: float = 5
@export var passive_temperaturecoolingrate: float = .001

@export var energy_chargeRate_second: float = 1
@export var temperature_chargeRate_second: float = 20

@export var charge_integrity: float = 1
@export var max_charge_integrity: float = 1
############################################################
############################################################
############################################################

const DEFAULTS := {
	"energy_max": 100.0,
	"energy": 0.0,
	
	"temperature": 20,
	"overheat_temperature": 80,
	
	"passive_energypersecond": 0.0,
	"passive_temperaturecoolingpersecond": 5,
	"passive_temperaturecoolingrate": .001,
	
	"energy_chargeRate_second": 1,
	"temperature_chargeRate_second": 20
}

func reset():
	for key in DEFAULTS:
		#key is the name of the global variables
		#the other is the value from DEFAULTS
		set(key, DEFAULTS[key])

################################







func _ready():
	var t = Timer.new()
	t.wait_time = 0.1
	t.one_shot = false
	add_child(t)
	t.start()
	t.timeout.connect(tick_passed.emit)
	
	
	if FileAccess.file_exists(SAVE_LOCATION) == true:
		loadgame()
		pass
	
	if is_new_game == true:
		is_new_game = false
		self.reset()





func loadgame():
	pass

func savegame():
	var save_file = FileAccess.open(SAVE_LOCATION, FileAccess.WRITE)
	







##################################################################
######### sound players ##########################################
##################################################################
var music_player: AudioStreamPlayer = null

#play sound by name
func play_sound(soundName: String, randomPitch: bool = false) -> AudioStreamPlayer:
	var sfx := AudioStreamPlayer.new()
	sfx.stream = load("res://sounds/%s.ogg" % soundName)
	if randomPitch:
		sfx.pitch_scale = randf_range(0.8, 1.2)
	add_child(sfx)
	sfx.finished.connect(sfx.queue_free)
	sfx.play()
	return sfx

##################################################################
#play sound by name but specific pitch
func play_sound_specificPitch(soundName: String, specificPitch: float = 1) -> AudioStreamPlayer:
	var sfx := AudioStreamPlayer.new()
	sfx.stream = load("res://sounds/%s.ogg" % soundName)
	sfx.pitch_scale = specificPitch
	add_child(sfx)
	sfx.finished.connect(sfx.queue_free)
	sfx.play()
	return sfx
##################################################################
##################################################################
##################################################################
