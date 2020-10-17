# frozen_string_literal: true

# TODO: Copy from mastermind
class UnspecifiedPlayerSubclassError < TheProgrammerIsStupidError; end

# The superclass for Human and Computer players. Contains all the shared stuff.
class Player
  attr_reader :color, :id, :min_word_length, :max_word_length, :name, :score

  include MessagesForPlayer
  include SharedMethods

  def initialize(id, settings)
    raise UnspecifiedPlayerSubclassError unless is_a?(Human) || is_a?(Computer)

    @id = id
    @color = (id == 1 ? :cyan : :magenta)
    @name = "Player #{id}".colorize(color)
    @score = 0
    @min_word_length = settings[:min_word_length]
    @max_word_length = settings[:max_word_length]
  rescue UnspecifiedPlayerSubclassError => e
    unspecified_player_subclass_error(e)
    exit(1)
  end

  def choose_secret_word(_allowed_words)
    puts 'TODO!'.colorize(:red)
  end

  def gain_score(points)
    @score += points
  end

  def to_s
    name
  end
end
