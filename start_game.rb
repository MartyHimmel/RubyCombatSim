require 'json'
require 'fileutils'

require_relative 'classes/game'
require_relative 'classes/player'
require_relative 'classes/monster'
require_relative 'classes/weapon'
require_relative 'classes/armor'
require_relative 'classes/shop'

# Start a new game
game = Game.new
game.start_game

# Check if it's a new player
if (game.player == nil)
	#Create a new player
	game.get_player_name
	while !game.player.name_confirmed? do
		game.get_player_name
	end

	# Select a class
	game.player.choose_class
	while !game.player.class_confirmed? do
		game.player.choose_class
	end
end

# Check if the user wants to keep playing
while game.keep_playing?
end