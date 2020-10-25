# frozen_string_literal: true

# 80-columns long comment so that I know what the optimal max line length is. ##
# 100-columns long comment so that I know what the reasonable line length limit is. ################
# 120-columns long comment so that I know what's the longest line I can write if I ever need to...######################

# xD
class TheProgrammerIsStupidError < StandardError; end

# Methods that either are shared by several classes or are generic/universal.
module SharedMethods
  def choose_smaller(number1, number2)
    case number1 <=> number2
    when -1 then number1
    when 0 then number1 # No difference
    when 1 then number2
    else raise TheProgrammerIsStupidError
    end
  end

  def choose_greater(number1, number2)
    case number1 <=> number2
    when -1 then number2
    when 0 then number1 # No difference
    when 1 then number1
    else raise TheProgrammerIsStupidError
    end
  end

  # Makes the user enter a valid 'yes' or 'no' input. No excuses, this method
  #   is patient and won't stop  until a valid input is given.
  def force_valid_yes_or_no_input
    loop do
      answer = gets.chomp.downcase
      return true if answer.match(/^y(es)?$/)
      return false if answer.match(/^n(o)?$/)

      invalid_yes_or_no_input_message
    end
  end

  def getint
    loop do
      number = gets.chomp
      return number.to_i if number =~ /[0-9]+/

      puts 'Invalid input: type an integer value.'.colorize(:red)
    end
  end

  # #gets that doesn't show what the user is typing.
  def secure_gets
    STDIN.noecho(&:gets)
  end
end

# Build-in Ruby Object class.
class Object
  def in?(array)
    raise TypeError, misused_in(array) unless array.is_a?(Array)

    array.include?(self)
  end
end
