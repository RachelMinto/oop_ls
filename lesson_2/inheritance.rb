
class Animal
  def run
    'running!'
  end

  def jump
    'jumping!'
  end
end

module Swim
  def swim
    "Swimming!"
  end
end

module Lick
  def lick
    "I love you so much I'll lick you!"
  end
end

class Dog < Animal
  def speak
    'bark!'
  end

  include Swim
  include Lick

end

class Cat < Animal

end

class BullDog < Dog
  def swim
    'Can\'t swim!'
  end
end

class Fish < Animal
  include Swim
end

p Dog.ancestors

p BullDog.ancestors

p Cat.ancestors

p Fish.ancestors

p Animal.ancestors