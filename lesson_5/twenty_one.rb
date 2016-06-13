
class Participant
  attr_accessor :hand, :total
  def initialize
    @total = 0
    @hand = []
  end

  def stay
    puts "You have chosen to stay with a total of #{total}."
  end

  def busted?

  end
  
  def show_cards(show_all_cards=true)
    if show_all_cards
      hand.each { |card| puts "#{card.value} of #{card.suit}" }
    else
      puts "#{hand.first.value} of #{hand.first.suit} and one unknown card."
    end
  end
end

class Player < Participant
  def initialize
    super
  end
  
end

class Dealer < Participant
  attr_accessor :deck
  
  def initialize(deck)
    super()
    @deck = deck
  end
  
  def hit(participant)
    card = deal(participant)
    puts "You have chosen to hit and have been dealt the #{card.value} of #{card.suit}."
  end

  def stay

  end

  def deal(player)
    card = @deck.cards.sample
    deck.dealt_cards.push(card)
    player.hand.push(card)
    return card
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
  attr_accessor :player, :dealer, :deck

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new(@deck)
  end

  def play
    display_welcome_message
    deal_cards
    display_initial_cards
    player_turn
    # dealer_turn
    # display_result
  end

  def deal_cards
    dealer.deal(player)
    dealer.deal(player)
    dealer.deal(dealer)
    dealer.deal(dealer)
  end
  
  def display_initial_cards
    player.show_cards(true)
    dealer.show_cards(false)
  end
  
  def player_turn
    loop do
      answer = ''
      unless player.busted?
        loop do
          puts "Would you like to hit or stay?"
          answer = gets.chomp.downcase
          break if %w(hit stay h s).include? answer
          puts "I'm sorry, you must reply with either hit or stay."
        end
        answer.start_with?('h') ? dealer.hit(player) : player.stay
      end
    end
  end
end

twenty_one = Game.new
twenty_one.play