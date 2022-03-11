# frozen_string_literal: true

require 'json'

class Simulator
  attr_accessor :name, :udid

  def initialize(args = {})
    @name = args[:name]
    @udid = args[:udid]
  end

  def to_json(*)
    {
      type: 'file',
      title: @name,
      subtitle: '',
      arg: @udid,
      icon: {
        path: 'simulator.png'
      }
    }.to_json
  end
end
