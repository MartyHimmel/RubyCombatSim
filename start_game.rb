require 'json'
require_relative 'classes/game'
require_relative 'classes/player'
require_relative 'classes/monster'
require_relative 'classes/weapon'
require_relative 'classes/armor'

# Start a new game
game = Game.new

# Create a new player
game.get_player_name
while !game.player.name_confirmed? do
	game.get_player_name
end

# Select a class
game.player.choose_class
while !game.player.class_confirmed? do
	game.player.choose_class
end

# Select an enemy to fight
game.select_enemy
game.combat_loop

# Check if the user wants to keep playing
while game.keep_playing? do
	game.select_enemy
	game.combat_loop
end

puts "Thanks for playing!"