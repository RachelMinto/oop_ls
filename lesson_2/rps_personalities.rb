
# frozen_string_literal: true

module Display
  def clear_screen
    system('clear') || system('cls')
  end
end

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
    @score = 0
  end
end

class Human < Player
  attr_accessor :move_history

  include Display

  def initialize
    super
    @move_history = []
  end

  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      # rubocop: disable Style/ZeroLengthPredicate
      break unless n.to_s.strip.length == 0
      # rubocop: enable Style/ZeroLengthPredicate
      puts "Sorry, must enter a value."
    end
    self.name = n
    clear_screen
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, or scissors."
      choice = gets.chomp.downcase
      break if Move::VALUES.include? choice
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end

  def update_history
    @move_history.push(move.to_s)
  end
end

module Personalities
  def r2d2_choose(human)
    r2_choices = ['rock', 'paper', 'paper']
    self.move = if !human.move_history.empty? &&
                   !!preferred_move_beater(human.move_history)
                  Move.new(preferred_move_beater(human.move_history))
                else
                  Move.new(r2_choices.sample)
                end
  end

  def preferred_move_beater(move_history)
    if move_history.count('scissors') / move_history.length.to_f > 0.50
      'rock'
    elsif move_history.count('rock') / move_history.length.to_f > 0.50
      'paper'
    elsif move_history.count('paper') / move_history.length.to_f > 0.50
      'scissors'
    end
  end

  def hal_choose
    hal_choices = ['paper', 'paper', 'scissors']
    self.move = Move.new(hal_choices.sample)
  end

  def psych_prof_choose(human)
    self.move = if move && (human.move > move)
                  Move.new(previous_move_beater(human.move.to_s))
                elsif move && (human.move < move)
                  Move.new(human.move.to_s)
                else
                  Move.new(Move::VALUES.sample)
                end
  end

  def previous_move_beater(prev_move)
    if prev_move == 'rock'
      'paper'
    elsif prev_move == 'paper'
      'scissors'
    elsif prev_move == 'scissors'
      'rock'
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

class Computer < Player
  include Personalities
  include Display

  def set_name
    puts <<~MSG
      Which opponent would you like to play?
      Please enter the corresponding number.
    MSG
    opponents = ['R2D2', 'Hal', 'Psych. Prof', 'Sonny', 'Number 5']
    opponents.each_with_index { |name, index| puts "#{index + 1}. #{name}" }

    num_opponent = ''
    loop do
      num_opponent = gets.chomp.to_i - 1
      break if (0..(opponents.length - 1)).cover? num_opponent
      puts "Please enter a number between 1 and #{opponents.length}."
    end
    self.name = opponents[num_opponent]
  end

  def choose(human)
    result = case name
             when 'R2D2' then r2d2_choose(human)
             when 'Hal' then hal_choose
             when 'Psych. Prof' then psych_prof_choose(human)
             when 'Sonny' then sonny_choose(human)
             when 'Number 5' then num5_choose
             end
    result
  end
end

class RPSGame
  include Display
  MATCH_WINNING_SCORE = 5

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def line_break
    puts "------------------------------"
  end

  def display_welcome_message
    clear_screen
    puts "Welcome to Rock, Paper, Scissors!"
    puts "This match will be best out of #{MATCH_WINNING_SCORE} rounds."
    puts "Please press enter to begin."
    gets
    clear_screen
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors. Good bye!"
  end

  def play_round
    make_moves
    display_moves
    display_winner
    update_scores
    display_scores
  end

  def make_moves
    computer.choose(human)
    human.choose
    human.update_history
  end

  def display_moves
    puts "#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    human_move = human.move
    if human_move > computer.move
      puts "#{human.name} won!"
    elsif human_move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie."
    end
    line_break
  end

  def update_scores
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    end
  end

  def reset_info
    human.score = 0
    computer.score = 0
    human.move_history = []
  end

  def display_scores
    puts <<~MSG
    Score: #{human.name} has #{human.score} point(s)
           #{computer.name} has #{computer.score} point(s).
    MSG
    line_break
  end

  def start_next_round
    puts "Please press enter to start the next round."
    gets
    clear_screen
  end

  def match_winner?
    human.score == MATCH_WINNING_SCORE || computer.score == MATCH_WINNING_SCORE
  end

  def change_opponent
    answer = ''
    loop do
      puts "Would you like to play a different opponent? (y/n)"
      answer = gets.chomp
      break if %w(yes no y n).include? answer.downcase
      puts "Sorry, must be yes or no."
    end
    computer.set_name if answer.downcase.start_with? 'y'
  end

  def display_match_winner
    line_break
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
      break if %w(yes no y n).include? answer.downcase
      puts "Sorry, must be yes or no."
    end

    return false if answer.downcase.start_with? 'n'
    return true if answer.downcase.start_with? 'y'
  end

  def play
    display_welcome_message

    loop do
      loop do
        play_round
        break if match_winner?
        start_next_round
      end

      display_match_winner
      reset_info
      break unless play_again?
      change_opponent
    end

    display_goodbye_message
  end
end

RPSGame.new.play
