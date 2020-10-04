# frozen_string_literal: true

# frozen_string_literal: true

require 'pry'
require 'colorize'

require_relative 'public_static_void_main_string_args'
require_relative 'formatted_current_round'
require_relative 'game'
require_relative 'round'
require_relative 'player'
require_relative 'human'
require_relative 'guessing_algorithm_aliases'
require_relative 'guessing_algorithm_analysis'
require_relative 'guessing_algorithm_guessing'
require_relative 'computer'
require_relative 'memory_cell'

# A fancy name for assertion error.
class TheProgrammerIsStupidError < StandardError; end
# Raised when an instance of Player is created that isn't neither Human nor Computer
class UnspecifiedPlayerSubclassError < TheProgrammerIsStupidError; end

# Makes the user enter a valid 'yes' or 'no' input. No excuses, this method
#   is patient and won't stop  until a valid input is given.
def force_valid_yes_or_no_input
  loop do
    answer = gets.chomp.downcase
    return true if answer.match(/^y(es)?$/)
    return false if answer.match(/^n(o)?$/)

    puts 'Invalid input. Please do cooperate...'.colorize(:red)
    puts "Valid inputs are 'y', 'yes' for yes and 'n', 'no' for no.".colorize(:yellow)
    puts 'Case is ignored.'.colorize(:yellow)
  end
end

PublicStaticVoidMainStringArgs.new.main
puts 'Have a nice afterdoom!'.colorize(:red)
sleep(4)
