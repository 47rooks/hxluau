-- Animal base class module
local Animal = {}
Animal.__index = Animal

function Animal.new(name: string)
	local self = setmetatable({}, Animal)
	-- local self = {}
	self.__index = Animal
	-- self.__tostring = Animal.__tostring
	self.name = name
	return self
end

function Animal.__tostring(self)
	print("Animal __tostring called")
	return self.name or "Unnamed Animal"
end

function Animal.getAnimalName(self)
	return "Animal " .. (self.name or "Unnamed")
end

return Animal