
# frozen_string_literal:true

# CRC Cards: Class, Superclass, Collaborators, Responsibilities
# Player - Nil - Nil - Has a Move, Has a Name
# Human - Player - Move, Score - User Choose Move, User Choose Name @Init
# Computer - Player - Move, Score - AI Choose Move, AI Choose Name @Init
# Move - Nil - Nil - Has a value, Compare Moves, Return string representation
# Score - Nil - Nil - 

MATCH_WINNING_SCORE = 10.freeze

class Move
  VALUES = ['rock', 'paper', 'scissors'].freeze

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other_move)
    (rock? && other_move.scissors?) ||
      (paper? && other_move.rock?) ||
      (scissors? && other_move.paper?)
  end

  def <(other_move)
    (rock? && other_move.paper?) ||
      (paper? && other_move.scissors?) ||
      (scissors? && other_move.rock?)
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    self.score = Score.new(name)
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors."
      choice = gets.chomp
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class Score
  def initialize(name)
    @value = 0
    @name = name
  end
  
  def display
    "#{@value}"
  end
  
  def update
    @value += 1
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie."
    end
  end
  
  def update_score
    if human.move > computer.move
      human.score.update
    elsif human.move < computer.move
      computer.score.update
    end
  end
  
  def display_score
    puts "#{human.name} has #{human.score.display} points and #{computer.name} has #{computer.score.display}."
  end
  
  def winner?
    human.score == 10 || computer.score == 10 # NOT WORKING!!
  end

  def play_again?
    answer = nil

    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include? answer.downcase
      puts "Sorry, must be y or n."
    end

    return false if answer.downcase == 'n'
    return true if answer.downcase == 'y'
  end

  def play
    display_welcome_message

    loop do
      loop do
        human.choose
        computer.choose
        display_moves
        update_score
        display_winner
        display_score
        break if winner?
      end
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
