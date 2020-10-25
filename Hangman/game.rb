# frozen_string_literal: true

# Initializes each game with given settings and runs the main game loop.
class Game
  attr_reader :allowed_words, :current_round, :max_word_length, :min_word_length,
              :misses_available, :player1, :player_1_data, :player2, :player_2_data,
              :round, :round_data, :settings, :total_rounds

  include SharedMethods
  include MessagesForGame
  include Save
  include Load
  include MessagesForSave

  def initialize(settings, load_from = nil)
    @settings = load_from ? load_from[:game_data][:settings] : settings
    @max_word_length = settings[:max_word_length]
    @min_word_length = settings[:min_word_length]
    @allowed_words = load_dictionary
    @total_rounds = settings[:number_of_round_pairs].to_i * 2
    @misses_available = settings[:misses_available]
    load_from ? load_game(load_from) : create_new_game
  end

  def main_loop
    player_colors_message
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

  def create_new_game
    @player1 = make_player_and_set_type(1, settings, allowed_words)
    @player2 = make_player_and_set_type(2, settings, allowed_words)
    @current_round = 1
    @round_data = nil
    @player_1_data = nil
    @player_2_data = nil
  end

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

  def load_game(data)
    load_game_data(data)
    @round_data = data[:round_data]
    @player_1_data = data[:player_1_data]
    @player_2_data = data[:player_2_data]
  end

  def load_game_data(data)
    @player1 = make_player_and_set_type(1, settings, allowed_words, data)
    @player2 = make_player_and_set_type(2, settings, allowed_words, data)
    @current_round = data[:game_data][:current_round]
  end

  def make_player_and_set_type(id, settings, words, data = nil)
    data =
      if data
        id == 1 ? data[:player_1_data] : data[:player_2_data]
      end
    human?(id, settings) ? Human.new(id, settings, self, data) : Computer.new(id, settings, words, data)
  end

  def prepare_next_round
    print_score(player1, player2)
    @round_data = nil # Prevents infinite loading of the same round.
    @current_round += 1
    player1.reset_memory(allowed_words) if player1.is_a?(Computer)
    player2.reset_memory(allowed_words) if player2.is_a?(Computer)
  end

  def start_round
    @round = Round.new(executioner, prisoner, misses_available, current_round, allowed_words, @round_data)
    round.play_round
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
