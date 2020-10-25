# frozen_string_literal: true

# Contains all the methods that DIRECTLY change settings.
module ChangeSettingsMethods
  private

  def change_max_word_length # rubocop:disable Metrics/MethodLength
    relative_min_length = choose_greater(settings[:min_word_length], abs_min_word_len)
    change_edge_word_length_help(:max, relative_min_length, abs_max_word_len)
    loop do # Enforces valid input
      new_value = getint
      if new_value&.between?(relative_min_length, abs_max_word_len)
        settings[:max_word_length] = new_value
        break
      else
        bad_input(relative_min_length, abs_max_word_len)
      end
    end
  end

  def change_min_word_length # rubocop:disable Metrics/MethodLength
    relative_max_length = choose_smaller(settings[:max_word_length], abs_max_word_len)
    change_edge_word_length_help(:min, abs_min_word_len, relative_max_length)
    loop do # Enforces valid input
      new_value = getint
      if new_value&.between?(abs_min_word_len, relative_max_length)
        settings[:min_word_length] = new_value
        break
      else
        bad_input(abs_min_word_len, relative_max_length)
      end
    end
  end

  def change_misses_available
    change_misses_available_help(abs_min_misses, abs_max_misses)
    loop do # Enforces valid input
      new_value = getint
      if new_value&.between?(abs_min_misses, abs_max_misses)
        settings[:misses_available] = new_value
        break
      else
        bad_input(abs_max_misses, abs_max_misses)
      end
    end
  end

  def change_number_of_rounds
    change_rounds_help(abs_min_rounds)
    loop do # Enforces valid input
      new_value = getint
      if new_value && new_value >= abs_min_rounds
        settings[:number_of_round_pairs] = new_value
        break
      else
        bad_input(abs_min_rounds, 'as much as you want, but keep it civil...')
      end
    end
  end

  def change_player1_type
    change_player_type_help(1)
    settings[:player_1_type] = force_valid_yes_or_no_input ? :human : :computer
  end

  def change_player2_type
    change_player_type_help(2)
    settings[:player_2_type] = force_valid_yes_or_no_input ? :human : :computer
  end

  def change_AI_difficulty # rubocop:disable Naming/MethodName -> exception for an acronym.
    change_AI_difficulty_help
    settings[:intelligent_computer] = force_valid_yes_or_no_input
  end
end
