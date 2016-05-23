class Student

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(other_student)
    grade > other_student.grade
  end

  protected

  attr_reader :grade

end


joe = Student.new("Joseph", 88)

bob = Student.new("Robert", 79)

puts "well done!" if joe.better_grade_than?(bob)