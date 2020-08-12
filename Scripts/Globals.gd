extends Node

var SHOW_NPC_PATHFIND : bool = false

const DEFAULT_LAP_NUMBER : int = 3
const MIN_LAP_NUMBER : int = 1
const MAX_LAP_NUMBER : int = 99

const DEFAULT_NPC_NUMBER : int = 11
const MIN_NPC_NUMBER : int = 0
const MAX_NPC_NUMBER : int = 11

var laps_number : int = DEFAULT_LAP_NUMBER
var NPC_number : int = DEFAULT_NPC_NUMBER

onready var game : Game = get_tree().get_root().get_node("Game")
