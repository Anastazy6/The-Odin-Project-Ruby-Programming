# frozen_string_literal: true

require 'colorize'

# Returns an array of first #{nums} Fibonacci sequence numbers.
def fibs(nums)
  return [] if nums < 1
  return [0] if nums == 1

  fibo = [0, 1]
  fibo << (fibo[-1] + fibo[-2]) until fibo.size == nums
  fibo
end

# Returns an array of first #{nums} Fibonacci sequence numbers, recursively.
def fibs_rec(nums, fibo = [0, 1], this = 0)
  this == nums ? fibo[0...this] : fibs_rec(nums, (fibo << fibo[-1] + fibo[-2]), this + 1)
end

20.times { |x| puts fibs(x).to_s.colorize(:green) }
20.times { |x| puts fibs_rec(x).to_s.colorize(:blue) }
