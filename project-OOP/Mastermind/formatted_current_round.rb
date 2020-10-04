# frozen_string_literal: true

# Contains a single method for printing the current round ID, used both in the Game and the
#   Round classes.
module FormattedCurrentRound
  def formatted_current_round
    letter = current_round.odd? ? 'A' : 'B'
    digit = (current_round + 1) / 2
    "#{digit}-#{letter}"
  end
end
