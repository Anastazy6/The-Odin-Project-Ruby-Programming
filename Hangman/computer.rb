# frozen_string_literal: true

# Computer player.
class Computer < Player
  attr_accessor :unused_letters

  def initialize(id, settigns)
    super
    @name = "Player #{id} (AI)".colorize(color)
    @unused_letters = ('A'..'Z').to_a
  end

  def choose_secret_word(allowed_words)
    word = allowed_words.select { |w| w.length.between?(min_word_length, max_word_length) }.sample
    SecretWord.new(word)
  end

  def reset_memory
    @unused_letters = ('A'..'Z').to_a
  end

  def make_guess
    guess = unused_letters.sample
    unused_letters.delete(guess)
    guess
  end
end
