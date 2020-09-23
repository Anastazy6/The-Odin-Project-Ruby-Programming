# frozen_string_literal: true

require 'pry'
require 'colorize'

# Raised in case of an attempt to occupy an already occupied cell.
class CellIsOccupiedError < StandardError; end
# A fancy name for AssertionError.
class TheProgrammerIsStupidError < StandardError; end

######################################   CELLS   #######################################

# Missing top level documentation comment
class Cell
  attr_reader :name, :owner

  def initialize(name)
    @name = name
    @owner = nil
  end

  def assign(player_symbol)
    raise CellIsOccupiedError unless owner.nil?

    @owner = player_symbol
  end

  def to_s
    case owner
    when nil then ' '
    when 'X' then 'X'.colorize(:cyan)
    when 'O' then 'O'.colorize(:magenta)
    else raise TheProgrammerIsStupidError
    end
  end
end

#######################################  PLAYER  #######################################

# Allows the creation of many players
class Player
  attr_reader :symbol, :id

  def initialize(symbol, id)
    # NOT a RUBY symbol, but a regular string ('X' or 'O')
    @symbol = symbol.to_s
    @id = id
  end

  def choose_cell
    loop do
      puts "Player #{symbol}'s turn.".colorize(:yellow)
      puts 'Choose your cell or type ' + 'help'.colorize(:magenta) + ' for help.'
      chosen_cell = gets.chomp
      case chosen_cell
      when 'help' then print_help
      else return chosen_cell.upcase.to_sym
      end
    end
  end

  # Shows the player the names of the cells to make picking the right one easier.
  def print_help
    puts "\n\n\n"
    puts '                    A1 | A2 | A3'
    puts '                   --------------'
    puts '                    B1 | B2 | B3'
    puts '                   --------------'
    puts '                    C1 | C2 | C3'
    puts "\n"
    puts 'Input is ' + 'case insensitive'.colorize(:green) + ".\n\n\n"
  end
end

######################################  THE GAME  ######################################

