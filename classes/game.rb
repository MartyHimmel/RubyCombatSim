class Game

	attr_accessor :player, :monster, :monster_list

	# Print welcome message
	def initialize
		puts "Welcome to the combat simulator!"

		# Store monster list
		file = File.read('json/monsters.json')
		json = JSON.parse(file)
		@monster_list = json['monsters']
	end

	# Get the player's name and initialize the player object
	def get_player_name
		puts "\nWhat is your name?"
		@player = Player.new(gets.strip)
	end

	# Select enemy to fight
	def select_enemy
		puts "\nSelect a monster to fight:"

		# Display list of monsters
		for monster in @monster_list do
			puts "#{monster['id']}: #{monster['name']}"
		end

		selection = gets.strip.to_i

		# Make sure selection is within range
		if !(1..@monster_list.length).include? selection
			puts "\nInvalid selection. Enter the number for the monster you want to fight."
			return self.select_enemy
		end
		
		# Get selected monster
		@monster = Monster.new(selection)

		puts "\n#{@monster.name} appears before you."
	end

	def combat_loop
		while @monster.is_alive? && @player.is_alive? do
			# Command list
			puts "\nWhat will you do?"
			puts "1: View character"
			puts "2: Attack #{@monster.name}"
			puts "3: Run away"
			command = gets.strip.to_i

			case command
				when 1
					# View Character
					@player.check_self
				when 2
					# Attack
					damage_to_monster = @player.weapon_attack
					puts "You do #{damage_to_monster} damage to the #{@monster.name}."
					@monster.hit_points -= damage_to_monster

					if @monster.is_alive?
						damage_to_player = self.calc_damage_to_player
						if damage_to_player > 0
							puts "You lost #{damage_to_player} hit points."
						else
							puts "Your armor absorbed the attack. You didn't take any damage."
						end
						@player.hit_points -= damage_to_player
					end
				when 3
					# Run away
					r = rand(1..100)
					if r >= 30
						puts "You ran away from #{@monster.name}"
						break
					else
						puts "You failed to escape the #{@monster.name}"
						damage_to_player = self.calc_damage_to_player
						if damage_to_player > 0
							puts "You lost #{damage_to_player} hit points."
						else
							puts "Your armor absorbed the attack. You didn't take any damage."
						end
						@player.hit_points -= damage_to_player
					end
				else
					puts "Enter the number for your desired action."
			end
		end

		if !@monster.is_alive?
			self.victory
		elsif !@player.is_alive?
			puts "You have been slain by #{@monster.name}. Thanks for playing!"
			exit
		end
	end

	def calc_damage_to_player
		calculated_damage = @monster.attack - rand(0..@player.armor.defense)
		if calculated_damage < 0
			calculated_damage = 0
		end
		calculated_damage
	end

	def victory
		puts "\nYou have slain the #{@monster.name}."
		puts "You have gained #{@monster.exp_value} experience and #{@monster.gold_value} gold."
		@player.experience += @monster.exp_value
		@player.gold += @monster.gold_value
	end

	def keep_playing?
		puts "\nDo you want to fight a monster (Y/N)?"
		answer = gets.strip.upcase
		case answer
			when "Y"
				play_again = true
			when "N"
				play_again = false
			else
				puts "Enter 'Y' or 'N'"
				return self.keep_playing?
		end
		play_again
	end

end