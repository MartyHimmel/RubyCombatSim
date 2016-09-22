# Handles the various shops
class Shop
  attr_reader :inventory, :shop_type

  def initialize(shop_type)
    @shop_type = shop_type

    file = File.read("json/#{shop_type}.json")
    json = JSON.parse(file)
    @inventory = json[shop_type]
  end

  def greeting
    puts "\nWelcome to the #{@shop_type} shop."
    puts 'What are you interested in?'
  end

  def choices
    @inventory.each do |item|
      printf("%3s: %-25s %8d gold\n", item['id'], item['name'], item['value'])
    end
  end

  def enter
    greeting
    choices
  end

  def select_item
    choice = gets.strip.to_i
    @inventory.each do |item|
      next unless item['id'] == choice
      @item = item
    end
    @item
  end

  def enough_gold?(item, player)
    if player.gold < item['value']
      puts 'You don\'t have enough gold for that.'
      return false
    end

    true
  end
end
