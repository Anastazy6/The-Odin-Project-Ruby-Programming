# frozen_string_literal: true

require 'pry'
require 'colorize'

# A fancy name for assertion error.
class TheProgrammerIsStupidError < StandardError; end
# Raised when an instance of Player is created that isn't neither Human nor Computer
class UnspecifiedPlayerSubclassError < StandardError; end

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
######################################## MAIN ##########################################

# Contains methods that help the user set the game settings and play another game.
#   This is the outernmost box where you can change settings and decide whether you
#   wish to play a few more games or not.
class PublicStaticVoidMainStringArgs
  attr_accessor :settings
  attr_reader :default_settings

  def initialize
    @default_settings = { rounds: 2, code_length: 4, guesses: 12, memory_announcements: true }
    @settings = { rounds: 2, code_length: 4, guesses: 12, memory_announcements: true }
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
  # rescue TheProgrammerIsStupidError => e
    # uts "A fatal error has occured due to the programmer being a total derp: #{e}"
      # .colorize(:red)
    # exit(-1)
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
    puts 'New value must be one of those: 2, 3, 4 (default), 5, 6, 7.'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:code_length] = answer.between?(2, 7) ? answer : default_settings[:code_length]
  end

  # Responsible for the number of guesses the guesser is allowed to make within one game.
  def change_guesses
    puts "Changing max guesses. Current value: #{settings[:guesses]}.".colorize(:blue)
    puts 'New value must be an integer between 4 and 30; default is 12'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:guesses] = answer.between?(4, 30) ? answer : default_settings[:guesses]
  end

  # Responsible for the rounds played in one game (must be an even number).
  def change_rounds
    puts "Changing the number of round pairs. Current value: #{settings[:rounds]}.\n"\
      "Each pair consists of you guessing the Computer's code and the computer "\
      'guessing yours'.colorize(:blue)
    puts 'New value must be an even integer between 1 and 10; default is 2'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:rounds] = answer.between?(1, 10) ? answer : default_settings[:rounds]
  end

  def change_settings
    change_rounds
    change_code_length
    change_guesses
    toggle_memory_announcements
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

  def toggle_memory_announcements
    puts "Do you want to receive a print of Computer'"\
      's guessing history after each round? (yes/no, default is yes)'.colorize(:blue)
    settings[:memory_announcements] = force_valid_yes_or_no_input
  end
end

######################################## GAME ##########################################

# Contains variables that will be set to a certain value after each game start,
#   defaults and methods that don't fit the other, more specific classes.
class Game
  attr_reader :player1, :player2, :rounds, :current_round, :verbose,
              :max_guesses, :current_guess, :winner, :code_length

  def initialize(settings)
    @rounds = settings[:rounds] * 2
    @code_length = settings[:code_length]
    @max_guesses = settings[:guesses]
    @verbose = settings[:memory_announcements]

    @player1 = human_wants_to_start? ? Human.new(settings) : Computer.new(settings)
    @player2 = human_starts? ? Computer.new(settings) : Human.new(settings)

    @current_round = 1
    @current_guess = 1
  end

  def human_starts?
    return true if player1.is_a?(Human)

    false
  end

  def human_wants_to_start?
    puts 'Good mourning! As the human player, you are given the opportunity to '\
      'choose whether you want to guess first. '\
      "Type 'yes' if so, else type 'no'.".colorize(:green)
    force_valid_yes_or_no_input
  end

  # This is where the entire game is in.
  def game_loop
    start_round until current_round > rounds
    # Score is detrimental: the less you gain, the better
    winner =
      case player1.score <=> player2.score
      when -1 then player1
      when 0 then :draw
      when 1 then player2
      else raise TheProgrammerIsStupidError
      end
    print_winner(winner)
  end

  private

  def prepare_next_round
    @current_round += 1
    puts  "#{player1}'s score: #{player1.score}.\n"\
          "#{player2}'s score: #{player2.score}.\n"\
          "Remember: less is better!\n\n"
  end

  def print_winner(winner)
    return puts "It's a draw!".colorize(:blue) if winner == :draw

    puts "#{winner} wins!"
  end

  def start_round
    guesser = current_round.odd? ? player1 : player2
    code_maker = current_round.even? ? player1 : player2

    Round.new(code_maker, guesser, max_guesses).play_the_round(verbose)

    puts "Round #{current_round} finished!".colorize(:green)
    prepare_next_round
  end
end

######################################## ROUND #########################################

