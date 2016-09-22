class Game
  attr_accessor :player, :monster
  attr_reader :monster_list

  # Print welcome message
  def initialize
    puts 'Welcome to the combat simulator!'

    # Store monster list
    file = File.read('json/monsters.json')
    json = JSON.parse(file)
    @monster_list = json['monsters']
  end

  def start_game
    puts '1: Create New Character'
    puts '2: Load Character'
    selection = gets.strip.to_i
    case selection
    when 1
      return false
    when 2
      load_character
    else
      puts 'Enter a valid number.'
      start_game
    end
  end

  # Get the player's name and initialize the player object
  def player_name
    puts "\nWhat is your name?"
    @player = Player.new(gets.strip)
  end

  # Select enemy to fight
  def select_enemy
    puts "\nSelect a monster to fight:"

    # Display list of monsters
    @monster_list.each do |monster|
      puts "#{monster['id']}: #{monster['name']}"
    end

    selection = gets.strip.to_i

    # Make sure selection is within range
    unless (1..@monster_list.length).include? selection
      puts "\nInvalid selection. Enter the number for the monster \
            you want to fight."
      return select_enemy
    end

    # Get selected monster
    @monster = Monster.new(selection)

    puts "\n#{@monster.name} appears before you."
  end

  def combat_command_list
    puts "\nWhat will you do?"
    puts '1: View character'
    puts "2: Attack #{@monster.name}"
    puts '3: Run away'
    command = gets.strip.to_i
    command
  end

  def combat_loop
    while @monster.alive? && @player.alive?
      command = combat_command_list

      case command
      when 1
        # View Character
        @player.check_self
      when 2
        # Attack
        full_combat_round
      when 3
        # Run away
        return if run_away?
      else
        puts 'Enter the number for your desired action.'
      end
    end

    if !@monster.alive?
      victory
    elsif !@player.alive?
      puts "You have been slain by #{@monster.name}."
      puts 'Thanks for playing!'
      exit
    end
  end

  def full_combat_round
    damage_to_monster = @player.weapon_attack
    puts "You do #{damage_to_monster} damage to the #{@monster.name}."
    @monster.hit_points -= damage_to_monster

    display_damage_to_player(calc_damage_to_player) if @monster.alive?
  end

  def run_away?
    r = rand(1..100)
    if r >= 30
      puts "You ran away from #{@monster.name}"
      return true
    else
      puts "You failed to escape the #{@monster.name}"
      display_damage_to_player(calc_damage_to_player)
      return false
    end
  end

  def calc_damage_to_player
    calculated_damage = @monster.attack - rand(0..@player.armor.defense)
    calculated_damage = 0 if calculated_damage < 0
    @player.hit_points -= calculated_damage
    calculated_damage
  end

  def display_damage_to_player(damage)
    if damage > 0
      puts "You lost #{damage} hit points."
    else
      puts 'Your armor absorbed the attack. You didn\'t take any damage.'
    end
  end

  def victory
    puts "\nYou have slain the #{@monster.name}."
    puts "You have gained #{@monster.exp_value} experience and #{@monster.gold_value} gold."
    @player.experience += @monster.exp_value
    @player.gold += @monster.gold_value
  end

  def keep_playing?
    display_menu
    selection = gets.strip.to_i
    menu_action(selection)
  end

  def display_menu
    cost_of_inn = @player.level * 5

    puts "\nWhat do you want to do?"
    puts '1: View character'
    puts '2: Fight a monster'
    puts '3: Weapon shop'
    puts '4: Armor shop'
    puts "5: Rest (#{cost_of_inn} gold)"
    puts '6: Save character'
    puts '7: Quit game'
  end

  def menu_action(selection)
    case selection
    when 1 # View character
      @player.check_self

    when 2 # Fight monster
      select_enemy
      combat_loop

    when 3 # Weapon shop
      weapon_shop

    when 4 # Armor shop
      armor_shop

    when 5 # Rest
      rest

    when 6 # Save character
      save_character

    when 7 # Quit
      puts "\nThanks for playing!\n"
      return false

    else
      puts 'Invalid selection. Enter the number for your selection.'
      menu_selection
    end
    true
  end

  def rest
    if @player.level * 5 <= @player.gold
      @player.gold -= @player.level * 5
      @player.hit_points = @player.max_hit_points
      puts "\nYou go to the inn and rent a room for the night."
      puts 'Your hit points have been restored.'
    else
      puts "\nYou don't have enough gold."
    end
  end

  def save_character
    # See if save file exists. If it does, make sure the player
    # wants to overwrite it
    if File.exist?('save/character.txt')
      puts 'The save file will be overwritten. Are you sure you want to save?'
      answer = gets.strip.upcase
      return if answer.eql?('N')

      unless answer.eql?('Y')
        puts 'Enter Y or N'
        return save_character
      end
    else
      # Create new file if this is the first save
      FileUtils.mkdir('save')
      File.new('save/character.txt', 'w')
    end

    # Open and write character data to the file
    File.open('save/character.txt', 'w') do |file|
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

    puts "\nYour character has been saved."
  end

  def load_character
    # Bail out if there's no save file
    return puts 'No saved characters.' unless File.exist?('save/character.txt')

    data = {}
    File.readlines('save/character.txt').each do |line|
      line.gsub!('\n', '')
      arr = line.split('=')
      data[arr[0]] = arr[1]
    end

    @player = Player.new(data['name'].strip)
    @player.class_by_name(data['class'].strip)
    @player.level = data['level'].to_i
    @player.hit_points = data['hit_points'].to_i
    @player.max_hit_points = data['max_hit_points'].to_i
    @player.experience = data['experience'].to_i
    @player.gold = data['gold'].to_i
    @player.weapon = Weapon.new(data['weapon'].to_i)
    @player.armor = Armor.new(data['armor'].to_i)

    puts "\n#{@player.name} has been successfully loaded."
  end

  def weapon_shop
    shop = Shop.new('weapons')
    shop.enter
    item = shop.select_item
    if shop.enough_gold?(item, @player)
      @player.gold -= item['value']
      @player.weapon = Weapon.new(item['id'])
      puts 'Thank you!'
    else
      menu_action(3)
    end
  end

  def armor_shop
    shop = Shop.new('armor')
    shop.enter
    item = shop.select_item
    if shop.enough_gold?(item, @player)
      @player.gold -= item['value']
      @player.armor = Armor.new(item['id'])
      puts 'Thank you!'
    else
      menu_action(4)
    end
  end
end
