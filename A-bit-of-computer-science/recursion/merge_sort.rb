# frozen_string_literal: true

require 'pry'
require 'colorize'

# Merge sort is going to be a method callable on Arrays.
class Array
  def merge_sort
    return self if length < 2

    merge(left_half.merge_sort, rigth_half.merge_sort)
  end

  # Helpers:
  def merge(left, rigth)
    merged = []
    merged << add_smaller(left, rigth) until left.empty? && rigth.empty?
    merged
  end

  def add_smaller(left, rigth)
    return rigth.shift if left.empty? # Explicit returns prevent comparing ints with nils, though
    return left.shift if rigth.empty? #   a single line implementation looked better.

    left[0] <= rigth[0] ? left.shift : rigth.shift
  end

  # In case of Arrays containing odd number of elements, #rigth_half will be
  #   1 element longer than #left_half
  def left_half
    self[0...length / 2]
  end

  def rigth_half
    self[(length / 2)..-1]
  end
end

# Some tests (decomment a group delimited by empty lines/comments):
#
# puts [5, 3, 2, 1, 7, 6, 10, 8, 9].merge_sort.to_s.colorize(:magenta)
#
# test = []
# 200.times { test << rand(0..500) }
# puts test.uniq.merge_sort.to_s.colorize(:cyan)
#
# test2 = %w[death pain suffering DECAY Destruction DaRkness morEpain]
# puts test2.merge_sort.to_s.colorize(:red)
