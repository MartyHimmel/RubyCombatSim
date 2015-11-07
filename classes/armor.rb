class Armor

	attr_reader :id, :name, :defense, :value

	def initialize(id)
		file = File.read('json/armor.json')
		json = JSON.parse(file)
		armor_list = json['armor']

		for armor in armor_list do
			if id == armor['id']
				@id = id
				@name = armor['name']
				@defense = armor['defense']
				@value = armor['value']
				break
			end
		end
	end
	
end