# Used to easily reset rounds
class Round
  attr_reader :code_maker, :guesser, :max_guesses, :code
  attr_accessor :guesses_made

  def initialize(code_maker, guesser, max_guesses)
    guesser.is_a?(Computer) ? guesser.clear_memory : code_maker.clear_memory
    @code_maker = code_maker
    @guesser = guesser
    @max_guesses = max_guesses
    @guesses_made = 0
    puts initial_message(code_maker, code_maker.code_length)
    @code = code_maker.make_code
  end

  # The message that will be printed out at the start of each round. The parametres are
  #   just shorthands for the code_maker and code_maker.code_length variables, respectively.
  #   Otherwise the strings are getting even more absurdly longer...
  def initial_message(maker, len)
    if maker.is_a? Computer
      "The #{maker} has created its code. Your task is to guess it! \n".colorize(:magenta) +
        "Remember, the code is #{len} digits long.\nIf you guess correctly, the #{maker} will "\
        "receive #{len} points instead of you receiving 1.\nRemember: points are bad!\n"
        .colorize(:green) + "You can guess up to #{max_guesses} times. GL.".colorize(:yellow)
    else
      "Looks like you are making the code this time. The #{guesser} should "\
        "be able to quickly make its guesses, though results may vary...\n".colorize(:cyan) +
        "The code has to be #{len} digits long.".colorize(:green)
    end
  end

  def play_the_round(verbose)
    until guesses_made == max_guesses
      puts guess_prompt
      guess = guesser.make_a_guess
      evaluate_guess(code, guess, guesser)
      break if round_finished?(code, guess, guesser)
    end
    show_memory(guesser) if verbose
  end

  private

  def count_correctly_placed_digits(code, guess)
    counter = 0
    code.length.times { |i| counter += 1 if code[i] == guess[i] }
    puts 'Dayum, you got it!'.colorize(:green) if code == guess
    counter
  end

  def count_misplaced_digits(full_code, full_guess)
    leftovers = remove_correct_digits(full_code, full_guess)
    counter = 0
    until leftovers[:guess].length.zero?
      if leftovers[:code].include?(leftovers[:guess][0])
        leftovers[:code].delete_at(leftovers[:code].index(leftovers[:guess][0])) # KILLME
        counter += 1
      end
      leftovers[:guess].shift
    end
    counter
  end

  # Counts the correctly placed and misplaced digits in each guess and sends the data
  #   to the Computer if it is the guesser.
  def evaluate_guess(code, guess, guesser)
    correct = count_correctly_placed_digits(code, guess)
    misplaced = count_misplaced_digits(code.dup, guess.dup)
    puts "Correctly placed digits: #{correct}.".colorize(:green)
    puts "Correct but misplaced digits: #{misplaced}.\n\n".colorize(:yellow)
    # For Computer's AI (TODO)
    results = { guess: guess,
                correct: correct,
                misplaced: misplaced,
                wrong: code.length - (correct + misplaced) }
    guesser.acknowledge_results(results) if guesser.is_a?(Computer)
  end

  def guess_failure(guesser)
    guesser.gain_score(1)
    @guesses_made += 1
  end

  def guess_prompt
    "#{guesser.name}, please make your guess. "\
        "Attempt number: #{guesses_made + 1}/#{max_guesses}\n\n".colorize(:yellow)
  end

  def remove_correct_digits(code, guess)
    unmatched_code = []
    unmatched_guesses = []
    guess.each_with_index do |_elem, id|
      unless guess[id] == code[id]
        unmatched_code << code[id]
        unmatched_guesses << guess[id]
      end
    end
    { code: unmatched_code, guess: unmatched_guesses }
  end

  def round_finished?(code, guess, guesser)
    if guess == code
      code_maker.gain_score(code.length)
      return true
    end
    guess_failure(guesser)
    false
  end

  def show_memory(guesser)
    puts guesser.memory if guesser.is_a?(Computer)
  end
end

####################################### PLAYER #########################################

# Contains variables and methods that are shared between the human and the AI players.
#   Methods that do the same thing, but are implemented differently due to the nature
#   of human/AI behaviour are combined here under one name that will pick the correct
#   implementation based on the subclass of the caller.
class Player
  attr_reader :score, :name, :code_length

  def initialize(settings)
    raise UnspecifiedPlayerSubclassError unless is_a?(Human) || is_a?(Computer)

    @code_length = settings[:code_length]
    @score = 0
  rescue UnspecifiedPlayerSubclassError
    puts 'CRITICAL ERROR: an instance of the Player class is neither Human '\
      'nor Computer. Unable to proceed...'.colorize(:red)
    exit(1)
  end

  def gain_score(points)
    @score += points
  end

  def to_s
    name
  end
end

######################################## HUMAN #########################################

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

###################################### COMPUTER ########################################

