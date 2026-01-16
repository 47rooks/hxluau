print('hello')
local Animal = require('./Animal.luau')
local Dog = require('./Dog.luau')

local a = Animal.new('animal')

print(a:getAnimalName())

local d = Dog.new('Fido')

print(d:getAnimalName())
print(Dog.getName(d))