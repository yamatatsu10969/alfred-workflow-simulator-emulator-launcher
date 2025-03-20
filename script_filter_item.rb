# frozen_string_literal: true

require 'json'

# Item shown in the script filter
class ScriptFilterItem
  attr_accessor :title, :arg, :icon_path

  def initialize(args = {})
    @title = args[:title]
    @arg = args[:arg]
    @icon_path = args[:icon_path]

    # Create a debug log
    log_file = '/tmp/alfred_script_filter_items.log'
    File.write(log_file, "Created ScriptFilterItem: title=#{@title}, arg=#{@arg}\n", mode: 'a')
  end

  def to_json(*)
    to_h.to_json
  end

  # Add a to_h method to convert to hash
  def to_h
    item_hash = {
      type: 'file',
      title: title,
      subtitle: '',
      arg: arg,
      icon: {
        path: icon_path
      }
    }

    # Create a debug log
    log_file = '/tmp/alfred_script_filter_items.log'
    File.write(log_file, "Converting to hash: #{item_hash.inspect}\n", mode: 'a')

    item_hash
  end

  # For inspection
  def inspect
    "#<ScriptFilterItem title='#{title}' arg='#{arg}'>"
  end
end
