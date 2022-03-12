# frozen_string_literal: true

require 'json'

# Item shown in the script filter
class ScriptFilterItem
  attr_accessor :title, :arg, :icon_path

  def initialize(args = {})
    @title = args[:title]
    @arg = args[:arg]
    @icon_path = args[:icon_path]
  end

  def to_json(*)
    {
      type: 'file',
      title: title,
      subtitle: '',
      arg: arg,
      icon: {
        path: icon_path
      }
    }.to_json
  end
end
