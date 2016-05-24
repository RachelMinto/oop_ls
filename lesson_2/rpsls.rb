
# frozen_string_literal:true

MATCH_WINNING_SCORE = 4.freeze

class Move
  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock'].freeze

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

  def spock?
    @value == 'spock'
  end

  def lizard?
    @value == 'lizard'
  end

  def >(other_move)
    (rock? && (other_move.scissors? || other_move.lizard?)) ||
      (paper? && (other_move.rock? || other_move.spock?)) ||
      (scissors? && (other_move.paper? || other_move.lizard?)) ||
      (lizard? && (other_move.paper? || other_move.spock?)) ||
      (spock? && (other_move.rock? || other_move.scissors?))  
  end

  def <(other_move)
    (rock? && (other_move.spock? || other_move.paper?)) ||
      (paper? && (other_move.lizard? || other_move.scissors?)) ||
      (scissors? && (other_move.rock? || other_move.spock?)) ||
      (lizard? && (other_move.rock? || other_move.scissors?)) ||
      (spock? && (other_move.lizard? || other_move.paper?))  
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
      puts "Please choose rock, paper, scissors, lizard, or spock."
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
  
  def update
    @value += 1
  end

  def to_i
    @value
  end

  def reset
    @value = 0
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
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
    puts "-------------------"
  end
  
  def update_score
    if human.move > computer.move
      human.score.update
    elsif human.move < computer.move
      computer.score.update
    end
  end
  
  def display_score
    puts <<-MSG
#{human.name} has #{human.score.to_i} points and \
#{computer.name} has #{computer.score.to_i} points.
    MSG
  end
  
  def winner?
    human.score.to_i == MATCH_WINNING_SCORE || 
    computer.score.to_i == MATCH_WINNING_SCORE
  end

  def display_match_winner
    if human.score.to_i == MATCH_WINNING_SCORE
      puts "#{human.name} won best out of #{MATCH_WINNING_SCORE}!"
    elsif computer.score.to_i == MATCH_WINNING_SCORE
      puts "#{computer.name} won best out of #{MATCH_WINNING_SCORE}!"
    end
    puts "-------------------"
  end

  def reset_scores
    human.score.reset
    computer.score.reset
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
      display_match_winner
      reset_scores
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
