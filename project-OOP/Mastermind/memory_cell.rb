# frozen_string_literal: true

# Allows the computer to remember previous guesses (and their results) in a structured way.
class MemoryCell
  attr_reader :correct, :guess, :id, :method, :misplaced, :wrong

  def initialize(id, method, results)
    @correct = results[:correct]
    @guess = results[:guess].freeze
    @id = id
    @method = method
    @misplaced = results[:misplaced]
    @wrong = results[:wrong]
  end

  def to_s
    # This method is split in parts due to high ABC (formating and colouring is expensive...)
    first_part = to_s_part1
    second_part = to_s_part2
    first_part + second_part
  end

  def to_s_part1
    first_part =  "Guess #{id}: #{guess}   ".colorize(:blue) + "Method: \"#{method[:name]
        .to_s.capitalize.gsub('_', ' ')}\" ".colorize(:magenta)
    # Some methods work at a particular index. I want to have a formatted string that only
    #   mentions a method doing its job at a particular index if the index is present.
    first_part += "at index #{method[:index]}.".colorize(:magenta) unless method[:index].nil?
    first_part
  end

  def to_s_part2
    "\nCorrect: #{correct}   ".colorize(:green) +
      "Misplaced: #{misplaced}   ".colorize(:yellow) +
      "Wrong: #{wrong}\n".colorize(:red)
  end
end
