# frozen_string_literal: true

# Colors:
#   :red for errors and negative stuff.
#   :yellow for basic info.
#   :green for positive stuff
#   :cyan for player 1
#   :magenta for player 2
#   :blue for questions
#   :black whenever I feel like it.
#   exceptions possible, especially for making distinguishing different prints easier.

# Contains prints for the Game class.
module MessagesForGame
  def print_score(player1, player2)
    puts  "#{player1}'s score: #{player1.score}.\n"\
          "#{player2}'s score: #{player2.score}.\n"\
          "Remember: less is better!\n\n"
  end

  def print_winner(winner)
    return puts "It's a draw!".colorize(:blue) if winner == :draw

    puts "#{winner} wins!"
  end

  def round_finished(round)
    puts "Round #{formatted_current_round(round)} finished!".colorize(:green)
  end
end

# Contains prints for the Hangman class.
module MessagesForHangman
  def are_you_sure_message
    puts "Are you sure you like these settings?\n".colorize(:blue)
    print_settings
  end

  def bad_input(min, max)
    puts "Invalid input! Type a natural number between #{min} and #{max}!".colorize(:red)
  end

  def change_settings_help
    puts  "1 -> Max word length (int)\n"\
          "2 -> Min word length (int)\n"\
          "3 -> Misses available (int)\n"\
          "4 -> Number of rounds (int)\n"\
          "5 -> Player 1 type ('yes' = Player, 'no' = Computer)\n"\
          "6 -> Player 2 type ('yes' = Player, 'no' = Computer)\n"\
          "Any other -> Confirm your choice and proceed.\n"
      .colorize(:green)
  end

  def change_edge_word_length_help(type, min, max)
    puts  "You are about to set the #{type} word length. The value has to be between "\
          "#{min} and #{max}. In case of invalid input you'll have to type again.\n"\
          "Current value: #{change_edge_word_length_current(type)}.".colorize(:yellow)
  end

  def change_edge_word_length_current(type)
    type == :min ? settings[:min_word_length] : settings[:max_word_length]
  end

  def change_misses_available_help(min, max)
    puts  'You are about to set the max number of letters you can guess incorrectly before '\
          "you'll lose. The value has to be between #{min} and #{max}. "\
          "In case of invalid input you\'ll have to type again.\n"\
          "Current value: #{settings[:misses_available]}.".colorize(:yellow)
  end

  def change_rounds_help(min_rounds)
    puts  'You are about to set the number of rounds you are going to play. The number has to '\
          "be no lesser than #{min_rounds}. In case of invalid input you'll have to type again.\n"\
          "Current value: #{settings[:number_of_rounds]}.".colorize(:yellow)
  end

  def change_player_type_help(id)
    puts  "You are about to set Player #{id} type. Type 'yes' if you want Player 1 to be "\
          "a Human, or 'no', to be a Computer.".colorize(:yellow)
  end

  def change_settings_intro
    puts  'There is a list of available options below the current settings print.'\
          'Each option is assigned a number. Type the number corresponding to the '\
          "option you want to change to change the option.\n"
      .colorize(:yellow)
  end

  def greet_the_player
    puts "\nGood mourning! There is no dedicated help command as you will be "\
    'told what you need to type to achieve the desired results at the runtime. '\
    'If you somehow fail to type a valid input, you will be told what to type so do not worry!'\
    "\n\nFirst and foremost, lets decide if you like the following settings: \n".colorize(:green)
  end

  def print_settings(asking: false)
    puts 'Current settings:'.colorize(:green)
    settings.each_pair do |k, v|
      puts "#{k.to_s.capitalize.gsub('_', ' ')}: #{v.to_s.capitalize}".colorize(:yellow)
    end
    puts "\n\nDo you want to change the settings? (yes/no)".colorize(:blue) if asking
  end

  def save_settings_message
    puts 'Save settings for later use? (yes/no)'.colorize(:blue)
  end
end

# Contains prints for the Human class.
module MessagesForHuman
  def secure_word_prompt_message
    puts 'Type a word you want the other player to guess. The word must be found in the '
      .colorize(:yellow) + 'data/dictionary.txt'.colorize(:green) + ' file.'.colorize(:yellow)
  end

  def make_guess_message
    print "\nType a letter: ".colorize(:yellow)
  end

  def invalid_word_message(word, allowed_words, max_word_length, min_word_length)
    word_not_allowed unless word.in?(allowed_words)
    word_too_short(word, min_word_length) if word.length < min_word_length
    word_too_long(word, max_word_length) if word.length > max_word_length
  end

  def word_not_allowed
    puts "The typed word is not allowed.\n".colorize(:red)
    puts 'You can add it to the dictionary (reload required) or choose another word'
      .colorize(:yellow)
  end

  def word_too_short(word, min_word_length)
    puts "The typed word is #{word.length} letters long while the minimum word length "\
    "is #{min_word_length}".colorize(:red)
  end

  def word_too_long(word, max_word_length)
    puts "The typed word is #{word.length} letters long while the maximum word length "\
    "is #{max_word_length}".colorize(:red)
  end
end

# Contains prints for the Player class.
module MessagesForPlayer
  def unspecified_player_subclass_error(error)
    puts 'CRITICAL ERROR: an instance of the Player class is neither Human '\
    'nor Computer. Unable to proceed...'.colorize(:red)
    puts error.backtrace.inspect.to_s.colorize(:red)
  end
end

# Contains prints for the Round Class
module MessagesForRound
  def duplicate_guess_message
    puts 'You have already made such a guess. Choose some other letter...'.colorize(:red)
  end

  def invalid_guess_length_message
    puts 'The guess has to be exactly 1 letter long!'.colorize(:red)
  end

  def print_letters(letters)
    letters.each { |l| print " #{l} " }
    print "\n"
  end

  def print_found_letters(found_letters)
    print 'These letters are correct: '.colorize(:yellow)
    print_letters(found_letters)
  end

  def print_incorrect_letters(incorrect_letters)
    print 'These letters are incorrect: '.colorize(:yellow)
    print_letters(incorrect_letters)
  end

  def success_message(prisoner, executioner, secret_word)
    print prisoner.to_s
    print ' has guessed the secret word, finishing the round and causing the '.colorize(:yellow)
    print executioner.to_s
    puts " to gain #{secret_word.length / 2 + 1} "\
      "points. The less points you have, the better!\n".colorize(:yellow)
  end
end

# General messages for Shared Methods.

def formatted_current_round(current_round)
  letter = current_round.odd? ? 'A' : 'B'
  digit = (current_round + 1) / 2
  "#{digit}-#{letter}"
end

def misused_in(array)
  puts "#in? takes an Array as the only argument, not a #{array.class}!"
end

def invalid_yes_or_no_input_message
  puts 'Invalid input. Please do cooperate...'.colorize(:red)
  puts "Valid inputs are 'y', 'yes' for yes and 'n', 'no' for no.".colorize(:yellow)
  puts 'Case is ignored.'.colorize(:yellow)
end
