require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

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
      if two_case_markers_and_blank?(squares, case_marker)
        at_risk = line.select do |num| 
          @squares[num].marker == Square::INITIAL_MARKER
        end
        return at_risk[0]
      end
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
  INITIAL_MARKER = " "

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
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = Score.new
  end
end

class Computer < Player
  def initialize(marker)
    super(marker)
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

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = 'choose' #Can also set to HUMAN_MARKER or COMPUTER_MARKER
  WINNING_SCORE = 3

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Computer.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
  end

  def play
    clear
    display_welcome_message

    loop do
      loop do
        display_player_info
        display_board

        loop do
          current_player_moves
          break if board.someone_won? || board.full?
          clear_screen_and_display_board
        end

        update_score
        display_result
        break if match_winner?
        start_next_round
        reset_board
      end

      break unless play_again?
      reset_board
      display_play_again_message
      reset_score
    end

    display_goodbye_message
  end

  private

  def display_welcome_message
    puts <<~MSG
    Welcome to Tic Tac Toe!
    The first person to win #{WINNING_SCORE} rounds wins the match.

    MSG
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def determine_who_starts
    answer = validate_yes_no_answer("Would you like to begin? (y/n)")
    @current_marker = answer[0] == 'y' ? HUMAN_MARKER : COMPUTER_MARKER
  end

  def display_player_info
    puts <<~MSG
    You're a #{human.marker}. Computer is a #{computer.marker}.
    You have #{human.score.value} points 
    and the computer has #{computer.score.value} points.
    MSG
  end

  def display_board
    puts ""
    board.draw
    puts ""
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
    minimax_strategy(board)
  end

  def current_player_moves
    determine_who_starts if @current_marker == 'choose'
    @current_marker == HUMAN_MARKER ? human_moves : computer_moves  
    alternate_marker
  end

  def alternate_marker
    @current_marker = @current_marker == HUMAN_MARKER ? COMPUTER_MARKER : HUMAN_MARKER
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score.update
    when computer.marker
      computer.score.update
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
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

  def clear
    system "clear"
  end

  def reset_board
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def reset_score
    human.score.reset && computer.score.reset
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def determine_possible_score(board_state)
    case board.winning_marker
    when human.marker
      -10
    when computer.marker
      10
    else
      0
    end
  end

  def minimax_strategy(board_state)
    return determine_possible_score(board_state) if board_state.someone_won? || board_state.full?
    scores = []
    moves = []
    puts "Scores are: #{scores} and moves are: #{moves}"

    board_state.unmarked_keys.each do |potential_move|
      possible_board_state = Board.new
      possible_board_state.squares = board_state.get_new_state(potential_move, @current_marker)
      alternate_marker
      possible_board_state.draw
      scores.push minimax_strategy(possible_board_state)
      moves.push(potential_move)
      puts "Scores are NOW: #{scores} and moves are NOW: #{moves}"
    end

    if @current_marker = COMPUTER_MARKER
      max_score_index = scores.each_with_index.max[1]
      @choice = moves[max.score.index]
      return scores[max_score_index]
    else
      min_score_index = scores.each_with_index.min[1]
      @choice = moves[min.score_index]
      return scores[min_score_index]
    end
  end
end

game = TTTGame.new
game.play

