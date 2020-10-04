# frozen_string_literal: true

# Used to easily reset rounds
class Round # rubocop:disable Metrics/ClassLength
  attr_accessor :guesses_made
  attr_reader :code, :code_maker, :current_round, :guesser, :max_guesses

  def initialize(code_maker, guesser, max_guesses, current_round)
    guesser.is_a?(Computer) ? guesser.clear_memory : code_maker.clear_memory
    @code_maker = code_maker
    @guesser = guesser
    @current_round = current_round
    @max_guesses = max_guesses
    @guesses_made = 0
    puts initial_message(code_maker, code_maker.code_length)
    @code = code_maker.make_code
  end

  include FormattedCurrentRound

  # The message that will be printed out at the start of each round. The parametres are
  #   just shorthands for the code_maker and code_maker.code_length variables, respectively.
  #   Otherwise the strings are getting even more absurdly longer...
  def initial_message(maker, len)
    maker.is_a?(Computer) ? the_maker_is_a_computer(maker, len) : the_maker_is_a_human(len)
  end

  def play_the_round(verbose)
    until guesses_made == max_guesses
      puts guess_prompt
      guess = guesser.make_a_guess
      evaluate_guess(code, guess, guesser)
      break if round_finished?(code, guess, guesser)
    end
    show_memory(guesser) if verbose
  end

  private

  def count_correctly_placed_digits(code, guess)
    counter = 0
    code.length.times { |i| counter += 1 if code[i] == guess[i] }
    puts "\nDayum, you got it!\n".colorize(:green).underline if code == guess
    counter
  end

  def count_misplaced_digits(full_code, full_guess)
    leftovers = remove_correct_digits(full_code, full_guess)
    counter = 0
    until leftovers[:guess].length.zero?
      if leftovers[:code].include?(leftovers[:guess][0])
        leftovers[:code].delete_at(leftovers[:code].index(leftovers[:guess][0])) # KILLME
        counter += 1
      end
      leftovers[:guess].shift
    end
    counter
  end

  # Counts the correctly placed and misplaced digits in each guess and sends the data
  #   to the Computer if it is the guesser.
  def evaluate_guess(code, guess, guesser)
    correct = count_correctly_placed_digits(code, guess)
    misplaced = count_misplaced_digits(code.dup, guess.dup) # involves a destructive
    wrong = code.length - (correct + misplaced)
    print_round_results(correct, misplaced, wrong)
    # For Computer's AI
    results = { guess: guess,
                correct: correct,
                misplaced: misplaced,
                wrong: wrong }
    guesser.acknowledge_results(results) if guesser.is_a?(Computer)
  end

  def guess_failure(guesser)
    guesser.gain_score(1)
    @guesses_made += 1
  end

  def guess_prompt
    "#{guesser.name}, please make your guess. "\
        "Attempt number: #{guesses_made + 1}/#{max_guesses}\n\n".colorize(:yellow)
  end

  def print_round_results(correct, misplaced, wrong)
    puts "Correctly placed digits: #{correct}.".colorize(:green).underline
    puts "Correct but misplaced digits: #{misplaced}.".colorize(:yellow)
    puts "Digits both wrong and in wrong place: #{wrong}.\n\n".colorize(:red)
  end

  def remove_correct_digits(code, guess)
    unmatched_code = []
    unmatched_guesses = []
    guess.each_with_index do |_elem, id|
      unless guess[id] == code[id]
        unmatched_code << code[id]
        unmatched_guesses << guess[id]
      end
    end
    { code: unmatched_code, guess: unmatched_guesses }
  end

  def round_finished?(code, guess, guesser)
    if guess == code
      code_maker.gain_score(code.length)
      return true
    end
    guess_failure(guesser)
    false
  end

  def show_memory(guesser)
    puts guesser.memory if guesser.is_a?(Computer)
  end

  def the_maker_is_a_computer(maker, len)
    puts  "\nRound #{formatted_current_round}: \n\n".colorize(:green) +
          "The #{maker} has created its code. Your task is to guess it! \n".colorize(:magenta) +
          "Remember, the code is #{len} digits long.\nIf you guess correctly, the #{maker} will "\
          "receive #{len} points instead of you receiving 1.\nRemember: points are bad!\n"
          .colorize(:green) + "You can guess up to #{max_guesses} times. GL.".colorize(:yellow)
  end

  def the_maker_is_a_human(len)
    puts  "\nRound #{formatted_current_round}: \n\n".colorize(:green) +
          "Looks like you are making the code this time. The #{guesser} should "\
          "be able to quickly make its guesses, though results may vary...\n".colorize(:cyan) +
          "The code has to be #{len} digits long.".colorize(:green)
  end
end