# Allows the creation of many disting games during one program execution
class Game
  attr_reader :player1, :player2, :victory_rows, :winner, :cells,
              :a1, :a2, :a3, :b1, :b2, :b3, :c1, :c2, :c3

  # each game is initialized with new player set and empty cells
  def initialize
    @player1 = Player.new(choose_symbol, 1)
    @player2 = Player.new(leftover_symbol, 2)
    @a1 = Cell.new(:A1)
    @a2 = Cell.new(:A2)
    @a3 = Cell.new(:A3)
    @b1 = Cell.new(:B1)
    @b2 = Cell.new(:B2)
    @b3 = Cell.new(:B3)
    @c1 = Cell.new(:C1)
    @c2 = Cell.new(:C2)
    @c3 = Cell.new(:C3)
    @cells = [@a1, @a2, @a3, @b1, @b2, @b3, @c1, @c2, @c3]
    # The sets of cells a player has to fully occupy in order to win.
    @victory_rows = [
      [a1, a2, a3], # ROWS
      [b1, b2, b3],
      [c1, c2, c3],
      [a1, b1, c1], # COLUMNS
      [a2, b2, c2],
      [a3, b3, c3],
      [a1, b2, c3], # DIAGONAL
      [a3, b2, c1]
    ]
    @winner = nil
  end

  # Allows the player1 to choose whether they want to play as X or O. This method will
  #   loop until a valid input is given.
  def choose_symbol
    puts "\n\nGuten Tag, player 1!\nAs the first player you can choose whether you "\
    'want to play as ' + 'X'.colorize(:cyan) + ' or ' + 'O'.colorize(:magenta)
    puts 'Pick your symbol: '.colorize(:yellow)
    loop do
      symbol = gets.chomp.upcase
      return symbol if %w[X O].include?(symbol)

      puts 'Invalid symbol. Must be "X" or "O". Try again: '.colorize(:red)
    end
  end

  # Makes sure that if player1 wants to be X, then player2 will be O or vice versa.
  def leftover_symbol
    player2_values =
      case player1.symbol
      when 'X' then { symbol: 'O', color: :magenta }
      when 'O' then { symbol: 'X', color: :cyan }
      else raise TheProgrammerIsStupidError # I've actually got that one xD
      end
    puts 'Guten Tag, player 2. Your fate has already been chosen.'.colorize(:yellow)
    puts "You'll have to play as " \
      + player2_values[:symbol].to_s.colorize(player2_values[:color])
    player2_values[:symbol]
  end

  # Prints up-to-date game state.
  def print_board
    puts "\n\n\n"
    puts "                    #{a1} | #{a2} | #{a3}"
    puts '                   -----------'
    puts "                    #{b1} | #{b2} | #{b3}"
    puts '                   -----------'
    puts "                    #{c1} | #{c2} | #{c3}"
    puts "\n\n\n"
  end

  # Checks if someone has won and returns the winner. If not found, checks if the game
  #   is a draw and returns :draw if so. Else returns nil and the game will continue.
  def check_state
    winner = find_winner
    return winner unless winner.nil?

    winner = draw? ? :draw : nil
    winner
  end

  def find_winner
    victory_rows.each do |row|
      if row[0].owner == row[1].owner && row[0].owner == row[2].owner
        winner = row[0].owner
        return winner
      end
    end
    nil
  end

  def draw?
    cells.each { |cell| return false if cell.owner.nil? }
    true
  end

  def play_game
    puts 'Let the game start!'.colorize(:green)
    winner = game_loop
    case winner
    when :draw then puts "It's a draw!".colorize(:yellow)
    when 'X' then puts "Player #{winner_id(winner)} (X) wins!".colorize(:cyan)
    when 'O' then puts "Player #{winner_id(winner)} (O) wins!".colorize(:magenta)
    else raise TheProgrammerIsStupidError
    end
  end

  # Returns the ID of the winner. Player1 is 1, player2 is 2.
  #   Only useful for formatted output,
  def winner_id(winner)
    return 1 if player1.symbol == winner

    2
  end

  # Carries on the game until someone wins or the game is a draw.
  #   Returns the winner of the game (or the fact that it is a :draw).
  def game_loop
    until winner
      action(player1)
      winner = check_state
      break if winner

      action(player2)
      winner = check_state
      break if winner # Prevents some buggy behavior. Crazy crap's going on...]

    end
    winner
  end

  # Assigns the chosen cell (from anschluss_cell method) to the player taking the turn.
  #   If the assignment is successful, prints the updated board, else the player has to
  #   choose another cell (in case of trying to occupy an already occupied cell).
  def action(player)
    chosen_cell = anschluss_cell(player)
    chosen_cell.assign(player.symbol)
    puts "Assigning cell #{chosen_cell.name} to player #{player.id}.".colorize(:green)
    print_board
  rescue CellIsOccupiedError
    puts "WARNING! Cell #{chosen_cell.name} is already occupied!. Try again".colorize(:red)
    retry
  end

  # Creates an environment in the Game class for the player that makes it possible
  #   to access Game instance variables, i.e. the cells. The player has to input
  #   the chosen cell's name (e.g. B2) and then the cell will be selected from the list
  #   of cells. If the cell is not found (e.g. the player typed some random crap), it will
  #   print error message and try again until the user input is valid. Returns the chosen
  #   cell as object.
  def anschluss_cell(player)
    loop do
      chosen_cell_name = player.choose_cell
      chosen_cells = cells.select { |cell| cell.name == chosen_cell_name }
      raise TheProgrammerIsStupidError if chosen_cells.length > 1

      return chosen_cells[0] if chosen_cells.length == 1

      puts "Cell #{chosen_cell_name} not found! Try again.".colorize(:red)
    end
  end
end

game1 = Game.new
game1.play_game
