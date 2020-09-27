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
    @default_settings = { rounds: 4, code_length: 4, guesses: 12 }
    @settings = { rounds: 4, code_length: 4, guesses: 12 }
  end

  # This is where the entire program happens within. Allows to play multiple games and
  #   run #game_loop method on each of them.
  def main
    greet_the_player
    loop do
      ask_about_settings
      game = Game.new(settings)
      game.game_loop
      puts 'Do you want to play another game? (yes/no): '.colorize(:yellow)
      answer = force_valid_yes_or_no_input
      break unless answer
    end
  end

  private

  # Asks the player if he/she wants to change the settings or leave them as they are.
  def ask_about_settings
    puts 'Current settings:'.colorize(:yellow)
    print_settings
    puts 'Do you want to change the settings? (yes/no)'.colorize(:blue)
    answer = force_valid_yes_or_no_input
    change_settings if answer
  end

  # Responsible for the length of the code the guesser will have to guess.
  def change_code_length
    puts "Changing code length. Current value: #{settings[:code_length]}.".colorize(:blue)
    puts 'New value must be one of those: 3, 4 (default), 5, 6.'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:code_length] =
      if [3, 4, 5, 6].include?(answer)
        answer
      else
        default_settings[:code_length]
      end
  end

  # Responsible for the number of guesses the guesser is allowed to make within one game.
  def change_guesses
    puts "Changing max guesses. Current value: #{settings[:guesses]}.".colorize(:blue)
    puts 'New value must be an integer between 4 and 20; default is 12'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:guesses] = answer.between?(4, 20) ? answer : default_settings[:guesses]
  end

  # Responsible for the rounds played in one game (must be an even number).
  def change_rounds
    puts "Changing rounds. Current value: #{settings[:rounds]}.".colorize(:blue)
    puts 'New value must be an even integer between 2 and 30; default is 4'.colorize(:yellow)
    answer = gets.chomp.to_i
    settings[:rounds] =
      if answer.even? && answer.between?(2, 30)
        answer
      else
        default_settings[:rounds]
      end
  end

  # Explains briefly how to change the settings or change a value to default.
  # Runs the methods responsible for changing each setting one at a time.
  def change_settings
    puts "\nYou will now be told:\n1) What you are changing at the moment\n2) Correct values\n"\
      "If you somehow fail to enter a valid value you'll get the default one.\n".colorize(:blue)
    puts "Two words: no refunds!\n".colorize(:red)
    change_rounds
    change_code_length
    change_guesses
    puts 'New settings: '.colorize(:yellow)
    print_settings
    puts 'Are you sure about the new settings? (yes/no)'.colorize(:blue)
    change_settings unless force_valid_yes_or_no_input
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
end

######################################## GAME ##########################################

