# frozen_string_literal: true

require 'json'
require_relative 'script_filter_item'

# Android Emulator
class Emulator
  attr_accessor :name

  def initialize(args = {})
    @name = args[:name]
  end

  def to_script_filter_item
    ScriptFilterItem.new(
      { arg: @name,
        title: @name,
        icon_path: 'assets/emulator.png' }
    )
  end
end
