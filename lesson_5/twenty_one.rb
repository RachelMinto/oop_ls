require 'pry'

class Participant
  attr_accessor :hand
  def initialize
    @total = 0
    @hand = []
  end

  def hit

  end

  def stay

  end

  def busted?

  end

  def total

  end
end

class Player < Participant
  def initialize
    super
  end
end

class Dealer < Participant
  def initialize(deck)
    super()
    @deck = deck
  end

  def stay

  end

  def deal(player)
    card = @deck.cards.sample
    @deck.dealt_cards.push(card)
    player.hand.push(card)
    puts "I've dealt a #{card.value} of #{card.suit} to #{player}"
  end
end

class Deck
  attr_accessor :cards, :dealt_cards
  SUITS = ['Hearts', 'Diamonds', 'Spades', 'Clubs']
  VALUES = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King', 'Ace']

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
    puts "Welcome to Twenty-One!"
  end
end

class Game
  include Display

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new(@deck)
  end

  def play
    display_welcome_message
    deal_cards
    # display_initial_cards
    # player_turn
    # dealer_turn
    # display_result
  end

  def deal_cards
    @dealer.deal(@player)
    @dealer.deal(@player)
    @dealer.deal(@dealer)
    @dealer.deal(@dealer)
  end
end

twenty_one = Game.new
twenty_one.play