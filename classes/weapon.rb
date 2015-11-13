class Weapon
  attr_reader :id, :name, :min_dmg, :max_dmg, :value

  def initialize(id)
    file = File.read('json/weapons.json')
    json = JSON.parse(file)
    weapons_list = json['weapons']

    weapons_list.each do |weapon|
      next unless id == weapon['id']
      @id = id
      @name = weapon['name']
      @min_dmg = weapon['min_dmg']
      @max_dmg = weapon['max_dmg']
      @value = weapon['value']
    end
  end
end
