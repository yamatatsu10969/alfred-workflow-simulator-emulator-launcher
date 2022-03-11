# frozen_string_literal: true

require 'json'

class Emulator
  attr_accessor :name

  def initialize(args = {})
    @name = args[:name]
  end

  def to_json(*)
    {
      type: 'file',
      title: @name,
      subtitle: '',
      arg: @name,
      icon: {
        path: 'emulator.png'
      }
    }.to_json
  end
end
