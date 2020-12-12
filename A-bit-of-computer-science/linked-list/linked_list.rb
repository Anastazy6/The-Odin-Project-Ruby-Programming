# frozen_string_literal: true

require 'colorize'
require 'pry'

# Death, decay and destruction.
class LinkedList # rubocop:disable Metrics/ClassLength
  attr_reader :first_node

  def initialize
    @first_node = nil
  end

  def append(new_node)
    return (@first_node = new_node) if @first_node.nil?

    current_node = @first_node
    current_node = current_node.next_node until current_node.next_node.nil?
    current_node.next_node = new_node
  end

  def at(index)
    current_index = 0
    current_node = @first_node

    until current_node.nil?
      return current_node if current_index == index

      current_node = current_node.next_node
      current_index += 1
    end
    puts "Unable to find node at index #{index}.".colorize(:red)
    nil
  end

  def contains?(value)
    current_node = @first_node
    until current_node.nil?
      return true if value == current_node.value

      current_node = current_node.next_node
    end
    false
  end

  def find(value)
    index = 0
    current_node = @first_node

    until current_node.nil?
      return index if current_node.value == value

      current_node = current_node.next_node
      index += 1
    end
    nil
  end

  def head
    @first_node
  end

  def insert_at(value, index)
    new_node = Node.new(value)

    return prepend(new_node) if index.zero?
    return append(new_node) if index >= size

    new_node.next_node = at(index)
    at(index - 1).next_node = new_node
  end

  def tail
    current_node = @first_node
    current_node = current_node.next_node until current_node.next_node.nil?
    current_node
  end

  def pop
    return nil if @first_node.nil?

    current_node = @first_node
    until current_node.next_node.nil?
      last_node = current_node
      current_node = current_node.next_node
    end
    size == 1 ? @first_node = nil : last_node.next_node = nil
    current_node
  end

  def prepend(new_node)
    new_node.next_node = @first_node
    @first_node = new_node
  end

  def remove_at(index)
    return nil unless index.between?(0, size - 1)

    removed_node = at(index)

    if index.zero?
      @first_node = @first_node.next_node if index.zero? # edge case handling
    else
      at(index - 1).next_node = removed_node.next_nod
    end

    removed_node.value
  end

  def size
    size = 0
    current_node = @first_node
    until current_node.nil?
      size += 1
      current_node = current_node.next_node
    end
    size
  end

  def pp_print(sep: "\n", ending: "\n")
    return puts 'Empty!'.colorize(:red) if @first_node.nil?

    current_node = @first_node
    until current_node.nil?
      print "#{current_node.value}#{sep}"
      current_node = current_node.next_node
    end
    print ending
  end

  def to_s
    current_node = @first_node
    until current_node.nil?
      print "( #{current_node.value} ) -> "
      current_node = current_node.next_node
    end
    puts 'nil'
  end
  nil
end

# Pain and suffering.
class Node
  attr_accessor :value, :next_node

  def initialize(value = nil, next_node = nil)
    @value = value
    @next_node = next_node
  end

  def to_s(recursive: false)
    print 'Class Node: '.colorize(:magenta)
    print 'Value => '.colorize(:cyan)
    print value
    print ' Next node => '.colorize(:cyan)
    return puts '<last>'.colorize(:magenta) if @next_node.nil?

    recursive ? @next_node.to_s(recursive: true) : (puts @next_node.value.to_s)
  end
end
