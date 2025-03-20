# frozen_string_literal: true

require 'json'

# Item shown in the script filter
class ScriptFilterItem
  attr_reader :uid, :title, :subtitle, :arg, :icon_path, :mods

  def initialize(options = {})
    @uid = options[:uid]
    @title = options[:title]
    @subtitle = options[:subtitle]
    @arg = options[:arg]
    @icon_path = options[:icon_path]
    @mods = options[:mods] || {}
  end

  def to_json(*)
    {
      type: 'file',
      title: @title,
      subtitle: @subtitle,
      arg: @arg,
      icon: {
        path: @icon_path
      }
    }.to_json
  end

  # For inspection
  def inspect
    "#<ScriptFilterItem title='#{title}' arg='#{arg}'>"
  end
end
