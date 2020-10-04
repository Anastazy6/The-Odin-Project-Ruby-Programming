# frozen_string_literal: true

# Contains methods that help the user set the game settings and play another game.
#   This is the outernmost box where you can change settings and decide whether you
#   wish to play a few more games or not.
class PublicStaticVoidMainStringArgs
  attr_accessor :settings
  attr_reader :default_settings

  def initialize
    @default_settings = { code_length: 4,
                          guesses: 12,
                          rounds: 2,
                          sleep: 0.5,
                          verbose: true }
    @settings = default_settings.dup
  end

  # This is where the entire program happens within. Allows to play multiple games and
  #   run #game_loop method on each of them.
  def main
    greet_the_player
    loop do
      ask_about_settings
      Game.new(settings).game_loop
      puts 'Do you want to play another game? (yes/no): '.colorize(:yellow)
      break unless force_valid_yes_or_no_input
    end
  end

  private

  # Asks the player if he/she wants to change the settings or leave them as they are.
  def ask_about_settings
    puts 'Current settings:'.colorize(:yellow)
    print_settings
    puts 'Do you want to change the settings? (yes/no)'.colorize(:blue)
    change_settings_interface if force_valid_yes_or_no_input
  end

  # Responsible for the length of the code the guesser will have to guess.
  def change_code_length
    puts "Changing code length. Current value: #{settings[:code_length]}.".colorize(:blue)
    puts 'New value must an integer from 2 to 15 (if you dare). Default: 4.'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:code_length] = answer.between?(2, 15) ? answer : default_settings[:code_length]
  end

  # Responsible for the number of guesses the guesser is allowed to make within one game.
  def change_guesses
    puts "\nChanging max guesses. Current value: #{settings[:guesses]}.".colorize(:blue)
    puts  "New value must be an integer between 2 and 100 (please don't).\n"\
          "Recommended (and default) value: #{recommended_guesses_limit}.".colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:guesses] = answer.between?(2, 100) ? answer : recommended_guesses_limit
  end

  # Responsible for the rounds played in one game (must be an even number).
  def change_rounds
    puts "\nChanging the number of round pairs. Current value: #{settings[:rounds]}.\n"\
      "Each pair consists of you guessing the Computer's code and the computer "\
      'guessing yours'.colorize(:blue)
    puts 'New value must be an even integer between 1 and 20; default is 2'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:rounds] = answer.between?(1, 20) ? answer : default_settings[:rounds]
  end

  def change_settings
    change_code_length
    change_guesses
    change_rounds
    change_sleep_duration
    toggle_verbosity
  end

  # Explains briefly how to change the settings or change a value to default.
  # Runs the methods responsible for changing each setting one at a time.
  def change_settings_interface
    puts "\nYou will now be told:\n1) What you are changing at the moment\n2) Correct values\n"\
      "If you somehow fail to enter a valid value you'll get the default one.\n".colorize(:cyan)
    puts "Two words: no refunds!\n".colorize(:red)
    change_settings
    puts 'New settings: '.colorize(:yellow)
    print_settings
    puts 'Are you sure about the new settings? (yes/no)'.colorize(:blue)
    change_settings_interface unless force_valid_yes_or_no_input
  end

  def change_sleep_duration
    print_sleep_info
    settings[:sleep] =
      case gets.chomp.to_i
      when 1 then 0.001
      when 2 then 0.5
      when 3 then 1
      when 4 then 1.5
      when 5 then 2
      else default_settings[:sleep]
      end
  end

  def greet_the_player
    puts "\nGood mourning! There is no dedicated help command as you will be "\
      'told what you need to type to achieve the desired results at the runtime. '\
      'If you somehow fail to type a valid input, you will be told what to type so do not worry!'\
      "\n\nFirst and foremost, lets decide if you like the following settings: \n".colorize(:blue)
  end

  # Pretty print? Who needs that if one can have this one below!
  def print_settings
    settings.each_pair { |key, value| puts "#{key.capitalize}: #{value}".colorize(:green) }
    puts "\n"
  end

  def print_sleep_info
    puts  "\nHow long do you want the Computer to wait between each guess? There are 4 levels:\n"\
      "1: 0.001 sec\n2: 0.5 sec\n3: 1 sec\n4: 1.5 sec\n5: 2 sec\nDefault is level 2: "\
      "0.5 sec\nType one of these integers: 1, 2, 3, 4, 5 to set the sleep duration."
      .colorize(:blue)
  end

  def recommended_guesses_limit
    ((settings[:code_length] - 1) * 4)
  end

  def toggle_verbosity
    puts "\nDo you want to receive a print of extra information about Computer's guessing and "\
      'guessing history after each round? (yes/no, default is yes)'.colorize(:blue)
    settings[:verbose] = force_valid_yes_or_no_input
  end
end
