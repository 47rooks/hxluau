print('hello')
local Animal = require('./Animal')
local Dog = require('./Dog')

local a = Animal.new('animal')

print(a:getAnimalName())

local d = Dog.new('Fido')

print(d:getAnimalName())
print(Dog.getName(d))