# frozen_string_literal: true

# The AI you will be playing against. Contains most memory-related methods and basic
#   code generators (only simple RNG).
class Computer < Player
  attr_accessor :known_digits, :last_guess_method, :memory, :possibilities,
                :useless_digits

  include GuessingAlgorithmAnalysis
  include GuessingAlgorithmGuessing
  include GuessingAlgorithmAliases

  def initialize(settings)
    super
    @name = 'Computer'.colorize(:magenta)
    @memory = []
    @known_digits = Array.new(code_length, nil)
    @useless_digits = []
    @possibilities = create_possibilities
    @last_guess_method = nil
  end

  def acknowledge_results(results)
    insert_to_memory(results)
    if results[:wrong] == code_length
      results[:guess].each { |el| useless_digits << el unless useless_digits.include?(el) }
      exclude_useless_digits
    end
    remove_possibilities(results)
    analyse_last_guess # Uses module GuessingAlgorithmAnalysis
  end

  def clear_memory
    @memory = []
    @known_digits = Array.new(code_length, nil)
    @useless_digits = []
    @possibilities = create_possibilities
    @last_guess_method = nil
  end

  def count_known_digits
    unknown_digits = known_digits.select(&:nil?)
    known_digits.length - unknown_digits.length
  end

  def create_possibilities
    possibilities = []
    code_length.times { possibilities << [1, 2, 3, 4, 5, 6] }
    possibilities
  end

  def exclude_useless_digits
    possibilities.map! { |position| position - useless_digits }
  end

  def insert_to_memory(results)
    memory << MemoryCell.new(
      memory.length + 1, # ID
      last_guess_method, # Last guess method
      results # Guess, correct, misplaced, wrong.
    )
  end

  def make_a_guess
    guess = force_unique_guess # Uses module GuessingAlgorithmGuessing
    puts "The computer has guessed: #{guess}.".colorize(:magenta)
    sleep(sleep_duration)
    guess
  end

  def make_code
    code = []
    code_length.times { code << [1, 2, 3, 4, 5, 6].sample }
    code
  end

  def remove_possibilities(results)
    return unless results[:correct] <= count_known_digits

    results[:guess].each_with_index do |g, i|
      possibilities[i].delete(g) unless possibilities[i].length == 1
    end
  end
end
