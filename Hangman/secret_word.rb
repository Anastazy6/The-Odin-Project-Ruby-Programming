# frozen_string_literal: true

# The word the prisoner has to guess
class SecretWord < Array
  attr_accessor :secret_word

  def initialize(secret_word_prototype = nil)
    make_secret_word_from(secret_word_prototype) if secret_word_prototype
  end

  # Sets the secret code letters' state to :found if they match the guess.
  #   Returns false unless a letter has been correctly guessed.
  def contains?(char)
    any_letter_found = false
    each do |letter|
      if char.upcase == letter.content
        letter.state = :found
        any_letter_found = true
      end
    end
    any_letter_found
  end

  def guessed?
    self.select { |char| char.state == :unknown }.length.zero? ? true : false
  end

  def to_s
    each { |l| print " #{l} " }
    print "\n"
  end

  def to_regex
    word = []
    each { |l| word << (l.state == :unknown ? '[a-z]' : l.content) }
    reg = word.join('').downcase

    %r{^#{reg}$}
  end

  def print_failed_word
    each do |l|
      l.incorrect_letter unless l.state == :found
      print " #{l} "
    end
    puts "\nFirst time?\n".colorize(:blue)
  end

  private

  def make_secret_word_from(secret_word_prototype)
    secret_word_prototype.split('').each { |char| self << Letter.new(char) }
  end
end

# Makes it easy to create each letter of the secret code and print according to it's state.
class Letter
  include Comparable

  attr_accessor :state
  attr_reader :content

  def initialize(char, state = :unknown)
    @content = char.upcase
    @state = state
  end

  def found
    @state = :found
  end

  def incorrect_letter
    @state = :incorrect
  end

  def letter_color
    color =
      case state
      when :unknown then :default
      when :found then :green
      when :incorrect then :red
      else raise TheProgrammerIsStupidError
      end
    color
  end

  def to_s
    case state
    when :unknown then '_'.colorize(letter_color)
    else content.colorize(letter_color)
    end
  end

  def <=>(other)
    raise TypeError unless other.is_a?(self.class)

    content <=> other.content
  end
end
