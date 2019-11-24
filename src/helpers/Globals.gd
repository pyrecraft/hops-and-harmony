extends Node

var moon
var day_night

enum GameState {
	PLAYING,
	DIALOGUE
}

enum GameProgress {
	BEDROOM,
	RACE_STARTED,
	COCONUT_STARTED, # Gather coconuts
	COCONUT_COMPLETED,
	STRING_STARTED, # Gather strings
	STRING_COMPLETED,
	SONG_STARTED, # Get song info from birds
	SONG_COMPLETED,
	LYRE_STARTED, # Play song for dolphins at night
	LYRE_COMPLETED, # Successfully played song for dolphins
	DOLPHIN_STARTED, # Start riding their backs to get across
	DOLPHIN_COMPLETED # Get to end of the game
}