# Contains variables that will be set to a certain value after each game start,
#   defaults and methods that don't fit the other, more specific classes.
class Game
  attr_reader :player1, :player2, :rounds, :current_round,
              :max_guesses, :current_guess, :winner, :code_length

  def initialize(settings)
    @rounds = settings[:rounds]
    @code_length = settings[:code_length]
    @max_guesses = settings[:guesses]
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
    puts "#{player1}'s score: #{player1.score}."
    puts "#{player2}'s score: #{player2.score}.\n Remember: less is better!\n\n"
    @current_round += 1
  end

  def print_winner(winner)
    return puts "It's a draw!".colorize(:blue) if winner == :draw

    puts "#{winner} wins!"
  end

  def start_round
    guesser = current_round.odd? ? player1 : player2
    code_maker = current_round.even? ? player1 : player2
    round = Round.new(code_maker, guesser, max_guesses)
    round.play_the_round
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

  def play_the_round
    until guesses_made == max_guesses
      # puts "DEBUG: #{code} (DELETE THIS!) (this is the code you have to guess)".colorize(:red) # DEBUG
      puts guess_prompt
      guess = guesser.make_a_guess
      evaluate_guess(code, guess, guesser)
      if guess == code
        code_maker.gain_score(code.length)
        break
      end
      guess_failure(guesser)
    end
  end

  private

  def count_correctly_placed_digits(code, guess)
    counter = 0
    code.length.times { |i| counter += 1 if code[i] == guess[i] }
    puts 'Dayum, you got it!'.colorize(:green) if code == guess
    counter
  end

  def count_misplaced_digits(full_code, full_guess)
    leftovers = remove_matching_guesses(full_code, full_guess)
    counter = 0
    until leftovers[:guess].length.zero?
      if leftovers[:code].include?(leftovers[:guess][0])
        leftovers[:code].delete_at(leftovers[:code].index(leftovers[:guess][0]))
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

  def remove_matching_guesses(code, guess)
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
    when :rearrange_last_guess then nil
    else raise TheProgrammerIsStupidError
    end
  end

  # Makes a copy of the last guess with exactly one different digit.
  def change_one_digit(last_guess)
    # Finds all indexes in the code that the computer isn't sure about yet.
    unknown_indexes = known_digits.each_index.select { |index| known_digits[index].nil? }
    # Picks random one of them.
    chosen_index = unknown_indexes[rand(0...unknown_indexes.length)]
    # Gets the digit that was placed in the last guess at the newly chosen index.
    digit_to_change = last_guess[chosen_index]
    # Generates a random number to replace the digit intended to change. The loop won't stop
    #   until it generates any different number which so far isn't considered useless.
    replacement = digit_to_change
    replacement = generate_useful_digit while replacement == digit_to_change
    # Creates a copy of the last guess (DUP is MANDATORY!) but with the 'replacement' digit
    #   at the 'chosen_index' index.
    new_guess = last_guess.dup # DUP prevents memory from being modified.
    new_guess[chosen_index] = replacement

    @last_guess_method = { name: :change_one_digit, index: chosen_index }
    include_known_digits(new_guess)
    # rescue TypeError # DEBUG
    # puts 'TYPE ERROR AT CHANGE ONE DIGIT!'.colorize(:red)
    # binding.pry
    # retry
  end

  def change_one_digit_score_difference
    memory[-2].nil? ? nil : memory[-1].correct - memory[-2].correct
  end

  def evaluate_change_one_digit
    changed_index = @last_guess_method[:index]
    case change_one_digit_score_difference
    when 0 then puts 'No changes'.colorize(:yellow)
    when 1 then known_digits[changed_index] = last_guess[changed_index]
    when -1 then known_digits[changed_index] = second_to_last_guess[changed_index]
    else raise TheProgrammerIsStupidError "(DEBUG) Result: #{change_one_digit_score_difference}".colorize(:red)
    end
  end

  def force_unique_guess
    loop do
      guess = guessing_algorithm
      same_guesses = memory.select { |entry| entry.guess == guess }
      return guess if same_guesses.length.zero?
    end
  end

  def guessing_algorithm
    return known_digits unless known_digits.include?(nil)
    return random_guess if memory.all?(&:nil?)
    return rearrange_last_guess if last_wrong.zero?
    return semi_random_guess if last_wrong >= @code_length / 2

    change_one_digit(last_guess)
  end

  # Ensures that the known digits are included in the guess.
  def include_known_digits(guess)
    guess.each_with_index { |_e, id| guess[id] = known_digits[id] unless known_digits[id].nil? }
    guess
  end

  def last_guess
    memory[-1].nil? ? nil : memory[-1].guess
  end

  def last_wrong
    memory[-1].nil? ? nil : memory[-1].wrong
  end

  def random_guess
    @last_guess_method = { name: :random_guess, index: nil }
    make_code
  end

  # If all digits are correct but some are misplaced, there is no use of guessing randomly
  #   or changing some digits at random. Instead it's better to rearrange the misaligned ones.
  def rearrange_last_guess # FIX
    misses = []
    last_guess.each_with_index { |e, i| misses << e unless last_guess[i] == known_digits[i] }
    guess = []
    known_digits.each do |e|
      guess << (e.nil? ? misses.shuffle.pop : e)
    end
    # raise TheProgrammerIsStupidError unless guess.length == code_length

    @last_guess_method = { name: :rearrange_last_guess, index: nil }
    guess
  end

  def second_to_last_guess
    memory[-2].nil? ? nil : memory[-2].guess
  end

  def second_to_last_wrong
    memory[-2].nil? ? nil : memory[-2].wrong
  end

  # Random guess that ensures that the digits which are known to be correct are included
  #   at their rightfull place.
  def semi_random_guess
    @last_guess_method = { name: :semi_random_guess, index: nil }
    guess = make_code
    include_known_digits(guess)
  end
