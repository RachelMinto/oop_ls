
class Vehicle
  attr_accessor :color
  attr_reader :model, :year

  @@num_vehicles = 0

  def self.num_of_vehicles
    puts "There are currently #{@@num_vehicles} vehicles."
  end

  def initialize (year, color, model)
    @year = year
    self.color = color
    @model = model
    @current_speed = 0
    @@num_vehicles += 1
  end

  def speed_up(how_much)
    @current_speed += how_much
  end

  def brake
    @current_speed = 0
  end

  def spraypaint(new_color)
    self.color = (new_color)
    puts "Your new #{color} paint job looks rad!"
  end

  def age
    puts  "The vehicle is #{age_tracker} years old."
  end

  private

  def age_tracker
    Time.now.year - self.year
  end
end

module Loadable
  def moving_truck
    puts "This vehicle is good at moving large amounts of stuff!" 
  end
end

class MyTruck < Vehicle

  include Loadable

  SIZE = "big"

  def initialize(year, color, model)
    super
  end

  def size
    puts "My vehicle is #{SIZE}."
  end
end

class MyCar < Vehicle

  SIZE = "small"

  def initialize(year, color, model)
    super
  end

  def self.gas_mileage(gallons, miles)
    puts "#{miles / gallons} miles per gallon of gas."
  end

  def turn_off
    if @current_speed != 0 
      puts "The car cannot turn off while it is going more than 0 mph."
    else
      puts "The car has been turned off."
    end
  end
  
  def description
    puts "The #{color} #{model} car is going #{@current_speed} mph."
  end

  def to_s
    puts "The car is a #{year} #{color} #{model}."
  end
end

ralph = MyCar.new(1993, "red", "S.Mouse")

ralph.description
ralph.spraypaint("tie-dyed")
ralph.description

four_wheels = MyTruck.new(1999, "blue", "Pickup")

four_wheels.size

Vehicle.num_of_vehicles

four_wheels.moving_truck

puts MyCar.ancestors
puts MyTruck.ancestors
puts Vehicle.ancestors

four_wheels.age