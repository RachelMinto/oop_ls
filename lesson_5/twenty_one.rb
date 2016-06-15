
# frozen_string_literal: true

# To do: set up nice playing screen. Clear. List player cards. Colorize.
# Don't clear until pressing enter after welcome. 
# Don't let dealer hit if it busts.

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
    self.total > MAX_ALLOWED_POINTS
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
    hand.each { |card| cards << [card.value, card.suit] }
    cards
  end

  def show_cards(show_all_cards=true)
    described_cards = []
    cards = cards_in_array
    if show_all_cards
      cards.each { |value, suit| described_cards << "#{value} of #{suit}" }
    else
      described_cards.push("#{cards[0][0]} of #{cards[0][1]}")
      described_cards.push("Hidden card")
    end
    described_cards
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
    puts ''
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
  attr_reader :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end
end

module Display
  def display_welcome_message
    clear
    puts "Welcome to Twenty-One, #{player.name}!"
    puts "#{dealer.name} will be your dealer today."
    puts ""
    sleep(1.8)
  end

  # def display_initial_cards
  #   player.show_cards(true)
  #   dealer.show_cards(false)
  #   puts "please press Enter to continue."
  #   gets.chomp
  # end

  def display_game_state
    clear
    width = Game::LINE_WIDTH
    display_hands(width)
  end

  def display_hands(width)
    display_player_titles(width)
    display_player_cards(width)
    puts ""
    puts "*  *  *  *  *  *  *".center(width)
    puts ""
  end

  def display_player_titles(width)
    dealer_title = "#{dealer.name}'s cards:"
    player_title = "#{player.name}'s cards:"
    puts player_title.ljust(width / 2) + dealer_title.rjust(width / 2)
  end

  def display_player_cards(width)
    player_cards = player.cards_in_array
    dealer_cards = dealer.cards_in_array
    shortest_length = player_cards.length < dealer_cards.length ? player_cards.length : dealer_cards.length
    i = 0
    while i < shortest_length
      puts player.show_cards[i].ljust(width / 2) + dealer.show_cards(false)[i].rjust(width / 2)
      i += 1
    end
    if player_cards.length > shortest_length
      puts player.show_cards[shortest_length..player_cards.length]
    elsif dealer_cards.length > shortest_length
      puts dealer.show_cards[shortest_length..player_cards.length]
    end
  end

  def display_result
    puts ""
    if dealer.busted?
      puts "The dealer has busted so you win!"
    elsif player.busted?
      puts "You have busted so the dealer wins!"
    else
      puts "Your total is #{player.total} and the dealer has #{dealer.total}."
    end
  end

  def clear
    system('clear') || system('cls')
  end
end

class Game
  include Display
  attr_accessor :player, :dealer, :deck
  LINE_WIDTH = 64

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new(@deck)
  end

  def play
    display_welcome_message
    deal_cards
    # display_initial_cards
    player_turn
    dealer_turn
    display_result
  end

  def deal_cards
    dealer.deal(player)
    dealer.deal(player)
    dealer.deal(dealer)
    dealer.deal(dealer)
  end

  def player_turn
    loop do
      display_game_state
      break if player.busted? || player.stayed?
      answer = hit_stay_or_total
      case answer
      when /^h/ then dealer.hit(player)
      when /^s/ then player.stay
      when /^t/ then
        puts ""
        puts "Your cards total to #{player.total} points."
        puts "Please press enter to continue."
        gets.chomp
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
    loop do 
      if dealer.total < 17 || dealer.total < player.total
        dealer.hit(dealer) unless player.busted?
      end
      break if dealer.busted?
    end
  end
end

twenty_one = Game.new
twenty_one.play
