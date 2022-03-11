# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative 'emulator'

class EmulatorWorkflow
  def self.show_emulators
    OptionParser.new do |opts|
      opts.on('-p', '--path PATH', 'Path to use') do |path|
        @path = path
      end
    end.parse!
    cmd_output = `#{@path} -list-avds`

    emulator_names = cmd_output.split("\n")

    emulators = emulator_names.map do |name|
      Emulator.new({ name: name })
    end

    export_json = {
      'items' => emulators
    }.to_json

    puts export_json
  end
end

EmulatorWorkflow.show_emulators
