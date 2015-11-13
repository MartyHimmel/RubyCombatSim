class Shop
  attr_reader :shop_type

  def initialize(shop_type)
    @shop_type = shop_type
  end

  def get_shop(type)
    case type
    when 'weapon'
      weapon_shop
    when 'armor'
      armor_shop
    else
      puts 'Wrong type of shop'
    end
  end

  def weapon_shop
    puts "\nWelcome to the weapon shop."
  end

  def armor_shop
    puts "\nWelcome to the armor shop."
  end
end
