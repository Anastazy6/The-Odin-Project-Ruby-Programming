# frozen_string_literal: true

# You. Any self-aware biological, mechanical or supernatural beings are politely
#   asked to act as if they were a Human. For simplicity.
class Human < Player
  def initialize(settings)
    super
    @name = 'Human'.colorize(:cyan)
  end

  # Asks the human player for code until a valid one is given.
  def force_valid_code(guess: false)
    puts 'Human, please type the code: '.colorize(:cyan) unless guess
    loop do
      code = gets.chomp
      return code.split('').map(&:to_i) if code.match(/^[123456]{#{code_length}}$/)

      puts 'Invalid code. Please do cooperate...'.colorize(:red)
      puts "The code has to be #{code_length} digits long and consist of natural "\
        'numbers from 1 to 6. Some examples of valid codes: '.colorize(:yellow)
      puts "3 digits: 255, 666;\n4 digits: 1111, 2345;\n5 digits: 12345, 32325;\n"\
        "6 digits: 123456, 666666\nDo not separate the digits.".colorize(:green)
    end
  end

  def make_a_guess
    guess = force_valid_code(guess: true)
    puts "You have guessed: #{guess}.".colorize(:cyan)
    guess
  end

  def make_code
    force_valid_code(guess: false)
  end
end
