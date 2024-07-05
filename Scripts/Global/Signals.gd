extends Node

@onready var animation: AnimationPlayer

signal resume
signal quit
signal delete

signal mute

signal petal_picked
signal gold_lotus

signal stairs

var previous_time

var next_point

var previous_level

var invincible = false

var music_volume
var respawnpos_data
var death_counter : int

	


