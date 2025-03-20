# frozen_string_literal: true

require_relative 'script_filter_item'

# iOS Simulator
class Simulator
  attr_accessor :name, :udid

  def initialize(args = {})
    @name = args[:name]
    @udid = args[:udid]

    # Create a debug log to track object creation
    log_file = '/tmp/alfred_simulator_objects.log'
    File.write(log_file, "Created Simulator: name=#{@name}, udid=#{@udid}\n", mode: 'a')
  end

  def to_script_filter_item
    # Create a debug log to track conversion
    log_file = '/tmp/alfred_simulator_objects.log'
    File.write(log_file, "Converting to ScriptFilterItem: #{@name}, #{@udid}\n", mode: 'a')

    item = ScriptFilterItem.new(
      { arg: @udid,
        title: @name,
        icon_path: 'assets/simulator.png' }
    )

    File.write(log_file, "Created ScriptFilterItem: #{item.inspect}\n", mode: 'a')
    item
  end

  # For inspection
  def inspect
    "#<Simulator name=#{@name} udid=#{@udid}>"
  end
end
