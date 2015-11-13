class Monster
  attr_reader :name, :attack1, :attack1_min_dmg, :attack1_max_dmg,
              :attack2, :attack2_min_dmg, :attack2_max_dmg, :exp_value,
              :gold_value

  attr_accessor :hit_points

  def initialize(id)
    file = File.read('json/monsters.json')
    json = JSON.parse(file)
    monster_list = json['monsters']

    monster_list.each do |monster|
      next unless id == monster['id']
      @name = monster['name']
      @hit_points = monster['max_hp']
      @attack1 = monster['attack1']
      @attack1_min_dmg = monster['attack1_min_dmg']
      @attack1_max_dmg = monster['attack1_max_dmg']
      @attack2 = monster['attack2']
      @attack2_min_dmg = monster['attack2_min_dmg']
      @attack2_max_dmg = monster['attack2_max_dmg']
      @exp_value = monster['exp_value']
      @gold_value = monster['gold_value']
      break
    end
  end

  def attack
    att_method = attack_method

    case att_method
    when 1
      puts "#{@name} #{@attack1}."
      damage = rand(@attack1_min_dmg..@attack1_max_dmg)
    when 2
      puts "#{@name} #{@attack2}."
      damage = rand(@attack2_min_dmg..@attack2_max_dmg)
    else
      puts "#{@name} #{@attack1}."
      damage = rand(@attack1_min_dmg..@attack1_max_dmg)
    end

    damage
  end

  def attack_method
    percentage = rand(1..100)

    if @attack2.nil?
      attack_method = 1
    elsif percentage <= 75
      attack_method = 1
    else
      attack_method = 2
    end

    attack_method
  end

  def alive?
    @hit_points > 0
  end
end
