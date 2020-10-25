# frozen_string_literal: true

# Saving requires the dictionary.txt file not to be modified between saving and loading the game.
#   This way the entire dictionary doesn't need to be included in the save file (that's a lot
#   of memory!)
module Save
  def save_game
    File.open("saves/#{choose_name}.yaml", 'w') do |save|
      save.puts(YAML.dump(all_data))
    end
    puts 'Game saved.'.colorize(:green)
  end

  def all_data
    binding.pry
    { game_data: game_data,
      round_data: round_data(round),
      player_1_data: player_data(1),
      player_2_data: player_data(2) }
  end

  def choose_name
    choose_file_name
    gets.chomp
  end

  def game_data
    { settings: settings,
      current_round: current_round }
  end

  def round_data(round)
    { executioner: round.executioner.id,
      prisoner: round.prisoner.id,
      misses_available: round.misses_available,
      current_round: round.current_round,
      misses_this_round: round.misses_this_round,
      secret_word: save_letters(round.secret_word),
      incorrect_letters: save_letters(round.incorrect_letters),
      found_letters: save_letters(round.found_letters) }
  end

  def player_data(id)
    p = (id == 1 ? @player1 : @player2)
    { score: p.score }
  end

  def save_letters(secret_word)
    saved = []
    secret_word.each { |l| saved << [l.content, l.state] }
    saved
  end
end

# Missing top-level... whatever.
module Load
  def choose_a_file_to_load
    saves = []
    Dir.entries('saves').each { |save| saves << save if save =~ /^(\w+).yaml$/ }
    chosen_file = idiotproof_load(saves.sort)
    puts "Filename: #{chosen_file}.".colorize(:red)
    public_static_void_main_string_args(process_data(chosen_file))
  end

  def process_data(chosen_file)
    data = YAML.load(File.read("saves/#{chosen_file}")) # rubocop:disable Security/YAMLLoad
    data
  end

  def idiotproof_load(saves) # rubocop:disable all
    offset = 0
    loop do
      visible_saves = saves[(8 * offset)..(7 + (8 * offset))]
      info_about_load(visible_saves)

      action = gets.chomp
      return visible_saves[action.to_i - 2] if visible_saves[action.to_i - 2] && action =~ /[1-8]/

      case action.upcase
      when 'Q' then offset -= 1 unless offset.zero?
      when 'E' then offset += 1 unless saves[(8 * offset + 1)..(7 + (8 * offset + 1))].length.zero?
      when 'X' then return main_menu
      else puts 'Invalid input!'.colorize(:red)
      end
    end
  end
end
