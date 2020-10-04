# frozen_string_literal: true

# Contains more descriptive names for some GuessingAlgorith variables.
module GuessingAlgorithmAliases
  private

  def both_digits_were_wrong_info(index)
    puts 'The Computer tried changing one digit resulting in no change in correctness. '\
      "\nTherefore they can be safely ignored at position #{index}.\n\n"
      .colorize(:yellow).underline
  end

  # For evaluate change last guess. INFO: New guess registered.
  def change_one_digit_score_difference
    raise TheProgrammerIsStupidError unless memory[-2]

    memory[-1].correct - memory[-2].correct
  end

  def choose_an_index_to_change_value
    unknown_indexes = known_digits.each_index.select { |index| known_digits[index].nil? }
    chosen_index = unknown_indexes[rand(0...unknown_indexes.length)]
    chosen_index
  end

  def guess_possible?(guess)
    guess.each_with_index { |e, i| return false unless possibilities[i].include?(e) }
    true
  end

  def last_guess
    raise TheProgrammerIsStupidError unless memory[-1]

    memory[-1].guess
  end

  def last_guess_score
    raise TheProgrammerIsStupidError unless memory[-1]

    memory[-1].correct
  end

  def last_wrong
    raise TheProgrammerIsStupidError unless memory[-1]

    memory[-1].wrong
  end

  def misplaced_digits_to_rearrange
    misses = []
    last_guess.each_with_index do |_e, i|
      misses << last_guess[i] unless last_guess[i] == known_digits[i]
    end
    misses
  end

  def new_correct_digit_found_info(index)
    puts  "The Computer tried changing one digit at position #{index}\n"\
          "Task failed successfully!\n\n".colorize(:green).underline
  end

  def old_digit_was_correct_info(index)
    puts  "The Computer tried changing one digit, resulting in a score decrease.\n"\
          "It now knows that the previous one was correct!\n"\
          "Position: #{index}, value: #{known_digits[index]}.\n\n"
      .colorize(:red).underline
  end

  def second_to_last_guess
    raise TheProgrammerIsStupidError unless memory[-2]

    memory[-2].guess
  end

  def second_to_last_score
    raise TheProgrammerIsStupidError unless memory[-2]

    memory[-2].correct
  end

  def second_to_last_wrong
    raise TheProgrammerIsStupidError unless memory[-2]

    memory[-2].wrong
  end
end
