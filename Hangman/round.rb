# frozen_string_literal: true

# XD TODO: comment.
class Round
  include MessagesForRound

  attr_accessor :found_letters, :incorrect_letters, :misses_this_round
  attr_reader :current_round, :executioner, :misses_available, :prisoner, :secret_word,
              :words

  def initialize(executioner, prisoner, misses_available, current_round, words)
    @executioner = executioner
    @prisoner = prisoner
    @misses_available = misses_available
    @current_round = current_round
    @misses_this_round = 0
    @words = words
    @secret_word = executioner.choose_secret_word(words)
    puts secret_word.to_s
    @incorrect_letters = Set[]
    @found_letters = Set[]
  end

  def draw_results
    print_incorrect_letters(incorrect_letters) unless incorrect_letters.length.zero?
    print_found_letters(found_letters) unless found_letters.length.zero?
    puts secret_word.to_s
  end

  def duplicate_guess?(guess)
    return false if used_letters.length.zero?

    duplicate = false
    used_letters.each do |letter|
      if letter.content == guess
        duplicate = true
        break
      end
    end
    duplicate
  end

  def letter_missed
    prisoner.gain_score(1)
    @misses_this_round += 1
  end

  def update_state(guess)
    if secret_word.contains?(guess)
      found_letters.add(Letter.new(guess, :found))
      secret_word.each { |l| l.found if l.content == guess }
    else
      incorrect_letters.add(Letter.new(guess, :incorrect))
      letter_missed
    end
  end

  def used_letters
    used = Set[]
    used.merge(incorrect_letters.dup)
    used.merge(found_letters.dup)
    used
  end

  def play_round
    until misses_this_round > misses_available
      update_state(force_valid_guess)
      draw_results
      if secret_word.guessed?
        success_procedure
        break
      end
    end
  end

  def force_valid_guess
    loop do
      guess = prisoner.make_guess
      return guess unless invalid?(guess)

      duplicate_guess_message if duplicate_guess?(guess)
      invalid_guess_length_message unless guess.length == 1
    end
  end

  def invalid?(guess)
    return true if duplicate_guess?(guess)
    return true if guess.length != 1
    return true unless guess =~ /[A-Z]+/

    false
  end

  def success_procedure
    executioner.gain_score(secret_word.length / 2 + 1)
    success_message(prisoner, executioner, secret_word)
  end
end
