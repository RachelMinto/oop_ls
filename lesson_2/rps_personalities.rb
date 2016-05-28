
MATCH_WINNING_SCORE = 10

class Move
  attr_reader :move_history
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
    @score = 0
  end
end

class Human < Player
  attr_accessor :move_history

  def initialize
    @move_history = []
    super
  end

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

  def update_history
    @move_history.push(self.move.to_s)
  end
end

class Computer < Player
  def set_name
    self.name = ['R2D2', 'Hal', 'Psych. Prof', 'Sonny', 'Number 5'].sample
  end

  def choose(human)
    result = case self.name 
      when 'R2D2' then r2d2_choose(human)
      when 'Hal' then hal_choose
      when 'Psych. Prof' then psych_prof_choose(human)
      when 'Sonny' then sonny_choose(human)
      when 'Number 5' then num5_choose
    end
    result
  end

  def r2d2_choose(human)
    r2_choices = ['rock', 'paper', 'paper']
    if human.move_history.length > 0
      if human.move_history.count('scissors')/human.move_history.length > 0.50
        self.move = Move.new('rock')
      elsif human.move_history.count('rock')/human.move_history.length > 0.50
        self.move = Move.new('paper')
      elsif human.move_history.count('paper')/human.move_history.length > 0.50
        self.move = Move.new('scissors')
      end
    else
      self.move = Move.new(r2_choices.sample)
    end
  end

  def hal_choose
    hal_choices = ['paper', 'paper', 'scissors']
    self.move = Move.new(hal_choices.sample)
  end

  def psych_prof_choose(human)
    if self.move && (human.move > self.move)
      if human.move.to_s == 'rock'
        self.move = Move.new('paper')
      elsif human.move.to_s == 'paper'
        self.move = Move.new('scissors')        
      else human.move.to_s == 'scissors'
        self.move = Move.new('rock')
      end
    elsif self.move && (human.move < self.move)
      self.move = Move.new(human.move.to_s)
    else
      self.move = Move.new(Move::VALUES.sample)
    end
  end

  def sonny_choose(human)
    self.move = human.move ? Move.new(human.move.to_s) : Move.new('rock')
  end

  def num5_choose
    num5_choices = ['rock', 'rock', 'rock', 'paper', 'scissors']
    self.move = Move.new(num5_choices.sample)
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
        computer.choose(human)
        human.choose
        human.update_history
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
