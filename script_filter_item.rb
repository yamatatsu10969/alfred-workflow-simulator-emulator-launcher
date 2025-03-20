# frozen_string_literal: true

require 'json'

# Item shown in the script filter
class ScriptFilterItem
  attr_reader :uid, :title, :subtitle, :arg, :icon, :mods

  def initialize(options = {})
    @uid = options[:uid]
    @title = options[:title]
    @subtitle = options[:subtitle]
    @arg = options[:arg]
    @icon = options[:icon]
    @mods = options[:mods] || {}
  end

  def to_json(*)
    to_h.to_json
  end

  # Convert to hash for JSON output
  def to_h
    {
      uid: @uid,
      title: @title,
      subtitle: @subtitle,
      arg: @arg,
      icon: @icon,
      mods: @mods
    }
  end

  # For inspection
  def inspect
    "#<ScriptFilterItem title='#{title}' arg='#{arg}'>"
  end
end
