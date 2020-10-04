# frozen_string_literal: true

# Contains method directly related to picking a particular guessing strategy and analysing
#   guess results. Contains particular guessing methods.
module GuessingAlgorithmGuessing
  private

  # Makes a copy of the last guess with exactly one different digit.
  def change_one_digit(last_guess)
    guess_data = change_one_digit_core(last_guess)
    @last_guess_method = { name: :change_one_digit, index: guess_data[:chosen_index] }
    guess_data[:guess]
  end

  def change_one_digit_core(last_guess)
    chosen_index = choose_an_index_to_change_value
    digit_to_change = last_guess[chosen_index]

    # Generates a random number to replace the digit intended to change. The loop won't stop
    #   until it generates any different number which so far isn't considered useless.
    replacement = digit_to_change
    replacement = possibilities[chosen_index].sample while replacement == digit_to_change

    # Creates a copy of the last guess (DUP is MANDATORY!) but with the 'replacement' digit
    #   at the 'chosen_index' index.
    new_guess = last_guess.dup # DUP prevents memory from being modified.
    new_guess[chosen_index] = replacement
    { guess: new_guess, chosen_index: chosen_index }
  end

  def check_for_known_digits_from_possibilities
    known_digits.each_with_index do |e, i|
      known_digits[i] = possibilities[i][0] if possibilities[i].length == 1 && e.nil?
    end
  end

  def force_unique_guess
    666.times do # 666 attempts should be enough to find a valid code
      guess = guessing_algorithm
      return guess if memory.length.zero?

      same_guesses = memory.select { |entry| entry.guess == guess }
      return guess if same_guesses.length.zero?
    end
    puts "It's taking too long... Known digits: #{known_digits}. #{possibilities}"
    semi_random_guess
  end

  # Redirects to a particular guessing method depending on some particular conditions.
  #   This method is allowed greater complexity than usual.
  def guessing_algorithm
    return known_digits unless known_digits.include?(nil)
    return random_guess if memory.all?(&:nil?)
    return rearrange_last_guess if last_wrong.zero?
    return semi_random_guess if (@last_guess_method[:name] == :change_one_digit_failure) ||
                                (last_wrong >= @code_length / 2)

    change_one_digit(last_guess)
  end

  # Ensures that the known digits are included in the guess.
  def include_known_digits(guess)
    guess.each_with_index { |_e, id| guess[id] = known_digits[id] unless known_digits[id].nil? }
    guess
  end

  def random_guess
    @last_guess_method = { name: :random_guess, index: nil }
    make_code
  end

  # If all digits are correct but some are misplaced, there is no use of guessing randomly
  #   or changing some digits at random. Instead it's better to rearrange the misaligned ones.
  def rearrange_last_guess
    guess = []
    666.times do # 666 attempts should be enough to find a valid code
      misses = misplaced_digits_to_rearrange
      known_digits.each { |e| guess << (e.nil? ? misses.shuffle!.pop : e) }
      guess_possible?(guess) ? break : guess.clear
    end
    @last_guess_method = { name: :rearrange_last_guess, index: nil }
    guess
  end

  # Random guess that ensures that the digits which are known to be correct are included
  #   at their rightfull place.
  def semi_random_guess
    @last_guess_method = { name: :semi_random_guess, index: nil }
    guess = []
    possibilities.each { |p| guess << p.sample }
    include_known_digits(guess)
  end
end
