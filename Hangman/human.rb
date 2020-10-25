# frozen_string_literal: true

# Human player.
class Human < Player
  attr_reader :the_game

  def initialize(id, settings, the_game, data = nil)
    super(id, settings, data)
    @the_game = the_game
    @score = data[:score] if data
  end

  include MessagesForHuman

  def choose_secret_word(allowed_words)
    secure_word_prompt_message(color)
    loop do
      secret_word = secure_gets.chomp.downcase
      return SecretWord.new(secret_word) if secret_word_valid?(allowed_words, secret_word)

      invalid_word_message(secret_word, allowed_words, max_word_length, min_word_length)
    end
  end

  def make_guess
    make_guess_message
    guess = gets.chomp
    return the_game.save_game if guess.downcase =~ /^save$/

    guess.upcase
  end

  def secret_word_valid?(allowed_words, secret_word)
    return false unless allowed_words.include?(secret_word)
    return false unless secret_word.length.between?(min_word_length, max_word_length)

    true
  end
end
