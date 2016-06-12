
class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  attr_accessor :squares

  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def empty?
    unmarked_keys.count == 9
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def at_risk_square(case_marker)
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      next unless two_case_markers_and_blank?(squares, case_marker)
      at_risk = line.select do |num|
        @squares[num].marker == Square::INITIAL_MARKER
      end
      return at_risk[0]
    end
    nil
  end

  def get_new_state(square, marker)
    new_squares = @squares.dup
    new_squares[square].marker = marker
    new_squares
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end

  def two_case_markers_and_blank?(squares, case_marker)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.count(case_marker) != 2
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " ".freeze

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def marked_with?
    marker == "X"
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :name
  attr_accessor :marker, :score

  def initialize
    @score = Score.new
    set_name
  end
end

class Human < Player
  def initialize
    super()
    set_marker
  end

  def set_name
    name = ''
    puts "Hello, what is your name?"
    loop do
      name = gets.chomp
      break unless name.to_s.strip.empty?
      puts "Sorry, you must enter a value."
    end
    @name = name
  end

  def set_marker
    marker = ''
    puts "Which marker would you like to use? Please enter one character."
    loop do
      marker = gets.chomp
      break unless marker.to_s.strip.length != 1
      puts "Sorry, you must enter one letter, symbol, or number."
    end
    @marker = marker
  end
end

class Computer < Player
  def initialize(m)
    super()
    @marker = m
  end

  def set_name
    @name = ['Elizabeth Bennet', 'Fanny Price', 'Fitzwilliam Darcy'].sample
  end
end

class Score
  attr_accessor :value

  def initialize
    @value = 0
  end

  def update
    self.value += 1
  end

  def reset
    self.value = 0
  end

  def to_s
    self.value
  end
end

module Display
  private

  def display_welcome_message
    puts <<~MSG
    #{human.name}, welcome to Tic Tac Toe!
    Today you will be playing against #{computer.name}.
    The first person to win #{TTTGame::WINNING_SCORE} rounds wins the match.

    MSG
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_player_info
    comp_name = computer.name
    hum_points = human.score.value
    comp_points = computer.score.value

    puts <<~MSG
    You're a #{human.marker}. #{comp_name} is a #{computer.marker}.
    You have #{hum_points} points and #{comp_name} has #{comp_points} points.
    MSG
  end

  def display_board
    puts ""
    board.draw
    puts ""
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_match_winner
    case board.winning_marker
    when human.marker
      puts "You won the match!"
    when computer.marker
      puts "#{computer.name} won the match!"
    end
  end

  def clear
    system "clear"
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

class TTTGame
  include Display
  FIRST_TO_MOVE = 'choose'.freeze # Can set to human.marker or computer.marker
  WINNING_SCORE = 3

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Human.new
    @computer = @human.marker == 'O' ? Computer.new('X') : Computer.new('O')
    @current_marker = FIRST_TO_MOVE
  end

  def play
    clear
    display_welcome_message

    loop do
      play_match
      display_match_winner
      break unless play_again?
      reset_board
      display_play_again_message
      reset_score
    end

    display_goodbye_message
  end

  private

  def play_match
    loop do
      display_player_info
      display_board

      loop do
        current_player_moves
        break if board.someone_won? || board.full?
        clear_screen_and_display_board
      end

      update_score
      break if match_winner?
      display_result
      start_next_round
      reset_board
    end
    display_board
  end

  def determine_who_starts
    answer = validate_yes_no_answer("Would you like to begin? (y/n)")
    @current_marker = answer[0] == 'y' ? human.marker : computer.marker
  end

  def joinor(array, seperator=', ', conjunction='or ')
    return array if array.length == 1
    joined_string = ''
    array[0..-2].each { |key| joined_string << key.to_s + seperator }
    joined_string = joined_string + conjunction + array.last.to_s
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}):"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    square = board.empty? ? 5 : best_legal_move
    board[square] = computer.marker
  end

  def current_player_moves
    determine_who_starts if @current_marker == 'choose'
    @current_marker == human.marker ? human_moves : computer_moves
    alternate_marker
  end

  def alternate_marker
    h_marker = human.marker
    @current_marker = @current_marker == h_marker ? computer.marker : h_marker
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score.update
    when computer.marker
      computer.score.update
    end
  end

  def start_next_round
    puts "Please press enter to begin the next round."
    gets
  end

  def match_winner?
    human.score.value == WINNING_SCORE || computer.score.value == WINNING_SCORE
  end

  def play_again?
    answer = validate_yes_no_answer("Would you like to play again? (y/n)")
    answer.start_with? 'y'
  end

  def validate_yes_no_answer(question)
    answer = nil
    loop do
      puts question
      answer = gets.chomp.downcase
      break if %w(y n yes no).include? answer
      puts "Sorry, must be y or n"
    end
    answer
  end

  def reset_board
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def reset_score
    human.score.reset && computer.score.reset
  end

  def best_legal_move
    legal_moves_with_values = {}
    board.unmarked_keys.each do |node|
      board[node] = computer.marker
      value = minimax_strategy(0, computer.marker)
      board[node] = Square::INITIAL_MARKER
      legal_moves_with_values[node] = value
    end
    legal_moves_with_values.key(legal_moves_with_values.values.max)
  end

  def end_state_value(depth)
    case board.winning_marker
    when human.marker
      depth - 10
    when computer.marker
      10 - depth
    else
      0
    end
  end

  def max_strategy

  end

  def min_strategy

  end

  def alternate_test_marker(current_player_marker)
    current_player_marker == computer.marker ? human.marker : computer.marker
  end

  def minimax_strategy(depth, current_player_marker)
    return end_state_value(depth) if board.someone_won? || board.full?

    current_player_marker = alternate_test_marker(current_player_marker)

    if current_player_marker == computer.marker
      best_value = -100
      board.unmarked_keys.each do |child_node|
        board.squares[child_node].marker = current_player_marker
        current_score = minimax_strategy(depth + 1, current_player_marker)
        board.squares[child_node].marker = Square::INITIAL_MARKER
        best_value = best_value > current_score ? best_value : current_score
      end

    else
      best_value = 100
      board.unmarked_keys.each do |child_node|
        board.squares[child_node].marker = current_player_marker
        current_score = minimax_strategy(depth + 1, current_player_marker)
        board.squares[child_node].marker = Square::INITIAL_MARKER
        best_value = best_value < current_score ? best_value : current_score
      end
    end

    best_value
  end
end

game = TTTGame.new
game.play
