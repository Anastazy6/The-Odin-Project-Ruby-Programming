# frozen_string_literal: true

require 'colorize'
require 'io/console'
require 'pry'
require 'set'
require 'yaml'

require_relative 'shared_by_many_classes'
require_relative 'messages'
require_relative 'hangman_constants'
require_relative 'change_settings' # TODO: consider refactoring some methods...
require_relative 'game'
require_relative 'round'
require_relative 'player'
require_relative 'human'
require_relative 'computer'
require_relative 'secret_word'

# All the goddamns setup, runs the entire program etc...
class Hangman
  include SharedMethods
  include MessagesForHangman
  include ChangeSettingsMethods
  include Constants

  attr_accessor :settings

  def initialize
    @settings = load_settings
    public_static_void_main_string_args
  end

  private

  # Directly responsible for keeping or terminating the settings-changing loop.
  def are_settings_set?
    change_settings
  end

  def ask_about_settings
    print_settings(asking: true)
    change_settings_wrapper if force_valid_yes_or_no_input
  end

  # Provides the interface to change settings and returns true if the user is satisfied
  #   with them, else returs false - the booleans are used to determine whether the loop
  #   querying next changes is to be terminated or not.
  def change_settings
    case option_to_change
    when 1 then change_max_word_length
    when 2 then change_min_word_length
    when 3 then change_misses_available
    when 4 then change_number_of_rounds
    when 5 then change_player1_type
    when 6 then change_player2_type
    else return user_sure?
    end
    false
  end

  def change_settings_wrapper
    change_settings_intro
    loop do
      print_settings
      change_settings_help
      break if are_settings_set?
    end
    save_settings_message
    save_settings(settings) if force_valid_yes_or_no_input
  end

  def load_settings
    set_default_settings unless File.exist?('data/settings.yaml')
    settings = YAML.load(File.read('data/settings.yaml')) # rubocop:disable Security/YAMLLoad
    settings
  end

  def option_to_change
    gets.chomp.to_i
  end

  def public_static_void_main_string_args
    greet_the_player
    ask_about_settings
    Game.new(settings).main_loop
    # TODO
  end

  def save_settings(new_settings)
    File.open('data/settings.yaml', 'w') do |settings|
      settings.puts(YAML.dump(new_settings))
    end
  end

  def set_default_settings
    defaults = {  max_word_length: 12,
                  min_word_length: 5,
                  misses_available: 4,
                  number_of_rounds: 1,
                  player_1_type: :human,
                  player_2_type: :computer }
    save_settings(defaults)
  end

  def user_sure?
    are_you_sure_message
    force_valid_yes_or_no_input
  end
end

Hangman.new
