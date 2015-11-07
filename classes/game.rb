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

	def start_game
		puts "1: Create New Character"
		puts "2: Load Character"
		selection = gets.strip.to_i
		case selection
		when 1
			return false
		when 2
			self.load_character
		else
			puts "Enter a valid number."
			self.start_game
		end
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
		self.display_menu
		selection = gets.strip.to_i
		menu_action(selection)
	end

	def display_menu
		cost_of_inn = @player.level * 5

		puts "\nWhat do you want to do?"
		puts "1: View character"
		puts "2: Fight a monster"
		puts "3: Weapon shop"
		puts "4: Armor shop"
		puts "5: Rest (#{cost_of_inn} gold)"
		puts "6: Save character"
		puts "7: Quit game"
	end

	def menu_action(selection)
		case selection
			when 1 # View character
				@player.check_self

			when 2 # Fight monster
				self.select_enemy
				self.combat_loop

			when 3 # Weapon shop
				Shop.new("weapon")
			
			when 4 # Armor shop
				Shop.new("armor")
			
			when 5 # Rest
				self.rest
			
			when 6 # Save character
				self.save_character
			
			when 7 # Quit
				puts "\nThanks for playing!\n"
				return false
			
			else 
				puts "Invalid selection. Enter the number for your selection."
				self.get_menu_selection
		end
		true
	end

	def rest
		if @player.level * 5 <= @player.gold
			@player.gold -= @player.level * 5
			@player.hit_points = @player.max_hit_points
			puts "\nYou go to the inn and rent a room for the night."
			puts "Your hit points have been restored."
		else
			puts "\nYou don't have enough gold."
		end
	end

	def save_character
		# See if save file exists. If it does, make sure the player
		# wants to overwrite it
		if File.exist?("save/character.txt")
			puts "The save file will be overwritten. Are you sure you want to save?"
			answer = gets.strip.upcase
			if answer.eql?("N")
				return
			end

			unless answer.eql?("Y")
				puts "Enter 'Y' or 'N'"
				return self.save_character
			end
		else
			# Create new file if this is the first save
			FileUtils.mkdir("save")
			File.new("save/character.txt", "w");
		end

		# Open and write character data to the file
		File.open("save/character.txt", "w") do |file|
			file.write("name=#{@player.name}\n")
			file.write("class=#{@player.character_class['name']}\n")
			file.write("level=#{@player.level}\n")
			file.write("hit_points=#{@player.hit_points}\n")
			file.write("max_hit_points=#{@player.max_hit_points}\n")
			file.write("experience=#{@player.experience}\n")
			file.write("gold=#{@player.gold}\n")
			file.write("weapon=#{@player.weapon.id}\n")
			file.write("armor=#{@player.armor.id}")
		end

		puts "Your character has been saved."
	end

	def load_character
		# Bail out if there's no save file
		if !File.exist?("save/character.txt")
			return puts "No saved characters."
		end

		data = {}
		File.readlines("save/character.txt").each do |line|
			line.gsub!("\n", "")
			arr = line.split("=")
			data[arr[0]] = arr[1]
		end

		@player = Player.new(data['name'])
		@player.set_class_by_name(data['class'])
		@player.level = data['level'].to_i
		@player.hit_points = data['hit_points'].to_i
		@player.max_hit_points = data['max_hit_points'].to_i
		@player.experience = data['experience'].to_i
		@player.gold = data['gold'].to_i
		@player.weapon = Weapon.new(data['weapon'].to_i)
		@player.armor = Armor.new(data['armor'].to_i)

		puts "#{@player.name} has been successfully loaded."
	end

end