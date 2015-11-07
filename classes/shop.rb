class Shop

	def initialize(type)
		self.get_shop(type)
	end

	def get_shop(type)
		case type
			when "weapon"
				self.weapon_shop
			when "armor"
				self.armor_shop
			else
				puts "Wrong type of shop"
		end
	end

	def weapon_shop
		puts "\nWelcome to the weapon shop."
	end

	def armor_shop
		puts "\nWelcome to the armor shop."
	end

end