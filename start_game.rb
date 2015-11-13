#!/usr/bin/env ruby

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
if game.player.nil?
  # Create a new player
  game.player_name
  game.player_name until game.player.name_confirmed?

  # Select a class
  game.player.choose_class
  game.player.choose_class until game.player.class_confirmed?
end

# Check if the user wants to keep playing
while game.keep_playing?
end
