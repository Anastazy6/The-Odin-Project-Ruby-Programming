# frozen_string_literal: true

# Contains constant values for Hangman. Used in settings to prevent
#   ridiculous options, like max word length == 666 (waaay to long xD)
module Constants
  ABS_MIN_WORD_LEN = 3
  ABS_MAX_WORD_LEN = 25
  ABS_MIN_ROUNDS = 1
  ABS_MIN_MISSES = 0
  ABS_MAX_MISSES = 13 # Just because.

  def abs_min_word_len
    ABS_MIN_WORD_LEN
  end

  def abs_max_word_len
    ABS_MAX_WORD_LEN
  end

  def abs_min_rounds
    ABS_MIN_ROUNDS
  end

  def abs_min_misses
    ABS_MIN_MISSES
  end

  def abs_max_misses
    ABS_MAX_MISSES
  end
end
