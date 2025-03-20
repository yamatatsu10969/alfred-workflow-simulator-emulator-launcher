# frozen_string_literal: true

require_relative 'script_filter_item'

# iOS Simulator
class Simulator
  attr_accessor :name, :udid

  def initialize(args = {})
    @name = args[:name]
    @udid = args[:udid]
  end

  def to_script_filter_item
    ScriptFilterItem.new(
      {
        arg: @udid,
        title: @name,
        icon_path: 'assets/simulator.png'
      }
    )
  end
end
