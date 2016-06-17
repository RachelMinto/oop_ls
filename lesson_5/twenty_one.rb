
# frozen_string_literal: true

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

  def cards_in_array
    cards = []
    hand.each { |card| cards << [card.value, card.suit, card.color] }
    cards
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
      name = gets.chomp
      break unless name.to_s.strip.empty? || name.to_s.length > 17
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
      card = @deck.cards.sample
      break unless deck.dealt_cards.include? card
    end
    deck.dealt_cards.push(card)
    player.hand.push(card)
    card
  end
end

class Deck
  attr_accessor :cards, :dealt_cards
  SUITS = ['Hearts', 'Diamonds', 'Spades', 'Clubs'].freeze
  VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10'] +
           ['Jack', 'Queen', 'King', 'Ace']

  def initialize
    cards = []
    SUITS.each do |suit|
      VALUES.each do |value|
        card = Card.new(suit, value)
        cards << card
      end
    end
    @cards = cards
    @dealt_cards = []
  end

  def to_s
    "#{cards}"
  end
end

class Card
  attr_reader :suit, :value, :color

  def initialize(suit, value)
    @suit = suit
    @value = value
    @color = suit == "Diamonds" || suit == "Hearts" ? "red" : "black"
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

  def show_cards(participant, show_all_cards=true)
    described_cards = []
    cards = participant.cards_in_array
    if show_all_cards
      cards.each do |value, suit, color| 
        described_cards << "#{value} of #{suit}".send("#{color}")
      end
    else
      described_cards.push("#{cards[0][0]} of #{cards[0][1]}".send("#{cards[0][2]}"))
      described_cards.push("Hidden card".send("black"))
    end
    described_cards
  end

  def display_game_state(show_dealer_card_2 = true)
    clear_screen
    width = Game::LINE_WIDTH
    display_hands(width, show_dealer_card_2)
  end

  def display_hands(width, show_dealer_card_2)
    display_player_titles(width - 18)
    display_player_cards(width, show_dealer_card_2)
    puts ""
    puts "*  *  *  *  *  *  *".center(width)
    puts ""
  end

  def display_player_titles(width)
    dealer_title = "#{dealer.name}'s cards:"
    player_title = "#{player.name}'s cards:"
    puts player_title.ljust(width / 2) + dealer_title.rjust(width / 2)
  end

  def display_player_cards(width, show_dealer_card_2)
    small_hand_size = find_smallest_hand
    display_equal_number_of_cards(width, small_hand_size, show_dealer_card_2)
    display_extra_cards(width - 9, small_hand_size)
  end

  def display_equal_number_of_cards(width, small_hand_size, show_dealer_card_2)
    i = 0
    while i < small_hand_size
      puts show_cards(player)[i].ljust(width / 2) + 
      show_cards(dealer, show_dealer_card_2)[i].rjust(width / 2)
      i += 1
    end
  end

  def display_extra_cards(width, small_hand_size)
    player_cards = player.cards_in_array
    dealer_cards = dealer.cards_in_array
    if player_cards.length > small_hand_size
      puts show_cards(player)[small_hand_size..player_cards.length]
    elsif dealer_cards.length > small_hand_size
      show_cards(dealer)[small_hand_size..dealer_cards.length].each do |card|
        puts card.rjust(width)
      end
    end
  end

  def find_smallest_hand
    player_hand_size = player.cards_in_array.length
    dealer_hand_size = dealer.cards_in_array.length
    player_hand_size < dealer_hand_size ? player_hand_size : dealer_hand_size
  end

  def display_result
    display_game_state
    puts ""
    if dealer.busted?
      puts "The dealer has busted with #{dealer.total} points so you win!"
    elsif player.busted?
      puts "You have busted with #{player.total} points so the dealer wins!"
    else
      puts "Your total is #{player.total} and the dealer has #{dealer.total}."
      if player.total > dealer.total then puts "You win!"
      elsif player.total < dealer.total then puts "#{dealer.name} wins!"
      else puts "It's a tie!"
      end
    end
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def display_end_message
    puts ""
    puts "Thank you for playing Twenty-One. Goodbye."
    puts ""
  end
end

class String
  def red
    "\e[31m#{self}\e[0m"
  end

  def black
    "\e[40m#{self}\e[0m"
  end
end

class Game
  include Display
  attr_accessor :player, :dealer, :deck
  LINE_WIDTH = 84

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new(@deck)
  end

  def play
    display_welcome_message
    loop do
      deal_cards
      player_turn
      dealer_turn
      display_result
      break unless play_again?
      # reset_information
    end
    display_end_message
  end

  def deal_cards
    dealer.deal(player)
    dealer.deal(player)
    dealer.deal(dealer)
    dealer.deal(dealer)
  end

  def player_turn
    loop do
      display_game_state(false)
      break if player.busted? || player.stayed?
      answer = hit_stay_or_total
      case answer
      when /^h/ then dealer.hit(player)
      when /^s/ then player.stay
      when /^t/ then
        puts ""
        puts "Your cards total to #{player.total} points."
        press_enter_to_continue
      end
    end
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
        if dealer.total < 17 || dealer.total < player.total
          dealer.hit(dealer)
          press_enter_to_continue
        else
          dealer.stay
        end
        break if dealer.busted? || dealer.stayed?
      end
    end
  end

  def press_enter_to_continue
    puts "Please press enter to continue."
    gets.chomp
  end
  
  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n yes no).include? answer
      puts "Sorry, must be y or n"
    end
    answer
  end
end

twenty_one = Game.new
twenty_one.play
