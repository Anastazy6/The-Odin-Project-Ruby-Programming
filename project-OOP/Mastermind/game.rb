# frozen_string_literal: true

# Contains variables that will be set to a certain value after each game start,
#   defaults and methods that don't fit the other, more specific classes.
class Game
  attr_reader :code_length, :current_round, :current_guess, :max_guesses,
              :player1, :player2, :rounds, :verbose, :winner

  def initialize(settings)
    @code_length = settings[:code_length]
    @max_guesses = settings[:guesses]
    @rounds = settings[:rounds] * 2
    @verbose = settings[:verbose]

    @player1 = human_wants_to_start? ? Human.new(settings) : Computer.new(settings)
    @player2 = human_starts? ? Computer.new(settings) : Human.new(settings)

    @current_round = 1
    @current_guess = 1
  end

  include FormattedCurrentRound

  def human_starts?
    return true if player1.is_a?(Human)

    false
  end

  def human_wants_to_start?
    puts 'Good mourning! As the human player, you are given the opportunity to '\
      'choose whether you want to guess first. '\
      "Type 'yes' if so, else type 'no'.".colorize(:green)
    force_valid_yes_or_no_input
  end

  # This is where the entire game is in.
  def game_loop
    start_round until current_round > rounds
    # Score is detrimental: the less you gain, the better
    winner =
      case player1.score <=> player2.score
      when -1 then player1
      when 0 then :draw
      when 1 then player2
      else raise TheProgrammerIsStupidError
      end
    print_winner(winner)
  end

  private

  def prepare_next_round
    @current_round += 1
    puts  "#{player1}'s score: #{player1.score}.\n"\
          "#{player2}'s score: #{player2.score}.\n"\
          "Remember: less is better!\n\n"
  end

  def print_winner(winner)
    return puts "It's a draw!".colorize(:blue) if winner == :draw

    puts "#{winner} wins!"
  end

  def start_round
    Round.new(the_maker, the_guesser, max_guesses, current_round).play_the_round(verbose)

    puts "Round #{formatted_current_round} finished!".colorize(:green)
    prepare_next_round
  end

  def the_guesser
    current_round.odd? ? player1 : player2
  end

  def the_maker
    current_round.even? ? player1 : player2
  end
end