# Contains method directly related to picking a particular guessing strategy and analysing
#   guess results. Contains particular guessing methods.
module GuessingAlgorithm
  private

  def analyse_last_guess
    case last_guess_method[:name]
    when :random_guess then nil
    when :semi_random_guess then nil
    when :change_one_digit then evaluate_change_one_digit
    when :fix_last_change_one_digit then evaluate_fix_last_change_one_digit
    when :rearrange_last_guess then evaluate_rearrangement
    else raise TheProgrammerIsStupidError
    end
    check_for_known_digits_from_possibilities
  end

  # Makes a copy of the last guess with exactly one different digit.
  def change_one_digit(last_guess)
    guess_data = change_one_digit_core(last_guess)

    @last_guess_method = { name: :change_one_digit, index: guess_data[:chosen_index] }
    guess_data[:guess]
  end

  def change_one_digit_core(last_guess)
    chosen_index = choose_an_index_to_change_value
    digit_to_change = last_guess[chosen_index]
    # Generates a random number to replace the digit intended to change. The loop won't stop
    #   until it generates any different number which so far isn't considered useless.
    replacement = digit_to_change
    replacement = possibilities[chosen_index].sample while replacement == digit_to_change
    # Creates a copy of the last guess (DUP is MANDATORY!) but with the 'replacement' digit
    #   at the 'chosen_index' index.
    new_guess = last_guess.dup # DUP prevents memory from being modified.
    new_guess[chosen_index] = replacement
    { guess: new_guess, chosen_index: chosen_index }
  end

  def check_for_known_digits_from_possibilities
    known_digits.each_with_index do |e, i|
      known_digits[i] = possibilities[i][0] if possibilities[i].length == 1 && e.nil?
    end
  end

  def evaluate_change_one_digit
    changed_index = @last_guess_method[:index]
    case change_one_digit_score_difference
    when 0 then both_digits_were_wrong(changed_index)
    when 1 then new_correct_digit_found(changed_index)
    when -1 then old_digit_was_correct(changed_index)
    else raise TheProgrammerIsStupidError
    end
  end

  def evaluate_fix_last_change_one_digit
    raise TheProgrammerIsStupidError if memory[-3].nil?

    changed_index = @last_guess_method[:index]
    score_difference = fix_last_change_one_digit_score_difference
    case score_difference
    when 0 then both_digits_were_wrong(changed_index)
    when 1 then new_correct_digit_found(changed_index)
    when -1 then old_digit_was_correct(changed_index)
    else raise TheProgrammerIsStupidError
    end
  end

  def evaluate_rearrangement
    if last_guess_score <= second_to_last_score # rubocop:disable Style/GuardClause
      possibilities.each_with_index { |p, i| p.delete(last_guess[i]) unless p.length == 1 }
      puts possibilities.to_s
    end
  end

  def fix_last_change_one_digit(second_to_last_guess)
    guess_data = change_one_digit_core(second_to_last_guess)

    @last_guess_method = { name: :fix_change_one_digit, index: guess_data[:chosen_index] }
    guess_data[:guess]
  end

  def force_unique_guess
    loop do
      guess = guessing_algorithm
      return guess if memory.length.zero?

      same_guesses = memory.select { |entry| entry.guess == guess }
      return guess if same_guesses.length.zero?
    end
  end

  # Redirects to a particular guessing method depending on some particular conditions.
  #   This method is allowed greater complexity than usual.
  def guessing_algorithm # rubocop:disable Metrics/AbcSize
    return known_digits unless known_digits.include?(nil)
    return random_guess if memory.all?(&:nil?)
    return rearrange_last_guess if last_wrong.zero?
    return fix_last_change_one_digit(second_to_last_guess) if
      @last_guess_method == :change_one_digit_failure
    return semi_random_guess if last_wrong >= @code_length / 2

    change_one_digit(last_guess)
  end

  # Ensures that the known digits are included in the guess.
  def include_known_digits(guess)
    guess.each_with_index { |_e, id| guess[id] = known_digits[id] unless known_digits[id].nil? }
    guess
  end

  # If all digits are correct but some are misplaced, there is no use of guessing randomly
  #   or changing some digits at random. Instead it's better to rearrange the misaligned ones.
  def rearrange_last_guess
    guess = []
    loop do
      misses = misplaced_digits_to_rearrange
      known_digits.each { |e| guess << (e.nil? ? misses.shuffle!.pop : e) }
      puts "ACHTUNG!: #{guess}."
      guess_possible?(guess) ? break : guess.clear
    end
    @last_guess_method = { name: :rearrange_last_guess }
    guess
  end
end

