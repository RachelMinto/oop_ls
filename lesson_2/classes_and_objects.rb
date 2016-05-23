class Person
  attr_accessor :full_name

  def initialize(full_name)
    @full_name = full_name
  end

  # def name
  #   puts "#{first_name} #{last_name}"
  # end

  # def name= (full_name)
  #   parse_full_name(full_name)   
  # end

  def to_s
    full_name
  end

  # private

  # def parse_full_name(full_name)
  #   parts = full_name.split
  #   self.first_name = parts.first
  #   self.last_name = parts.size > 1 ? parts.last : ''
  # end
end

bob = Person.new('Robert Smith')

puts "The person's name is: #{bob}"

