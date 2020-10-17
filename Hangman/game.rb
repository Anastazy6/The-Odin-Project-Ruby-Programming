# frozen_string_literal: true

# Initializes each game with given settings and runs the main game loop.
class Game
  attr_reader :allowed_words, :current_round, :max_word_length, :min_word_length,
              :misses_available, :player1, :player2, :settings, :total_rounds

  include SharedMethods
  include MessagesForGame

  def initialize(settings)
    @max_word_length = settings[:max_word_length]
    @min_word_length = settings[:min_word_length]
    @allowed_words = load_dictionary
    @player1 = human?(1, settings) ? Human.new(1, settings) : Computer.new(1, settings)
    @player2 = human?(2, settings) ? Human.new(2, settings) : Computer.new(2, settings)
    @misses_available = settings[:misses_available]
    @current_round = 1
    @total_rounds = settings[:number_of_rounds].to_i * 2
  end

  def main_loop
    puts 'Goodbye cruel world!'.colorize(:red)
    start_round until current_round > total_rounds
    winner =
      case player1.score <=> player2.score # Just like in Mastermind: lower score is better.
      when -1 then player1
      when 0 then :draw
      when 1 then player2
      else raise TheProgrammerIsStupidError
      end
    print_winner(winner)
  end

  private

  def human?(player_id, settings)
    player_symbol = "player_#{player_id}_type".to_sym
    settings[player_symbol] == :human
  end

  def load_dictionary
    words = []
    File.open('data/dictionary.txt').readlines.each do |word|
      words << word.strip.downcase if word.strip.length.between?(min_word_length, max_word_length)
    end
    words
  end

  def prepare_next_round
    print_score(player1, player2)
    @current_round += 1
    player1.reset_memory if player1.is_a?(Computer)
    player2.reset_memory if player2.is_a?(Computer)
  end

  def start_round
    Round.new(executioner, prisoner, misses_available, current_round, allowed_words).play_round
    round_finished(current_round)
    prepare_next_round
  end

  def executioner
    current_round.odd? ? player1 : player2
  end

  def prisoner
    current_round.even? ? player1 : player2
  end
end
