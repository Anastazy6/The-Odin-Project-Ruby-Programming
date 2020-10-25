# frozen_string_literal: true

# XD TODO: comment.
class Round # rubocop:disable Metrics/ClassLength
  include MessagesForRound
  include MessagesForDrawing

  attr_accessor :found_letters, :incorrect_letters, :misses_this_round
  attr_reader :current_round, :executioner, :misses_available, :prisoner, :secret_word,
              :words

  def initialize(executioner, prisoner, misses_available, current_round, words, data = nil)
    @executioner = executioner
    @prisoner = prisoner
    @misses_available = misses_available
    @current_round = current_round
    @words = words
    data ? load_data(data) : create_new_round
    draw_results
  end

  def create_new_round
    make_secret_word
    @misses_this_round = 0
    @incorrect_letters = Set[]
    @found_letters = Set[]
  end

  def draw_results
    print_results
    puts "\n"
    prepare_gallows(prisoner.color, misses_available, misses_this_round)
    puts "\n"
    puts secret_word.to_s
  end

  def duplicate_guess?(guess)
    return false if guess.nil? || used_letters.length.zero?

    duplicate = false
    used_letters.each do |letter|
      if letter.content == guess
        duplicate = true
        break
      end
    end
    duplicate
  end

  def load_data(data)
    @misses_available = data[:misses_available]
    @current_round = data[:current_round]
    @misses_this_round = data[:misses_this_round]
    @secret_word = load_secret_word(data[:secret_word])
    @incorrect_letters = load_incorrect_letters(data[:incorrect_letters])
    @found_letters = load_found_letters(data[:found_letters])
    puts "Round #{formatted_current_round(current_round)}: It's #{prisoner}'s turn to guess!"
    print_score(prisoner, executioner)
  end

  def load_secret_word(data)
    word = SecretWord.new
    data.each { |id| word << Letter.new(id[0], id[1]) }
    word
  end

  def load_incorrect_letters(data)
    incorrect_letters = Set[]
    data.each { |id| incorrect_letters.add(Letter.new(id[0], id[1])) }
    incorrect_letters
  end

  def load_found_letters(data)
    found_letters = Set[]
    data.each { |id| found_letters.add(Letter.new(id[0], id[1])) }
    found_letters
  end

  def make_secret_word
    @secret_word = executioner.choose_secret_word(words)
    prisoner.acknowledge_results(secret_word, incorrect_letters) if prisoner.is_a?(Computer)
  end

  def print_results
    print_incorrect_letters(incorrect_letters) unless incorrect_letters.length.zero?
    print_found_letters(found_letters) unless found_letters.length.zero?
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
      main_procedure
      if secret_word.guessed?
        success_procedure
        break
      end
    end
    secret_word.print_failed_word if failed?
  end

  def failed?
    return false unless misses_this_round > misses_available
    return false if secret_word.guessed?

    true
  end

  def force_valid_guess # rubocop:disable Metrics/CyclomaticComplexity
    loop do
      guess = prisoner.make_guess
      return guess unless invalid?(guess)
      next if guess.nil? || guess.downcase =~ /^save$/

      duplicate_guess_message if duplicate_guess?(guess)
      invalid_guess_length_message unless guess&.length == 1
      not_a_letter_message unless guess =~ /[A-Z]+/
    end
  end

  def invalid?(guess)
    return true if guess.nil?
    return false if guess.downcase =~ /^save$/
    return true if duplicate_guess?(guess)
    return true if guess.length != 1
    return true unless guess =~ /[A-Z]+/

    false
  end

  def main_procedure
    update_state(force_valid_guess)
    draw_results
    prisoner.acknowledge_results(secret_word, incorrect_letters) if prisoner.is_a?(Computer)
  end

  def success_procedure
    executioner.gain_score(secret_word.length / 2 + 1)
    success_message(prisoner, executioner, secret_word)
  end
end
