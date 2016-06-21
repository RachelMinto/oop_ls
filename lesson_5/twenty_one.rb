
# frozen_string_literal: true

require 'pry'

class Participant
  MAX_ALLOWED_POINTS = 21
  attr_accessor :hand
  attr_reader :name

  def initialize
    @total = 0
    @hand = []
    @turn_complete = false
    set_name
  end

  def busted?
    total > MAX_ALLOWED_POINTS
  end

  def stayed?
    @turn_complete
  end

  def stay
    puts "#{name} has chosen to stay with a total of #{total} points."
    @turn_complete = true
  end

  def title
    "#{name}'s cards:"
  end

  def score
    "#{name}'s total: #{total}"
  end

  def show_cards(show_all_cards=true)
    described_cards = []
    if show_all_cards
      hand.each do |card|
        described_cards << card.to_s
      end
    else
      described_cards.push(hand.first.to_s)
      described_cards.push("Hidden card")
    end
    described_cards
  end

  def total
    sum = 0

    hand.each do |card|
      sum += if card.value == "Ace"
               11
             elsif card.value.to_i == 0
               10
             else
               card.value.to_i
             end
    end

    hand.each.select { |card| card.value == "Ace" }.count.times do
      sum -= 10 if sum > MAX_ALLOWED_POINTS
    end
    sum
  end

  def turn_over?
    busted? || stayed?
  end

  def reset
    @total = 0
    self.hand = []
    @turn_complete = false
  end
end

class Player < Participant
  def initialize
    super
  end

  def set_name
    system('clear') || system('cls')
    name = ''
    puts "Hello, what is your name?"
    loop do
      name = gets.chomp.to_s
      break unless name.strip.empty? || name.length > 17
      puts "Sorry, your name must be between 1 and 17 characters long."
    end
    @name = name
  end
end

class Dealer < Participant
  attr_accessor :deck

  def initialize(deck)
    super()
    @deck = deck
  end

  def set_name
    @name = ['Jane Austen', 'George Eliot', 'Charles Dickens'].sample
  end
end

class Deck
  attr_accessor :cards
  SUITS = ['Hearts', 'Diamonds', 'Spades', 'Clubs'].freeze
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10'] +
           ['Jack', 'Queen', 'King', 'Ace']

  def initialize
    reset
  end

  def reset
    cards = []
    SUITS.each do |suit|
      VALUES.each do |value|
        card = Card.new(suit, value)
        cards << card
      end
      cards.shuffle!
    end
    self.cards = cards
  end

  def deal_card
    cards.pop
  end

  def hit(participant)
    card = deal_card
    participant.hand.push(card)
    yield if block_given?
    puts "#{participant.name} has been dealt the #{card.to_s}."
  end
end

class Card
  attr_reader :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def to_s
    "#{value} of #{suit}"
  end
end

module TwoColumnDisplay
  def display_hands(show_dealer_card_2)
    display_player_titles
    display_player_cards(show_dealer_card_2)
  end

  def display_line_break
    puts ""
    puts "*  *  *  *  *  *  *".center(Game::LINE_WIDTH)
    puts ""
  end

  def display_player_cards(show_dealer_card_2)
    small_hand_size = find_smallest_hand
    display_equal_number_of_cards(small_hand_size, show_dealer_card_2)
    display_extra_cards(small_hand_size)
  end

  def find_smallest_hand
    player_hand_size = player.hand.length
    dealer_hand_size = dealer.hand.length
    player_hand_size < dealer_hand_size ? player_hand_size : dealer_hand_size
  end

  def display_player_titles
    width = Game::LINE_WIDTH
    puts player.title.ljust(width / 2) + dealer.title.rjust(width / 2)
  end

  def display_equal_number_of_cards(small_hand_size, show_dealer_card_2)
    i = 0
    while i < small_hand_size
      puts player.show_cards[i].ljust(Game::LINE_WIDTH / 2) +
           dealer.show_cards(show_dealer_card_2)[i].rjust(Game::LINE_WIDTH / 2)
      i += 1
    end
  end

  def display_extra_cards(small_hand_size)
    player_cards_length = player.hand.length
    dealer_cards_length = dealer.hand.length
    if player_cards_length > small_hand_size
      puts player.show_cards[small_hand_size..player_cards_length]
    else
      dealer.show_cards[small_hand_size..dealer_cards_length].each do |card|
        puts card.rjust(Game::LINE_WIDTH)
      end
    end
  end

  def display_current_scores
    width = Game::LINE_WIDTH
    puts player.score.ljust(width / 2) + dealer.score.rjust(width / 2)
  end
end

class Game
  include TwoColumnDisplay
  attr_accessor :player, :dealer, :deck
  LINE_WIDTH = 64

  def initialize
    self.deck = Deck.new
    self.player = Player.new
    self.dealer = Dealer.new(deck)
  end

  def play
    display_welcome_message
    loop do
      deal_cards
      player_turn
      dealer_turn
      display_result
      break unless play_again?
      reset_information
    end
    display_end_message
  end

  def display_game_state(show_dealer_card_2 = true)
    clear_screen
    display_hands(show_dealer_card_2)
    puts ""
    display_current_scores
    display_line_break
  end

  private

  def display_welcome_message
    clear_screen
    puts "Welcome to Twenty-One, #{player.name}!"
    puts "#{dealer.name} will be your dealer today."
    puts ""
    sleep(2.3)
  end

  def deal_cards
    2.times do
      player.hand.push(deck.deal_card)
      dealer.hand.push(deck.deal_card)
    end
  end

  def player_turn
    display_total_score = false
    loop do
      display_game_state(false)
      break if player.turn_over?
      if display_total_score
        display_total
        display_total_score = false
      end
      answer = hit_or_stay
      if answer.start_with?('h')
        deck.hit(player) {display_game_state(false)}
      else
        player.stay
      end
    end
  end

  def hit_or_stay
    puts ""
    answer = ''
    loop do
      puts "Would you like to hit or stay? (h/s)"
      answer = gets.chomp.downcase
      break if %w(hit stay h s).include? answer
      puts "I'm sorry, you must reply with either hit or stay."
    end
    answer
  end

  def dealer_turn
    unless player.busted?
      loop do
        display_game_state
        if dealer.total < 17 || dealer.total < player.total 
          deck.hit(dealer) {display_game_state}
          puts "Press enter to continue."
          gets.chomp
        else
          dealer.stay
        end
        break if dealer.turn_over?
      end
    end
  end

  def compare_total_points(player_total, dealer_total)
    puts "Your total is #{player_total} and the dealer has #{dealer_total}."
    if player_total > dealer_total then puts "You win!"
    elsif player_total < dealer_total then puts "#{dealer.name} wins!"
    else puts "It's a tie!"
    end
  end

  def display_result
    player_total = player.total
    dealer_total = dealer.total
    display_game_state
    puts "Wow! You got 21 points right on. Nice" if player_total == 21
    if dealer.busted?
      puts "The dealer has busted with #{dealer_total} points so you win!"
    elsif player.busted?
      puts "You have busted with #{player_total} points so the dealer wins!"
    else
      compare_total_points(player_total, dealer_total)
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n yes no).include? answer
      puts "Sorry, must be y or n"
    end
    answer.start_with? 'y'
  end

  def reset_information
    deck.reset
    player.reset
    dealer.reset
  end

  def display_end_message
    puts ""
    puts "Thank you for playing Twenty-One. Goodbye."
    sleep(2.1)
    clear_screen
  end

  def clear_screen
    system('clear') || system('cls')
  end
end

twenty_one = Game.new
twenty_one.play
