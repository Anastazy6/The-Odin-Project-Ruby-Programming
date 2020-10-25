# frozen_string_literal: true

# Computer player.
class Computer < Player
  attr_accessor :choices, :unused_letters, :unknown_indexes
  attr_reader :intelligent, :possibilities

  def initialize(id, settings, possible_words, data = nil)
    super
    @name = "Player #{id} (AI)".colorize(color)
    @score = data[:score] if data
    @unused_letters = ('A'..'Z').to_a
    @intelligent = settings[:intelligent_computer]
    @possibilities = intelligent ? possible_words : nil
    @choices = possibilities.clone # IDK why but this makes it work properly...
    @unknown_indexes = nil
  end

  def acknowledge_results(secret_word, incorrect_letters)
    return unless intelligent

    remove_impossible_words(secret_word.to_regex, incorrect_letters)
    update_unknown_indexes(secret_word)
  end

  def choose_secret_word(words)
    possible_choices = words.select do |word|
      word.length.between?(min_word_length, max_word_length)
    end
    SecretWord.new(possible_choices.sample)
  end

  def reset_memory(allowed_words)
    @unused_letters = ('A'..'Z').to_a
    @possibilities = intelligent ? allowed_words : nil
    @unknown_indexes = nil
  end

  def make_guess
    return smart_guess if intelligent

    stupid_guess
  end

  def smart_guess
    possible_word = choices.sample
    possible_word[@unknown_indexes.sample].upcase
  end

  def stupid_guess
    guess = unused_letters.sample
    unused_letters.delete(guess)
    guess
  end

  private

  def contains_bad_letters?(word, incorrect_letters)
    return false if incorrect_letters.nil?

    # Note that incorrect_letters is a SET of Letter OBJECTS bad_letters is an ARRAY
    #   of single CHARS. The SET is passed from the Round class to the Computer, but the
    #   Computer only needs the content of the Letter objects.
    bad_letters = []
    incorrect_letters.each { |l| bad_letters << l.content.downcase }
    return false if (word.split('') & bad_letters).length.zero?

    true
  end

  def remove_impossible_words(secret_word_regex, incorrect_letters)
    @choices = possibilities.select { |word| word.downcase.match(secret_word_regex) }
    @choices.select! { |word| word unless contains_bad_letters?(word, incorrect_letters) }
  end

  def update_unknown_indexes(secret_word)
    unknown_ids = []
    secret_word.each_index { |id| unknown_ids << id if secret_word[id].state == :unknown }
    @unknown_indexes = unknown_ids
  end
end
