-- Dog subclass module
local Animal = require("./Animal")

-- Creating an Animal instance as the metatable base for Dog is required to
-- to access the :_tostring() method from Animal because we need an object
-- instance. Without this you need to use a new metatable with __index pointing
-- to Animal. That said this really isn't properly setup example yet.
local Dog = setmetatable({}, {__index = Animal})
-- local Dog = setmetatable({}, Animal.new("DogBase"))
Dog.__index = Dog

function Dog.new(name: string)
	local self = setmetatable({}, {__index = Animal.new(name),
									__tostring = Animal.__tostring
	})
	-- local self = setmetatable({}, Animal.new(name))
	-- local self = setmetatable({}, Dog)
	-- self.name = name
	return self
end

function Dog:__tostring()
	return "Dog " .. self.name
end

function Dog.getName(self)
	return "Dog " .. self.name
end

return Dog