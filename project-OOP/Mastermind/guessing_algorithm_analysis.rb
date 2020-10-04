# frozen_string_literal: true

# Contains methods used during the analyse_last_guess process
#   (in Computer::acknowledge_results). All this stuff happens AFTER a guess is made.
module GuessingAlgorithmAnalysis
  private

  def analyse_last_guess # rubocop:disable Metrics/MethodLength -> long case list
    case last_guess_method[:name]
    when :random_guess then nil
    when :semi_random_guess then nil
    when :change_one_digit then evaluate_change_one_digit
    when :rearrange_last_guess then evaluate_rearrangement
    when :change_one_digit_failure then nil
    else raise TheProgrammerIsStupidError
    end
    check_for_known_digits_from_possibilities
  rescue TheProgrammerIsStupidError => e
    puts "#{e}: #{last_guess_method[:name]} you idiot, do you remember it?".colorize(:red)
    exit(666)
  end

  # For evaluate change last guess. INFO: New guess registered.
  def both_digits_were_wrong(index)
    possibilities[index].delete(last_guess[index])
    possibilities[index].delete(second_to_last_guess[index])
    @last_guess_method = { name: :change_one_digit_failure, index: :index }
    both_digits_were_wrong_info(index) if verbose
  end

  def evaluate_change_one_digit
    changed_index = @last_guess_method[:index]
    case change_one_digit_score_difference
    when 0 then both_digits_were_wrong(changed_index)
    when 1 then new_correct_digit_found(changed_index)
    when -1 then old_digit_was_correct(changed_index)
    else raise TheProgrammerIsStupidError
    end
  end

  def evaluate_rearrangement
    return unless last_guess_score <= count_known_digits

    possibilities.each_with_index { |p, i| p.delete(last_guess[i]) unless p.length == 1 }
  end

  # For evaluate change last guess. INFO: New guess registered.
  def new_correct_digit_found(index)
    known_digits[index] = last_guess[index] if known_digits[index].nil?
    possibilities[index] = [known_digits[index]] unless possibilities[index].length == 1
    new_correct_digit_found_info(index) if verbose
  end

  # For evaluate change last guess. INFO: New guess registered.
  def old_digit_was_correct(index)
    known_digits[index] = second_to_last_guess[index] if known_digits[index].nil?
    possibilities[index] = [known_digits[index]] unless possibilities[index].length == 1
    @last_guess_method = { name: :change_one_digit_failure, index: :index }
    old_digit_was_correct_info(index) if verbose
  end
end