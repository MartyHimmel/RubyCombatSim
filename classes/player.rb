class Player

	attr_accessor :name, :character_class, :weapon, :armor, :max_hit_points,
		:hit_points, :level, :experience, :gold

	def initialize(name)
		@name = name
		@experience = 0
		@gold = 0
	end

	# Confirm the player's name
	def name_confirmed?
		puts "\nYour name is #{@name}. Is that correct (Y/N)?"
		confirm = gets.strip.upcase
		case confirm
			when "Y"
				confirmed = true
			when "N"
				confirmed = false
			else
				puts "Enter 'Y' or 'N'"
				return self.name_confirmed?
		end
		confirmed
	end

	# Return a list of classes from a JSON file
	def get_list_of_classes
		file = File.read('json/classes.json')
		json = JSON.parse(file)
		json['classes']
	end

	# Return a list of weapons from a JSON file
	def get_list_of_weapons
		file = File.read('json/weapons.json')
		json = JSON.parse(file)
		json['weapons']
	end

	# Return a list of armor from a JSON file
	def get_list_of_armor
		file = File.read('json/armor.json')
		json = JSON.parse(file)
		json['armor']
	end

	# Character class selection
	def choose_class
		character_classes = self.get_list_of_classes
		puts "\nSelect a class:"

		# List class ids and names
		for character_class in character_classes do
			puts "#{character_class['id']}: #{character_class['name']}"
		end

		# Get number from user
		selection = gets.strip.to_i

		# Make sure selection is within range of choices
		if !(1..character_classes.length).include? selection
			puts ""
			puts "\nInvalid selection. Enter the number for your desired class."
			return self.choose_class
		end

		# Find class info in list
		for character_class in character_classes do
			if selection == character_class['id']
				@character_class = character_class
				self.set_starting_weapon
				self.set_starting_armor
				break
			end
		end

		@level = 1
		self.set_hp
	end

	# Sets the character's class based on given class name.
	# Used for loading a saved character.
	def set_class_by_name(name)
		character_classes = self.get_list_of_classes
		character_classes.each do |character_class|
			if (character_class['name'].eql?(name))
				@character_class = character_class
				break
			end
		end
	end

	# Set max and current hit points based on class
	def set_hp
		@max_hit_points = @character_class['starting_hp']
		@hit_points = @character_class['starting_hp']
	end

	# Confirm the character class
	def class_confirmed?
		puts "\nYour chose #{@character_class['name']}. Is that correct (Y/N)?"
		confirm = gets.strip.upcase
		case confirm
			when "Y"
				confirmed = true
			when "N"
				confirmed = false
			else
				puts "Enter 'Y' or 'N'"
				return self.class_confirmed?
		end
		confirmed
	end

	def set_starting_weapon
		weapons = self.get_list_of_weapons

		for weapon in weapons do
			if @character_class['starting_weapon'] == weapon['name']
				@weapon = Weapon.new(weapon['id'])
				break
			end
		end
	end

	def set_starting_armor
		armor_list = self.get_list_of_armor

		for armor in armor_list do
			if @character_class['starting_armor'] == armor['name']
				@armor = Armor.new(armor['id'])
				break
			end
		end
	end

	# Select a weapon for the character
	def select_weapon
		weapons = self.get_list_of_weapons
		puts "Select a weapon:"

		# List weapon ids and names
		for weapon in weapons do
			puts "#{weapon['id']}: #{weapon['name']}"
		end
		
		# Get number from user
		selection = gets.strip.to_i

		# Make sure selection is within range of choices
		if !(1..weapons.length).include? selection
			puts ""
			puts "Invalid selection. Enter the number for your desired weapon."
			return self.select_weapon
		end

		# Find weapon in list
		for weapon in weapons do
			if selection == weapon['id']
				@weapon = Weapon.new(selection)
				break
			end
		end

	end

	# Attack with a weapon
	def weapon_attack
		rand(@weapon.min_dmg..@weapon.max_dmg)
	end

	def check_self
		puts "\n|".concat("-" * 31).concat("|")
		puts "|%-14s %16s|" % ["Name:", "#{@name}"]
		puts "|%-14s %16s|" % ["Class:", "#{@character_class['name']}"]
		puts "|%-14s %16s|" % ["Level:", "#{@level}"]
		puts "|%-14s %16s|" % ["Weapon:", "#{@weapon.name}"]
		puts "|%-14s %16s|" % ["Armor:", "#{@armor.name}"]
		puts "|%-14s %16s|" % ["HP:", "#{@hit_points}"]
		puts "|%-14s %16s|" % ["Damage:", "#{@weapon.min_dmg}-#{@weapon.max_dmg}"]
		puts "|%-14s %16s|" % ["Defense:", "#{@armor.defense}"]
		puts "|%-14s %16s|" % ["Experience:", "#{@experience}"]
		puts "|%-14s %16s|" % ["Gold:", "#{@gold}"]
		puts "|".concat("-" * 31).concat("|\n")
	end

	def is_alive?
		@hit_points > 0
	end

end