class Weapon

	attr_reader :name, :min_dmg, :max_dmg, :value

	def initialize(id)
		file = File.read('json/weapons.json')
		json = JSON.parse(file)
		weapons_list = json['weapons']

		for weapon in weapons_list do
			if id == weapon['id']
				@name = weapon['name']
				@min_dmg = weapon['min_dmg']
				@max_dmg = weapon['max_dmg']
				@value = weapon['value']
				break
			end
		end
	end

end