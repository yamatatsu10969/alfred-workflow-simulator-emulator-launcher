# frozen_string_literal: true

require 'json'
require_relative 'script_filter_item'

# Android Emulator
class Emulator
  attr_accessor :name

  def initialize(args = {})
    @name = args[:name]

    # Create debug log
    log_file = '/tmp/alfred_emulator_objects.log'
    File.write(log_file, "Created Emulator: name=#{@name}\n", mode: 'a')
  end

  def to_script_filter_item
    # Create debug log
    log_file = '/tmp/alfred_emulator_objects.log'
    File.write(log_file, "Converting to ScriptFilterItem: #{@name}\n", mode: 'a')

    item = ScriptFilterItem.new(
      { arg: @name,
        title: @name,
        icon_path: 'assets/emulator.png' }
    )

    File.write(log_file, "Created ScriptFilterItem: #{item.inspect}\n", mode: 'a')
    item
  end

  # For inspection
  def inspect
    "#<Emulator name='#{name}'>"
  end
end
