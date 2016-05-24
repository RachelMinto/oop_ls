
MATCH_WINNING_SCORE = 10.freeze

# frozen_string_literal:true
VALUES = ['rock', 'paper', 'scissors'].freeze

class Rock
  def initialize
    status = active
  end
end

class Paper
  def initialize
    status = active
  end
end

class Scissors
  def initialize
    status = active
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0
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
      break if VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    choice = choice.capitalize.const_get
    self.move = choice.new
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5'].sample
  end

  def choose
    self.move = (VALUES.sample.capitalize).const_get.new
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

  def update_scores
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    end
  end

  def reset_scores
    human.score = 0
    computer.score = 0
  end

  def display_scores
    puts "#{human.name} has #{human.score} points and #{computer.name} has 
#{computer.score} points."
    puts"------------------------------"
  end

  def match_winner?
    human.score == MATCH_WINNING_SCORE || computer.score == MATCH_WINNING_SCORE
  end

  def display_match_winner
    puts "------------------------------"
    if human.score == MATCH_WINNING_SCORE
      puts "#{human.name} won the match!"
    else
      puts "#{computer.name} won the match!"
    end
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
        display_winner
        update_scores
        display_scores
        break if match_winner?
      end
      display_match_winner
      reset_scores
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