# Contains more descriptive names for some GuessingAlgorith variables.
module GuessingAlgorithmAliases
  # For evaluate change last guess.
  def both_digits_were_wrong(index)
    puts 'The Computer tried changing one digit resulting in no change in correctness. '\
      "\nTherefore they can be safely ignored at position #{index + 1}.\n\n".colorize(:magenta)
  end

  def change_one_digit_score_difference
    memory[-2].nil? ? nil : memory[-1].correct - memory[-2].correct
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

  def fix_last_change_one_digit_score_difference
    base_score = memory[-3].correct
    memory[-1].correct - base_score
  end

  def last_guess
    memory[-1] ? memory[-1].guess : nil
  end

  def last_guess_score
    memory[-1] ? memory[-1].correct : nil
  end

  def last_wrong
    memory[-1] ? memory[-1].wrong : nil
  end

  def misplaced_digits_to_rearrange
    misses = []
    last_guess.each_with_index do |_e, i|
      misses << last_guess[i] unless last_guess[i] == known_digits[i]
    end
    misses
  end

  def new_correct_digit_found(index)
    known_digits[index] = last_guess[index]
    possibilities[index] = [known_digits[index]]
    puts "The Computer tried changing one digit at position #{index + 1}\n"\
      "Task failed successfully!\n\n".colorize(:magenta)
  end

  def old_digit_was_correct(index)
    known_digits[index] = second_to_last_guess[index]
    possibilities[index] = [known_digits[index]]
    @last_guess_method = { name: :change_one_digit_failure, index: :index }
    puts "The Computer tried changing one digit, resulting in a score decrease.\n"\
      "It now knows that the previous one was correct! Position: #{index}.\n\n".colorize(:magenta)
  end

  def random_guess
    @last_guess_method = { name: :random_guess, index: nil }
    make_code
  end

  def second_to_last_guess
    memory[-2] ? memory[-2].guess : nil
  end

  def second_to_last_score
    memory[-2] ? memory[-2].correct : nil
  end

  def second_to_last_wrong
    memory[-2] ? memory[-2].wrong : nil
  end

  # Random guess that ensures that the digits which are known to be correct are included
  #   at their rightfull place.
  def semi_random_guess
    @last_guess_method = { name: :semi_random_guess, index: nil }
    guess = []
    possibilities.each { |p| guess << p.sample }
    include_known_digits(guess)
  end
end

# The AI you will be playing against. Contains most memory-related methods and basic
#   code generators (only simple RNG).
class Computer < Player
  attr_accessor :known_digits, :last_guess_method, :useless_digits, :memory,
                :possibilities

  include GuessingAlgorithm
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
    analyse_last_guess
  end

  def clear_memory
    @memory = []
    @known_digits = Array.new(code_length, nil)
    @useless_digits = []
    @possibilities = create_possibilities
    @last_guess_method = nil
  end

  def create_possibilities
    possibilities = []
    code_length.times { possibilities << [1, 2, 3, 4, 5, 6] }
    possibilities
  end

  def exclude_useless_digits
    possibilities.map! { |position| position - useless_digits }
    puts possibilities.to_s.colorize(:red)
  end

  # Generates any random digit from 1 to 6 that still has a chance to be included in the code.
  #   The reason is: if the computer gets ALL digits wrong in a guess, then there is no use
  #   to include them in future guessses.
  def generate_useful_digit
    loop do
      digit = rand(1..6)
      return digit unless useless_digits.include?(digit)
    end
  end

  def insert_to_memory(results)
    memory << MemoryCell.new(
      memory.length + 1, # ID
      results, # Guess, correct, misplaced, wrong.
      last_guess_method # Last guess method
    )
  end

  def make_a_guess
    guess = force_unique_guess
    puts "The computer has guessed: #{guess}.".colorize(:magenta)
    sleep(0.5)
    guess
  end

  def make_code
    code = []
    code_length.times { code << generate_useful_digit }
    code
  end

  def remove_possibilities(results)
    already_known_digits = known_digits.select { |x| x unless x.nil? }
    if results[:correct] <= already_known_digits.length # rubocop:disable Style/GuardClause
      results[:guess].each_with_index do |g, i|
        possibilities[i].delete(g) unless possibilities[i].length == 1
      end
    end
  end
end

# Allows the computer to remember previous guesses (and their results) in a structured way.
class MemoryCell
  attr_reader :id, :guess, :correct, :misplaced, :wrong, :method

  def initialize(id, results, method)
    @id = id
    @guess = results[:guess].freeze
    @correct = results[:correct]
    @misplaced = results[:misplaced]
    @wrong = results[:wrong]
    @method = method
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

######################################## STUFF #########################################

PublicStaticVoidMainStringArgs.new.main
puts 'Have a nice afterdoom!'.colorize(:red)
sleep(4)
