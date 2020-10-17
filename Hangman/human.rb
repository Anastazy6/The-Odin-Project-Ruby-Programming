# frozen_string_literal: true

# Human player.
class Human < Player
  def initialize(id, settings)
    super
  end

  include MessagesForHuman

  def choose_secret_word(allowed_words)
    secure_word_prompt_message
    loop do
      secret_word = secure_gets.chomp.downcase
      return SecretWord.new(secret_word) if secret_word_valid?(allowed_words, secret_word)

      invalid_word_message(secret_word, allowed_words, max_word_length, min_word_length)
    end
  end

  def make_guess
    make_guess_message
    gets.chomp.upcase
  end

  def secret_word_valid?(allowed_words, secret_word)
    return false unless allowed_words.include?(secret_word)
    return false unless secret_word.length.between?(min_word_length, max_word_length)

    true
  end
end