end

# The AI you will be playing against. Contains most memory-related methods and basic
#   code generators (only simple RNG).
class Computer < Player
  attr_accessor :known_digits, :last_guess_method, :useless_digits, :memory

  include GuessingAlgorithm

  def initialize(settings)
    super
    @name = 'Computer'.colorize(:magenta)
    @memory = []
    @known_digits = Array.new(code_length, nil)
    @useless_digits = []
    @last_guess_method = nil
    print "HAHA BENIZ :DDDDD (known digits @initialize) #{known_digits}.\n".colorize(:red) # DEBUG (delete this)
  end

  def acknowledge_results(results)
    # puts results # DEBUG
    # puts known_digits.to_s + "HAHA BENIZ :DDDDD (known digits)\n\n".colorize(:red) # DEBUG
    insert_to_memory(results)
    if results[:wrong] == code_length
      results[:guess].each { |el| useless_digits << el unless useless_digits.include?(el) }
    end
    # puts "PENIZ #{useless_digits}. (useless digits)".colorize(:red) # DEBUG
    analyse_last_guess
    puts memory # DEBUG # TODO: include this at the very end of each round!
  end

  def clear_memory
    memory.map! { nil }
    known_digits.map! { nil }
    useless_digits.clear
    @last_guess_method = nil
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
      results[:guess],
      results[:correct],
      results[:misplaced],
      results[:wrong],
      last_guess_method
    )
  end

  def make_a_guess
    guess = force_unique_guess # TODO: more sophisticated algorithm
    puts "The computer has guessed: #{guess}.".colorize(:magenta)
    sleep(0.5)
    guess
  end

  def make_code
    code = []
    code_length.times { code << generate_useful_digit }
    code
  end
end

# Allows the computer to remember previous guesses (and their results) in a structured way.
class MemoryCell
  attr_reader :id, :guess, :correct, :misplaced, :wrong, :method

  def initialize(id, guess, correct, misplaced, wrong, method)
    @id = id
    @guess = guess.freeze
    @correct = correct
    @misplaced = misplaced
    @wrong = wrong
    @method = method
  end

  def to_s
    # IGNORE: ABC size is so high due to the complexity of the formatting. I do want the colors.
    first_part =  "Guess #{id}: #{guess}   ".colorize(:blue) +
                  "Method: \"#{method[:name].to_s.capitalize.gsub('_', ' ')}\" "
                  .colorize(:magenta)
    # Some methods work at a particular index. I want to have a formatted string that only
    #   mentions a method doing its job at a particular index if the index is present.
    first_part += "at index #{method[:index]}.".colorize(:magenta) unless method[:index].nil?

    second_part = "\nCorrect: #{correct}   ".colorize(:green) +
                  "Misplaced: #{misplaced}   ".colorize(:yellow) +
                  "Wrong: #{wrong}\n".colorize(:red)
    first_part + second_part
  end
end

######################################## STUFF #########################################

PublicStaticVoidMainStringArgs.new.main
puts 'Have a nice afterdoom!'.colorize(:red)
sleep(4)
