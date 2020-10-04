# frozen_string_literal: true

# Contains variables and methods that are shared between the human and the AI players.
#   Methods that do the same thing, but are implemented differently due to the nature
#   of human/AI behaviour are combined here under one name that will pick the correct
#   implementation based on the subclass of the caller.
class Player
  attr_reader :code_length, :name, :score, :sleep_duration, :verbose

  def initialize(settings)
    raise UnspecifiedPlayerSubclassError unless is_a?(Human) || is_a?(Computer)

    @code_length = settings[:code_length]
    @score = 0
    @sleep_duration = settings[:sleep]
    @verbose = settings[:verbose]
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
