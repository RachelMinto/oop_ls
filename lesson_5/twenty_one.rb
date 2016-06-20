
# frozen_string_literal: true

require 'colorize'

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

  def show_total
    puts "#{name} has a total of #{total} points."
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

  def hit(participant)
    card = deal(participant)
    puts "#{participant.name} has been dealt the #{card.value} of #{card.suit}."
  end

  def deal(player)
    card = ''
    loop do
      card = deck.cards.sample
      break unless deck.dealt_cards.include? card
    end
    deck.dealt_cards.push(card)
    player.hand.push(card)
    card
  end

  def take_turn(player_total)
    if total < 17 || total < player_total
      hit(self)
      puts "Please press enter to continue."
      gets.chomp
    else
      stay
    end
  end
end

class Deck
  attr_accessor :cards, :dealt_cards
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
    end
    self.cards = cards
    self.dealt_cards = []
  end
end

class Card
  attr_reader :suit, :value, :color

  def initialize(suit, value)
    @suit = suit
    @value = value
    @color = %w(Diamonds Hearts).include?(suit) ? "red" : "black"
  end
end

module Display
  def display_welcome_message
    clear_screen
    puts "Welcome to Twenty-One, #{player.name}!"
    puts "#{dealer.name} will be your dealer today."
    puts ""
    sleep(2.3)
  end

  def display_game_state(show_dealer_card_2 = true)
    clear_screen
    display_hands(Game::LINE_WIDTH, show_dealer_card_2)
  end

  def display_result
    player_total = player.total
    dealer_total = dealer.total
    display_game_state
    puts ""
    puts "Wow! You got 21 points right on. Good job!" if player_total == 21
    if dealer.busted?
      puts "The dealer has busted with #{dealer_total} points so you win!"
    elsif player.busted?
      puts "You have busted with #{player_total} points so the dealer wins!"
    else
      compare_total_points(player_total, dealer_total)
    end
  end

  def display_total
    puts ""
    puts "Your cards total to #{player.total} points."
    puts ""
  end

  def display_end_message
    puts ""
    puts "Thank you for playing Twenty-One. Goodbye."
    sleep(2.1)
    clear_screen
  end

  private

  def clear_screen
    system('clear') || system('cls')
  end

  def show_cards(participant, show_all_cards=true)
    described_cards = []
    cards = participant.hand
    if show_all_cards
      cards.each do |card|
        color = card.color.to_sym
        described_cards << "#{card.value} of #{card.suit}".colorize(color)
      end
    else
      color = cards.first.color.to_sym
      described_cards.push("#{cards.first.value} of #{cards.first.suit}".colorize(color))
      described_cards.push("Hidden card".colorize(:black))
    end
    described_cards
  end

  def display_hands(width, show_dealer_card_2)
    display_player_titles(width - 28)
    display_player_cards(width, show_dealer_card_2)
    puts ""
    puts "*  *  *  *  *  *  *".center(width - 28)
    puts ""
  end

  def display_player_cards(width, show_dealer_card_2)
    small_hand_size = find_smallest_hand
    display_equal_number_of_cards(width, small_hand_size, show_dealer_card_2)
    player_cards = player.hand
    dealer_cards = dealer.hand
    display_extra_cards(width - 14, small_hand_size, player_cards, dealer_cards)
  end

  def display_player_titles(width)
    dealer_title = "#{dealer.name}'s cards:"
    player_title = "#{player.name}'s cards:"
    puts player_title.ljust(width / 2) + dealer_title.rjust(width / 2)
  end

  def display_equal_number_of_cards(width, small_hand_size, show_dealer_card_2)
    i = 0
    while i < small_hand_size
      puts show_cards(player)[i].ljust(width / 2) +
           show_cards(dealer, show_dealer_card_2)[i].rjust(width / 2)
      i += 1
    end
  end

  def display_extra_cards(width, small_hand_size, player_cards, dealer_cards)
    player_cards_length = player_cards.length
    dealer_cards_length = dealer_cards.length
    if player_cards_length > small_hand_size
      puts show_cards(player)[small_hand_size..player_cards_length]
    elsif dealer_cards_length > small_hand_size
      show_cards(dealer)[small_hand_size..dealer_cards_length].each do |card|
        puts card.rjust(width)
      end
    end
  end
end

class Game
  include Display
  attr_accessor :player, :dealer, :deck
  LINE_WIDTH = 84

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

  private

  def deal_cards
    2.times do
      dealer.deal(player)
      dealer.deal(dealer)
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
      answer = hit_stay_or_total
      case answer
      when /^h/ then dealer.hit(player)
      when /^s/ then player.stay
      when /^t/ then display_total_score = true
      end
    end
  end

  def find_smallest_hand
    player_hand_size = player.hand.length
    dealer_hand_size = dealer.hand.length
    player_hand_size < dealer_hand_size ? player_hand_size : dealer_hand_size
  end

  def hit_stay_or_total
    puts ""
    answer = ''
    loop do
      puts "Would you like to hit, stay or view your current total? (h/s/t)"
      answer = gets.chomp.downcase
      break if %w(hit stay total h s t).include? answer
      puts "I'm sorry, you must reply with either hit, stay or total."
    end
    answer
  end

  def dealer_turn
    unless player.busted?
      loop do
        display_game_state
        dealer.take_turn(player.total)
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
end

twenty_one = Game.new
twenty_one.play
