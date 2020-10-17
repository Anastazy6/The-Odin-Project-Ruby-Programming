# frozen_string_literal: true

# xD
class TheProgrammerIsStupidError < StandardError; end

# Raised when a shared method is used by an instance of a class that is not
#   meant to use the method.
class UnavailableMethodError < TheProgrammerIsStupidError; end

# Methods that either are shared by several classes or are generic/universal.
module SharedMethods
  # Ensures that if a class is not supposed to be able to use a certain shared method, it will
  #   not happen. Never.
  def available_for(classes_allowed_to_use_the_method)
    raise UnavailableMethodError unless classes_allowed_to_use_the_method.include?(self.class)

    nil
  end

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
