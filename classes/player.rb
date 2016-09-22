# Player character and interactions
class Player
  attr_accessor :character_class, :weapon, :armor, :max_hit_points,
                :hit_points, :level, :experience, :gold
  attr_reader :name

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
    when 'Y'
      confirmed = true
    when 'N'
      confirmed = false
    else
      puts 'Enter Y or N'
      return name_confirmed?
    end
    confirmed
  end

  # Return a list of classes from a JSON file
  def list_of_classes
    file = File.read('json/classes.json')
    json = JSON.parse(file)
    json['classes']
  end

  # Return a list of weapons from a JSON file
  def list_of_weapons
    file = File.read('json/weapons.json')
    json = JSON.parse(file)
    json['weapons']
  end

  # Return a list of armor from a JSON file
  def list_of_armor
    file = File.read('json/armor.json')
    json = JSON.parse(file)
    json['armor']
  end

  # Character class selection
  def choose_class
    character_classes = list_of_classes
    puts "\nSelect a class:"

    # List class ids and names
    character_classes.each do |character_class|
      puts "#{character_class['id']}: #{character_class['name']}"
    end

    # Get number from user
    selection = gets.strip.to_i

    # Make sure selection is within range of choices
    unless (1..character_classes.length).include? selection
      puts "\nInvalid selection. Enter the number for your desired class."
      return choose_class
    end

    # Find class info in list
    character_classes.each do |character_class|
      next unless selection == character_class['id']
      @character_class = character_class
      starting_weapon
      starting_armor
      break
    end

    @level = 1
    starting_hp_values
  end

  # Sets the character's class based on given class name.
  # Used for loading a saved character.
  def class_by_name(name)
    character_classes = list_of_classes
    character_classes.each do |character_class|
      if character_class['name'].eql?(name)
        @character_class = character_class
        break
      end
    end
  end

  # Set max and current hit points based on class
  def starting_hp_values
    @max_hit_points = @character_class['starting_hp']
    @hit_points = @character_class['starting_hp']
  end

  # Confirm the character class
  def class_confirmed?
    puts "\nYou chose #{@character_class['name']}. Is that correct (Y/N)?"
    confirm = gets.strip.upcase
    case confirm
    when 'Y'
      confirmed = true
    when 'N'
      confirmed = false
    else
      puts 'Enter Y or N'
      return class_confirmed?
    end
    confirmed
  end

  def starting_weapon
    weapons = list_of_weapons

    weapons.each do |weapon|
      if @character_class['starting_weapon'] == weapon['name']
        @weapon = Weapon.new(weapon['id'])
        break
      end
    end
  end

  def starting_armor
    armor_list = list_of_armor

    armor_list.each do |armor|
      if @character_class['starting_armor'] == armor['name']
        @armor = Armor.new(armor['id'])
        break
      end
    end
  end

  def display_weapons
    weapons = list_of_weapons
    puts 'Select a weapon:'

    # List weapon ids and names
    weapons.each do |weapon|
      puts "#{weapon['id']}: #{weapon['name']}"
    end
  end

  # Select a weapon for the character
  def select_weapon
    weapons = list_of_weapons

    # Get number from user
    selection = gets.strip.to_i

    # Make sure selection is within range of choices
    unless (1..weapons.length).include? selection
      puts "\nInvalid selection. Enter the number for your desired weapon."
      display_weapons
      return select_weapon
    end

    # Find weapon in list
    weapons.each do |weapon|
      next unless selection == weapon['id']
      @weapon = Weapon.new(selection)
      break
    end
  end

  # Attack with a weapon
  def weapon_attack
    rand(@weapon.min_dmg..@weapon.max_dmg)
  end

  def check_self
    puts "\n|".concat('-' * 31).concat('|')
    puts format('| %-13s %15s |', 'Name:', @name)
    puts format('| %-13s %15s |', 'Class:', @character_class['name'])
    puts format('| %-13s %15s |', 'Level:', @level)
    puts format('| %-13s %15s |', 'Weapon:', @weapon.name)
    puts format('| %-13s %15s |', 'Armor:', @armor.name)
    puts format('| %-13s %15s |', 'HP:', @hit_points)
    puts format('| %-13s %15s |', 'Damage:',
                "#{@weapon.min_dmg}-#{@weapon.max_dmg}")
    puts format('| %-13s %15s |', 'Defense:', @armor.defense)
    puts format('| %-13s %15s |', 'Experience:', @experience)
    puts format('| %-13s %15s |', 'Gold:', @gold)
    puts '|'.concat('-' * 31).concat("|\n")
  end

  def alive?
    @hit_points > 0
  end
end
